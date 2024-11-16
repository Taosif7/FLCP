import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

class PathUtils {
  File? getPubspecFile() {
    var pubspecFile = File('pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      // Try once more in parent directory (in case if user is in a platform directory)
      pubspecFile = File('../pubspec.yaml');

      // And if it still doesn't exist, then it's not a flutter project
      if (pubspecFile.existsSync()) {
        return pubspecFile;
      }
    }

    return null;
  }

  String? getFileName(File pubspecFile) {
    Pubspec pubspec;
    try {
      pubspec = Pubspec.parse(pubspecFile.readAsStringSync());
    } catch (e) {
      return null;
    }
    String projectName = pubspec.name;
    String versionName = pubspec.version.toString().split('+').first;
    String buildNumber = pubspec.version.toString().split('+').last;
    DateTime now = DateTime.now();
    String formattedDate =
        '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';

    String filename =
        '${projectName}_v$versionName($buildNumber)_$formattedDate';

    return filename;
  }
}
