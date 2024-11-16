import 'dart:io';

import 'package:pubspec_parse/pubspec_parse.dart';

class PubspecUtils {
  File? getPubspecFile() {
    var pubspecFile = File('pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      // Try once more in parent directory (in case if user is in a platform directory)
      pubspecFile = File('../pubspec.yaml');

      // And if it still doesn't exist, then it's not a flutter project
      if (pubspecFile.existsSync()) {
        return pubspecFile;
      } else {
        return null;
      }
    } else {
      return pubspecFile;
    }
  }

  String getReleaseFileName(
    Pubspec pubspec, {
    List<String?> additionalSuffixes = const [],
    bool includeDate = true,
  }) {
    String projectName = pubspec.name;
    String versionName = pubspec.version.toString().split('+').first;
    String buildNumber = pubspec.version.toString().split('+').last;

    String filename = projectName;

    additionalSuffixes = additionalSuffixes
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    filename += additionalSuffixes.isNotEmpty
        ? '_${additionalSuffixes.whereType<String>().join('_')}'
        : '';
    filename += '_v$versionName($buildNumber)';

    if (includeDate) {
      DateTime now = DateTime.now();
      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';

      filename += '_$formattedDate';
    }

    return filename;
  }
}
