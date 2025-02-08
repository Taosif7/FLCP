import 'dart:io';

import 'package:flcp/src/pubspec_utils.dart';
import 'package:flcp/src/release_item.dart';
import 'package:flcp/src/zip_utility.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

/// Utility functions for file operations such as determining desktop path
/// and copying release files.
class FileUtils {
  /// Returns the desktop directory if available, otherwise null.
  Directory? getDesktopPath() {
    Directory? dir;
    if (Platform.isMacOS || Platform.isLinux) {
      dir = Directory("${Platform.environment['HOME']}/Desktop");
    } else if (Platform.isWindows) {
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        dir = Directory("$userProfile\\Desktop");
      }
    }

    if (dir != null && dir.existsSync()) {
      return dir;
    }
    return null;
  }

  /// Copies release files to the [targetDir] using project [pubspec]
  /// information. Includes date in file names based on [includeDateInFileName].
  List<File> copyReleaseFiles(
    Directory targetDir,
    List<ReleaseItem> releaseItems,
    Pubspec pubspec,
    bool includeDateInFileName, [
    List<String> suffixes = const [],
  ]) {
    List<File> copiedFiles = [];
    for (ReleaseItem releaseItem in releaseItems) {
      if (releaseItem.type == ReleaseType.exe) {
        Directory exeReleaseDir = Directory(releaseItem.path);
        String releaseName = PubspecUtils().getReleaseFileName(
          pubspec,
          additionalSuffixes: {'windows', ...suffixes},
          includeDate: includeDateInFileName,
        );
        String zipFilePath = "${targetDir.path}/$releaseName.zip";

        List<String> msixFilePaths =
            exeReleaseDir.listSync().where((file) => file.path.endsWith('.msix')).map((file) => file.path).toList();

        ZipUtility zipUtility = ZipUtility();
        zipUtility.zipFiles(exeReleaseDir, zipFilePath, msixFilePaths);
      } else if (releaseItem.type == ReleaseType.web) {
        Directory webReleaseDir = Directory(releaseItem.path);
        String releaseName = PubspecUtils().getReleaseFileName(
          pubspec,
          additionalSuffixes: {'web', ...suffixes},
          includeDate: includeDateInFileName,
        );
        String zipFilePath = "${targetDir.path}/$releaseName.zip";
        ZipUtility zipUtility = ZipUtility();
        zipUtility.zipFiles(webReleaseDir, zipFilePath);
      } else {
        File file = File(releaseItem.path);
        String releaseName = PubspecUtils().getReleaseFileName(
          pubspec,
          additionalSuffixes: {releaseItem.flavor, releaseItem.buildType, ...suffixes},
          includeDate: includeDateInFileName,
          date: releaseItem.date,
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
}
