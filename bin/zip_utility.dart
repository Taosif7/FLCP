import 'dart:io';

class ZipUtility {
  File zipFiles(List<File> files, String zipName) {
    File zipFile = File(zipName);
    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }

    if (Platform.isMacOS || Platform.isLinux) {
      Process.runSync('zip', ['-r', zipName, ...files.map((e) => e.path)]);
      return zipFile;
    } else if (Platform.isWindows) {
      Process.runSync('powershell',
          ['Compress-Archive', ...files.map((e) => e.path), zipName]);
      return zipFile;
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
