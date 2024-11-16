import 'dart:io';

import 'package:args/args.dart';
import 'package:flcp/src/cli_utils.dart';
import 'package:flcp/src/file_extractors.dart';
import 'package:flcp/src/file_utils.dart';
import 'package:flcp/src/pubspec_utils.dart';
import 'package:flcp/src/release_item.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

const String version = '1.0.0';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addFlag(
      'no-date',
      negatable: false,
      abbr: 'd',
      defaultsTo: false,
      help: 'Do not include the date in the release file name.',
    );
}

void printUsage(ArgParser argParser) {
  print('Usage: dart flcp.dart <flags> [arguments]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool includeDate = true;

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('flcp version: $version');
      return;
    }
    if (results.wasParsed('verbose')) {
      CLIUtils.verbose = true;
    }
    if (results.wasParsed('no-date')) {
      includeDate = false;
    }

    // Read project info

    CLIUtils.printVerbose("Verbose mode enabled");

    CLIUtils.printInfo("Reading project info...");

    var pubspecFile = PubspecUtils().getPubspecFile();

    if (pubspecFile == null) {
      CLIUtils.printError('pubspec.yaml file not found');
      CLIUtils.printWarning(
          "Please run this command in the root of your flutter project");
      return;
    }

    Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    } catch (e) {
      CLIUtils.printVerbose(e.toString());
      CLIUtils.printError("Error reading pubspec.yaml file");
      return;
    }

    // Find build files

    CLIUtils.printInfo("Finding build files across the project...");

    List<String> supportedPlatformsAndFiles = [
      "android",
      "ios",
      "web",
      "apk",
      "aab",
      "ipa"
    ];

    bool noExplicitPlatform = arguments
            .any((platform) => supportedPlatformsAndFiles.contains(platform)) ==
        false;

    List<ReleaseItem> releases = FileExtractors().getBuildFiles(
      apk: noExplicitPlatform ||
          arguments.contains("android") ||
          arguments.contains("apk"),
      aab: noExplicitPlatform ||
          arguments.contains("android") ||
          arguments.contains("aab"),
      ios: noExplicitPlatform ||
          arguments.contains("ios") ||
          arguments.contains("ipa"),
      web: noExplicitPlatform || arguments.contains("web"),
    );

    if (releases.isEmpty) {
      CLIUtils.printError('No build files found');
      return;
    }

    CLIUtils.printSuccess("Found ${releases.length} build files:");
    for (int i = 0; i < releases.length; i++) {
      print("    ${i + 1}) ${releases[i].type.name} - ${releases[i].fileName}");
    }

    // Copy build files to Desktop

    CLIUtils.printInfo("Copying build files to Desktop...");

    Directory? desktopPath = FileUtils().getDesktopPath();

    CLIUtils.printVerbose("Desktop path: ${desktopPath?.path}");

    if (desktopPath == null) {
      print('Unsupported platform');
      return;
    }

    FileUtils().copyReleaseFiles(
      desktopPath,
      releases,
      pubspec,
      includeDate,
    );

    CLIUtils.printSuccess("Copied ${releases.length} build files to Desktop");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    CLIUtils.printError(e.message);
    printUsage(argParser);
  }
}
