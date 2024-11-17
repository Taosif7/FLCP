import 'dart:io';

class ZipUtility {
  File zipFiles(
    Directory folder,
    String zipPath, [
    List<String> excludeFiles = const [],
  ]) {
    File zipFile = File(zipPath);
    if (zipFile.existsSync()) {
      zipFile.deleteSync();
    }

    if (!folder.existsSync()) {
      throw Exception('The specified folder does not exist');
    }

    if (Platform.isMacOS || Platform.isLinux) {
      // Use `zip` command, specifying folder contents
      final excludeArgs =
          excludeFiles.map((file) => '--exclude=${folder.path}/$file').toList();
      Process.runSync(
        'zip',
        [
          '-r',
          zipPath,
          '.',
          ...excludeArgs,
        ],
        workingDirectory: folder.path,
      );
      return zipFile;
    } else if (Platform.isWindows) {
      // Use PowerShell's `Compress-Archive`, specifying folder contents
      final excludeSet = excludeFiles.map((e) => e.toLowerCase()).toSet();
      final items = Directory(folder.path)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => !excludeSet.contains(
                file.path
                    .toLowerCase()
                    .replaceAll(folder.path.toLowerCase(), ''),
              ))
          .map((file) => file.path)
          .toList();

      final tempScript = '''
\$files = @(${items.map((path) => '"$path"').join(', ')})
Compress-Archive -Path \$files -DestinationPath "$zipPath"
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
