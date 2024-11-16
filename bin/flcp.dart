import 'dart:io';

import 'package:args/args.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

import 'file_extractors.dart';
import 'release_item.dart';
import 'utils.dart';
import 'zip_utility.dart';

const String version = '0.0.1';

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
    bool verbose = false;
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
      verbose = true;
    }
    if (results.wasParsed('no-date')) {
      includeDate = false;
    }

    // Read project info

    printInfo("Reading project info...");

    var pubspecFile = PubspecUtils().getPubspecFile();

    if (pubspecFile == null) {
      printError('pubspec.yaml file not found');
      print("Please run this command in the root of your flutter project");
      return;
    }

    Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    } catch (e) {
      printError("Error reading pubspec.yaml file");
      return;
    }

    // Find build files

    printInfo("Finding build files across the project...");

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

    List<ReleaseItem> releases = _getBuildFiles(
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
      printError('No build files found');
      return;
    }

    printSuccess("Found ${releases.length} build files:");
    for (int i = 0; i < releases.length; i++) {
      print("    ${i + 1}) ${releases[i].type.name} - ${releases[i].fileName}");
    }

    // Copy build files to Desktop

    printInfo("Copying build files to Desktop...");

    Directory? desktopPath = _getDesktopPath();

    if (desktopPath == null) {
      print('Unsupported platform');
      return;
    }

    _copyReleaseFiles(
      desktopPath,
      releases,
      pubspec,
      includeDate,
    );

    printSuccess("Copied ${releases.length} build files to Desktop");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    printError(e.message);
    printUsage(argParser);
  }
}

void printError(String message) {
  print('❌  $message');
}

void printWarning(String message) {
  print('⚠️ $message');
}

void printInfo(String message) {
  print('ℹ️ $message');
}

void printSuccess(String message) {
  print('✅  $message');
}

List<ReleaseItem> _getBuildFiles({
  bool apk = true,
  bool aab = true,
  bool ios = true,
  bool web = true,
}) {
  List<ReleaseItem> buildFiles = [];

  if (apk) {
    buildFiles.addAll(FileExtractors().extractAPKReleaseFiles());
  }
  if (aab) {
    buildFiles.addAll(FileExtractors().extractAABReleaseFiles());
  }
  if (ios) {
    buildFiles.addAll(FileExtractors().extractIPAReleaseFiles());
  }
  if (web) {
    buildFiles.addAll(FileExtractors().extractWebReleaseFiles());
  }

  return buildFiles;
}

List<File> _copyReleaseFiles(
  Directory targetDir,
  List<ReleaseItem> releaseItems,
  Pubspec pubspec,
  bool includeDateInFileName,
) {
  List<File> copiedFiles = [];
  for (ReleaseItem releaseItem in releaseItems) {
    if (releaseItem.type == ReleaseType.web) {
      Directory webReleaseDir = Directory(releaseItem.path);
      String releaseName = PubspecUtils().getReleaseFileName(
        pubspec,
        additionalSuffixes: ['web'],
        includeDate: includeDateInFileName,
      );
      String zipFilePath = "${targetDir.path}/$releaseName.zip";
      ZipUtility zipUtility = ZipUtility();
      zipUtility.zipFiles(webReleaseDir, zipFilePath);
    } else {
      File file = File(releaseItem.path);
      String releaseName = PubspecUtils().getReleaseFileName(
        pubspec,
        additionalSuffixes: [releaseItem.flavor, releaseItem.buildType],
        includeDate: includeDateInFileName,
      );
      File newFile = File(
        '${targetDir.path}/$releaseName.${releaseItem.type.name}',
      );
      file.copy(newFile.path);
      copiedFiles.add(newFile);
    }
  }
  return copiedFiles;
}

Directory? _getDesktopPath() {
  Directory? dir;
  if (Platform.isMacOS) {
    dir = Directory("${Platform.environment['HOME']}/Desktop");
  } else if (Platform.isWindows) {
  } else if (Platform.isLinux) {}

  if (dir != null && dir.existsSync()) {
    return dir;
  }
  return null;
}
