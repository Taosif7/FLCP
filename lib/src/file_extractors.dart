import 'dart:io';

import 'package:flcp/src/release_item.dart';

class FileExtractors {
  List<ReleaseItem> getBuildFiles({
    bool apk = true,
    bool aab = true,
    bool ios = true,
    bool web = true,
  }) {
    List<ReleaseItem> buildFiles = [];

    if (apk) {
      buildFiles.addAll(extractAPKReleaseFiles());
    }
    if (aab) {
      buildFiles.addAll(extractAABReleaseFiles());
    }
    if (ios) {
      buildFiles.addAll(extractIPAReleaseFiles());
    }
    if (web) {
      buildFiles.addAll(extractWebReleaseFiles());
    }

    return buildFiles;
  }

  List<ReleaseItem> extractAPKReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/app/outputs/apk/');

    if (directory.existsSync() == false) {
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith(".apk")) {
        String fileName = element.path.split('/').last;
        String flavor =
            fileName.split('-').sublist(1).join("-").split(".").first;
        String buildType = fileName.split('-').last.split(".").first;
        flavor = flavor.replaceAll("-$buildType", "");

        if (flavor == 'debug') {
          return;
        }

        files.add(ReleaseItem(
          path: element.path,
          flavor: flavor,
          type: ReleaseType.apk,
          buildType: buildType,
        ));
      } else if (element is Directory) {
        files.addAll(extractAPKReleaseFiles(element));
      }
    });

    return files;
  }

  List<ReleaseItem> extractAABReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/app/outputs/aab/');

    if (directory.existsSync() == false) {
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith(".apk")) {
        String fileName = element.path.split('/').last;
        String flavor =
            fileName.split('-').sublist(1).join("-").split(".").first;
        String buildType = fileName.split('-').last.split(".").first;
        flavor = flavor.replaceAll("-$buildType", "");

        if (flavor == 'debug') {
          return;
        }

        files.add(ReleaseItem(
          path: element.path,
          flavor: flavor,
          type: ReleaseType.aab,
          buildType: buildType,
        ));
      } else if (element is Directory) {
        files.addAll(extractAABReleaseFiles(element));
      }
    });

    return files;
  }

  List<ReleaseItem> extractIPAReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/ios/ipa/');

    if (directory.existsSync() == false) {
      return [];
    }

    List<ReleaseItem> files = [];

    directory.listSync().forEach((element) {
      if (element is File && element.path.endsWith(".ipa")) {
        String fileName = element.path.split('/').last;

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
        ));
      } else if (element is Directory) {
        files.addAll(extractIPAReleaseFiles(element));
      }
    });

    return files;
  }

  List<ReleaseItem> extractWebReleaseFiles([Directory? directory]) {
    directory ??= Directory('build/web/');

    if (directory.existsSync() == false) {
      return [];
    }

    List<ReleaseItem> files = [];

    files.add(
      ReleaseItem(
        path: directory.path,
        flavor: null,
        type: ReleaseType.web,
        buildType: 'release',
      ),
    );

    return files;
  }
}
