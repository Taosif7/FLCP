import 'dart:io';

class ZipUtility {
  File zipFiles(
    Directory folder,
    String zipPath,
  ) {
    File zipFile = File(zipPath);
    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }

    if (!folder.existsSync()) {
      throw Exception('The specified folder does not exist');
    }

    if (Platform.isMacOS || Platform.isLinux) {
      // Use `zip` command, specifying folder contents
      Process.runSync(
        'zip',
        [
          '-r',
          zipPath,
          '.',
        ],
        workingDirectory: folder.path,
      );
      return zipFile;
    } else if (Platform.isWindows) {
      // Use PowerShell's `Compress-Archive`, specifying folder contents
      final tempScript = '''
\$items = Get-ChildItem -Path "${folder.path}" -Recurse
Compress-Archive -Path \$items.FullName -DestinationPath "$zipPath"
''';
      final tempFile = File('${folder.path}/temp_zip_script.ps1');
      tempFile.writeAsStringSync(tempScript);
      Process.runSync(
          'powershell', ['-ExecutionPolicy', 'Bypass', '-File', tempFile.path]);
      tempFile.deleteSync();
      return zipFile;
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
