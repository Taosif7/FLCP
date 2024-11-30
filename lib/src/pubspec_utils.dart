import 'dart:io';

import 'package:flcp/src/cli_utils.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class PubspecUtils {
  File? getPubspecFile([bool verbose = false]) {
    var pubspecFile = File('pubspec.yaml');

    if (!pubspecFile.existsSync()) {
      // Try once more in parent directory (in case if user is in a platform directory)
      CLIUtils.printVerbose(
          'pubspec.yaml not found in current directory, checking in parent directory');
      pubspecFile = File('../pubspec.yaml');

      // And if it still doesn't exist, then it's not a flutter project
      if (pubspecFile.existsSync()) {
        return pubspecFile;
      } else {
        CLIUtils.printVerbose('pubspec.yaml not found in parent directory');
        return null;
      }
    } else {
      return pubspecFile;
    }
  }

  String getReleaseFileName(
    Pubspec pubspec, {
    Set<String?> additionalSuffixes = const {},
    bool includeDate = true,
    DateTime? date,
  }) {
    String projectName = pubspec.name;
    String versionName = pubspec.version.toString().split('+').first;
    String buildNumber = pubspec.version.toString().split('+').last;

    String filename = projectName;

    additionalSuffixes = additionalSuffixes
        .whereType<String>()
        .where((e) => e.isNotEmpty && e != projectName)
        .map((e) => e.replaceAll(' ', '_').toLowerCase())
        .toSet();
    filename += additionalSuffixes.isNotEmpty
        ? '_${additionalSuffixes.whereType<String>().join('_')}'
        : '';
    filename += '_v$versionName($buildNumber)';

    if (includeDate) {
      DateTime now = date ?? DateTime.now();
      String formattedDate =
          '${now.day.toString().padLeft(2, '0')}${now.month.toString().padLeft(2, '0')}${now.year.toString().substring(2)}';

      filename += '_$formattedDate';
    }

    return filename;
  }
}
