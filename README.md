# FLCP (Flutter Copy)

A command line tool that automatically finds, renames, and copies Flutter build files to your
desktop using a standardized naming convention.

## Installation

Install FLCP globally using:

```bash
$ dart pub global activate flcp
```

## Features

- Automatically locates and copies Flutter build files to your desktop
- Standardized naming convention: `{projectName}_{version}_{mmddyy}`
- Reads project information directly from pubspec.yaml
- Selective platform copying (Android APK/AAB, iOS IPA, Web builds)
- Automatically packages web release files into a zip archive
- Verbose mode for detailed operation logging

## Usage

### Basic Usage

Copy all available build files:

```bash
$ flcp
```

### Platform-Specific Copying

Copy builds for specific platforms:

```bash
# Copy only Android builds (APK & AAB)
$ flcp android

# Copy only iOS builds
$ flcp ios

# Copy only web builds
$ flcp web

# Copy specific file types
$ flcp apk aab
$ flcp ipa
```

### Command Options

```bash
Options:
  -h, --help       Print usage information
  -v, --verbose    Show additional command output
  --version        Print the tool version
  -d, --no-date    Exclude date from the release file name
```

### Important Notes

- Must be run from the root directory of your Flutter project
- Requires a valid pubspec.yaml file
- Build files must exist in their default Flutter output locations
- Supported build types:
  - Android: APK and AAB
  - iOS: IPA
  - Web: Build directory

## Error Handling

The tool provides clear error messages for common issues:

- Missing pubspec.yaml file
- Invalid pubspec.yaml format
- No build files found
- Unsupported platforms
- Invalid command arguments

## Limitations

- Only copies release builds
- Desktop builds not currently supported
- Must be run from project root directory

## Version

Current version: 1.0.0

I've improved the documentation by:

1. Adding more detailed usage examples
2. Including all available command flags
3. Clarifying supported platforms and file types
4. Adding error handling and limitations sections
5. Providing more context around where and how to run the tool
6. Making the naming convention match what's actually in the code
7. Adding version information
8. Restructuring for better readability and completeness

Would you like me to expand on any particular section or add more specific examples?