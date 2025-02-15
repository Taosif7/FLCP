import 'dart:io';

import 'package:flcp/src/cli_utils.dart';
import 'package:flcp/src/extensions.dart';
import 'package:flcp/src/release_item.dart';

/// Contains functions to scan directories and extract release items
/// for various platforms and build types.
class FileExtractors {
  /// Retrieves build files for different platforms based on provided boolean flags.
  List<ReleaseItem> getBuildFiles({
    bool apk = true,
    bool aab = true,
    bool ios = true,
    bool web = true,
    bool msix = true,
    bool exe = true,
  }) {
    List<ReleaseItem> buildFiles = [];

    if (apk) {
      CLIUtils.printVerbose("Adding APK files...");
      buildFiles.addAll(extractAPKReleaseFiles());
    }
    if (aab) {
      CLIUtils.printVerbose("Adding AAB files...");
      buildFiles.addAll(extractAABReleaseFiles());
    }
    if (ios) {
      CLIUtils.printVerbose("Adding IPA files...");
      buildFiles.addAll(extractIPAReleaseFiles());
    }
    if (web) {
      CLIUtils.printVerbose("Adding Web files...");
      buildFiles.addAll(extractWebReleaseFiles());
    }
    if (msix) {
      CLIUtils.printVerbose("Adding MSIX files...");
      buildFiles.addAll(extractMSIXReleaseFiles());
    }
    if (exe) {
      CLIUtils.printVerbose("Adding EXE files...");
      buildFiles.addAll(extractEXEReleaseFiles());
    }

    return buildFiles;
  }

  /// Extracts APK release files from a specified [directory] or the default location.
  List<ReleaseItem> extractAPKReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/app/outputs/flutter-apk/');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("APK build directory not found");
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith("-release.apk")) {
        String fileName = element.path.filename;
        String flavor =
            fileName.split('-').sublist(1).join("-").split(".").first;
        String buildType = fileName.split('-').last.split(".").first;
        flavor = flavor.replaceAll("-$buildType", "");

        CLIUtils.printVerbose("APK Found: $fileName");

        if (flavor == 'debug') {
          return;
        }

        files.add(ReleaseItem(
          path: element.path,
          flavor: flavor,
          type: ReleaseType.apk,
          buildType: buildType,
          date: element.lastModifiedSync(),
        ));
      } else if (element is Directory) {
        files.addAll(extractAPKReleaseFiles(element));
      }
    });

    return files;
  }

  /// Extracts AAB release files from a specified [directory] or the default location.
  List<ReleaseItem> extractAABReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/app/outputs/bundles/release');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("AAB build directory not found");
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith(".apk")) {
        String fileName = element.path.filename;
        String flavor =
            fileName.split('-').sublist(1).join("-").split(".").first;
        String buildType = fileName.split('-').last.split(".").first;
        flavor = flavor.replaceAll("-$buildType", "");

        CLIUtils.printVerbose("AAB Found: $fileName");

        if (flavor == 'debug') {
          return;
        }

        files.add(ReleaseItem(
          path: element.path,
          flavor: flavor,
          type: ReleaseType.aab,
          buildType: buildType,
          date: element.lastModifiedSync(),
        ));
      } else if (element is Directory) {
        files.addAll(extractAABReleaseFiles(element));
      }
    });

    return files;
  }

  /// Extracts IPA release files from a specified [directory] or the default location.
  List<ReleaseItem> extractIPAReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/ios/ipa/');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("IPA build directory not found");
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith(".ipa")) {
        String fileName = element.path.filename;

        CLIUtils.printVerbose("IPA Found: $fileName");

        // Handle different iOS build naming patterns
        // Example: AppName-Flavor-1.0.0-release.ipa
        List<String> parts = fileName.split('-');
        String buildType = 'release'; // Default to release for archives
        String flavor = '';

        if (parts.length > 1) {
          // Remove .ipa extension and split remaining parts
          parts = parts.join('-').split('.').first.split('-');

          // Last part is usually build type or version
          if (parts.last.toLowerCase() == 'debug' ||
              parts.last.toLowerCase() == 'release') {
            buildType = parts.last.toLowerCase();
            parts.removeLast();
          }

          // Check if we have a version number
          if (parts.last.contains(RegExp(r'\d+\.\d+'))) {
            parts.removeLast(); // Remove version number
          }

          // Remaining parts after app name are considered flavor
          if (parts.length > 1) {
            flavor = parts.sublist(1).join('-');
          }
        }

        if (buildType == 'debug') {
          return; // Skip debug builds
        }

        files.add(ReleaseItem(
          path: element.path,
          flavor: flavor,
          type: ReleaseType.ipa,
          buildType: buildType,
          date: element.lastModifiedSync(),
        ));
      } else if (element is Directory) {
        files.addAll(extractIPAReleaseFiles(element));
      }
    });

    return files;
  }

  /// Extracts web release items from a specified [directory] or the default location.
  List<ReleaseItem> extractWebReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/web/');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("Web build directory not found");
      return [];
    }

    List<ReleaseItem> files = [];

    CLIUtils.printVerbose("Web Build Found: ${directory.path}");

    files.add(
      ReleaseItem(
        path: directory.path,
        flavor: 'release',
        buildType: null,
        type: ReleaseType.web,
        date: DateTime.now(),
      ),
    );

    return files;
  }

  /// Extracts MSIX release files from a specified [directory] or fallback locations.
  List<ReleaseItem> extractMSIXReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/windows/x64/runner/Release/');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose(
          "MSIX build directory not found: ${directory.path}");
      directory = Directory('build/windows/runner/Release/');
    }
    if (directory.existsSync() == false) {
      CLIUtils.printVerbose(
          "MSIX build directory not found: ${directory.path}");
      directory = Directory('build/windows/arm64/runner/Release/');
    }
    if (directory.existsSync() == false) {
      CLIUtils.printVerbose(
          "MSIX build directory not found: ${directory.path}");
      return [];
    }

    List<ReleaseItem> files = [];

    CLIUtils.printVerbose("MSIX Build Found: ${directory.path}");

    var dirFiles = directory.listSync();

    for (var item in dirFiles) {
      if (item is File) {
        if (item.path.endsWith(".msix")) {
          files.add(
            ReleaseItem(
              path: item.path,
              flavor: 'release',
              buildType: 'msix',
              type: ReleaseType.msix,
              date: item.lastModifiedSync(),
            ),
          );
        }
      }
    }

    return files;
  }

  /// Extracts EXE release items from a specified [directory] or fallback locations.
  List<ReleaseItem> extractEXEReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/windows/x64/runner/Release/');

    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("EXE build directory not found: ${directory.path}");
      directory = Directory('build/windows/runner/Release/');
    }
    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("EXE build directory not found: ${directory.path}");
      directory = Directory('build/windows/arm64/runner/Release/');
    }
    if (directory.existsSync() == false) {
      CLIUtils.printVerbose("EXE build directory not found: ${directory.path}");
      return [];
    }

    List<ReleaseItem> files = [];

    CLIUtils.printVerbose("EXE Build Found: ${directory.path}");

    files.add(
      ReleaseItem(
        path: directory.path,
        flavor: 'release',
        buildType: 'msix',
        type: ReleaseType.exe,
        date: DateTime.now(),
      ),
    );

    return files;
  }
}
