import 'dart:io';

import 'package:args/args.dart';

import 'file_extractors.dart';
import 'release_item.dart';

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

    String? desktopPath = _getDesktopPath();

    if (desktopPath == null) {
      print('Unsupported platform');
      return;
    } else {
      desktopPath += '/Desktop';
      if (verbose) {
        print('Desktop path: $desktopPath');
      }
    }

    printInfo("Finding build files across the project...");

    List<ReleaseItem> getReleases = _getBuildFiles(
      apk: arguments.contains("android") || arguments.contains("apk"),
      aab: arguments.contains("android") || arguments.contains("aab"),
      ios: arguments.contains("ios") || arguments.contains("ipa"),
      web: arguments.contains("web"),
    );
    if (getReleases.isEmpty) {
      printError('No build files found');
      return;
    }

    printSuccess("Found ${getReleases.length} build files:");
    for (int i = 0; i < getReleases.length; i++) {
      print(
          "    ${i + 1}) ${getReleases[i].type.name} - ${getReleases[i].fileName}");
    }

    printInfo("Copying build files to Desktop...");
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    printError(e.message);
    printUsage(argParser);
  }
}

void printError(String message) {
  print('❌ $message');
}

void printWarning(String message) {
  print('⚠️ $message');
}

void printInfo(String message) {
  print('ℹ️ $message');
}

void printSuccess(String message) {
  print('✅ $message');
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

String? _getDesktopPath() {
  if (Platform.isMacOS) {
    return Platform.environment['HOME'];
  } else if (Platform.isWindows) {
  } else if (Platform.isLinux) {}
  return null;
}
