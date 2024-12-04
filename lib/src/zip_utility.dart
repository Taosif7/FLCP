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
      // Create a PowerShell script that preserves folder structure and handles exclusions
      final tempScript = '''
\$ErrorActionPreference = 'Stop'

# Function to check if a file should be excluded
function ShouldExcludeFile(\$filePath) {
    \$relativePath = \$filePath.Replace('${folder.path.replaceAll('\\', '/')}/', '').ToLower()
    \$excludeFiles = @(${excludeFiles.map((f) => '"${f.toLowerCase().replaceAll('\\', '/')}"').join(', ')})
    
    foreach (\$excludePattern in \$excludeFiles) {
        if (\$relativePath -like "*\$excludePattern*") {
            return \$true
        }
    }
    return \$false
}

# Get all files in the directory, excluding specified files
\$filesToZip = Get-ChildItem -Path "${folder.path}" -Recurse -File | 
    Where-Object { 
        -not (ShouldExcludeFile \$_.FullName) 
    } | 
    Select-Object -ExpandProperty FullName

# Compress files while maintaining directory structure
Compress-Archive -Path \$filesToZip -DestinationPath "$zipPath"
''';

      final tempFile = File('${folder.path}/temp_zip_script.ps1');
      tempFile.writeAsStringSync(tempScript);

      // Run the PowerShell script
      final result = Process.runSync(
        'powershell',
        ['-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', tempFile.path],
        runInShell: true,
      );

      // Clean up temporary script
      tempFile.deleteSync();

      // Check for errors in script execution
      if (result.exitCode != 0) {
        throw Exception('Zip creation failed: ${result.stderr}');
      }

      return zipFile;
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
