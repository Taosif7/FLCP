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
      // Get the directory and base name from the zip path
      final lastSeparator = zipPath.lastIndexOf('\\');
      final zipDirectory =
          lastSeparator != -1 ? zipPath.substring(0, lastSeparator) : '.';
      final zipBaseName =
          zipPath.substring(lastSeparator + 1).replaceAll('.zip', '');

      // Create the PowerShell script next to where the ZIP will be
      final scriptPath = '$zipDirectory\\${zipBaseName}_script.ps1';
      final tempFile = File(scriptPath);

      // Create a PowerShell script that uses System.IO.Compression
      final tempScript = '''
# Define function to zip folder with exclusions
function Compress-FolderWithExclusions {
    param (
        [Parameter(Mandatory = \$true)]
        [string]\$SourceFolder,      # Path to the folder to zip
        [Parameter(Mandatory = \$true)]
        [string]\$DestinationZip,    # Path for the resulting ZIP file
        [Parameter(Mandatory = \$false)]
        [string[]]\$ExcludePatterns  # Array of file patterns to exclude
    )

    # Ensure System.IO.Compression.FileSystem is loaded
    Add-Type -AssemblyName 'System.IO.Compression.FileSystem'

    # Create a temporary folder for zipping
    \$TempFolder = Join-Path -Path \$env:TEMP -ChildPath ([guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Path \$TempFolder | Out-Null

    try {
        # Copy the folder structure while excluding specified files
        Get-ChildItem -Path \$SourceFolder -Recurse | ForEach-Object {
            \$RelativePath = \$_.FullName.Substring(\$SourceFolder.Length).TrimStart('\\')
            
            # Check if the file matches any exclusion patterns
            \$Exclude = \$false
            foreach (\$Pattern in \$ExcludePatterns) {
                if (\$_ -is [System.IO.FileInfo] -and (\$_.Name -like \$Pattern)) {
                    \$Exclude = \$true
                    break
                }
            }

            if (-not \$Exclude) {
                \$TargetPath = Join-Path -Path \$TempFolder -ChildPath \$RelativePath
                
                # Create directories or copy files as needed
                if (\$_ -is [System.IO.DirectoryInfo]) {
                    New-Item -ItemType Directory -Path \$TargetPath -Force | Out-Null
                }
                elseif (\$_ -is [System.IO.FileInfo]) {
                    Copy-Item -Path \$_.FullName -Destination \$TargetPath
                }
            }
        }

        # Create the ZIP file from the temp folder
        [System.IO.Compression.ZipFile]::CreateFromDirectory(\$TempFolder, \$DestinationZip)
        Write-Host "Successfully created ZIP: \$DestinationZip"
    }
    catch {
        Write-Error "An error occurred: \$_"
        throw
    }
    finally {
        # Clean up the temporary folder
        Remove-Item -Path \$TempFolder -Recurse -Force
    }
}

# Call the function with parameters
Compress-FolderWithExclusions -SourceFolder "${folder.path}" -DestinationZip "$zipPath" -ExcludePatterns @(${excludeFiles.map((f) => "'$f'").join(', ')})
''';

      try {
        tempFile.writeAsStringSync(tempScript);

        // Run the PowerShell script
        final result = Process.runSync(
          'powershell',
          ['-ExecutionPolicy', 'Bypass', '-NoProfile', '-File', tempFile.path],
          runInShell: true,
        );

        // Check for errors in script execution
        if (result.exitCode != 0) {
          throw Exception('Zip creation failed: ${result.stderr}');
        }

        return zipFile;
      } finally {
        // Clean up the temporary script file
        if (tempFile.existsSync()) {
          tempFile.deleteSync();
        }
      }
    } else {
      throw Exception('Unsupported platform');
    }
  }
}
