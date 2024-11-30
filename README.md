# FLCP (Flutter Copy)

A command-line tool that automatically finds, renames, and copies Flutter build files to your
desktop using a standardized naming convention.

## Features

- Automatically locate and copy Flutter build files to your desktop
- Standardized naming convention: `{projectName}_{flavor}_{version}_{mmddyy}`
- Read project information directly from pubspec.yaml
- Selective platform copying:
  - Android: APK and AAB
  - iOS: IPA
  - Web: Zipped web build
  - Windows: EXE and MSIX
- Automatically packages web release files into a zip archive
- Verbose mode for detailed operation logging

## Prerequisites

- Dart SDK
- Flutter project with build files generated

## Installation

Install FLCP globally using:

```bash
$ dart pub global activate flcp
```

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

# Copy Windows builds
$ flcp windows

# Copy specific file types
$ flcp apk aab
$ flcp ipa

# Copy multiple platforms
$ flcp android ios
```

### Command Options

```
Options:
  -h, --help       Print usage information
  -v, --verbose    Show additional command output
  --version        Print the tool version
  -d, --no-date    Exclude date from the release file name
```

## Requirements

- Must be run from the root directory of your Flutter project
- Requires a valid `pubspec.yaml` file
- Supports desktop environments (macOS, Windows, Linux)

## Version

Current version: 1.0.0

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Read the [license file](LICENSE) for more information.

## Author

Taosif Jamal

- [LinkedIn](https://www.linkedin.com/in/taosif7/)
