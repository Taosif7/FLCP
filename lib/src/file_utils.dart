import 'dart:io';

import 'package:flcp/src/pubspec_utils.dart';
import 'package:flcp/src/release_item.dart';
import 'package:flcp/src/zip_utility.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

class FileUtils {
  Directory? getDesktopPath() {
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

  List<File> copyReleaseFiles(
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
}
