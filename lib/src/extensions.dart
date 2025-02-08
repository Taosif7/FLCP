import 'dart:io';

/// Extension on [String] to provide helper methods for file path manipulations.
extension PathExtensions on String {
  /// Returns the file name extracted from the path.
  String get filename {
    if (Platform.isMacOS || Platform.isLinux) {
      return split('/').last;
    } else if (Platform.isWindows) {
      return split('\\').last;
    } else {
      return split('/').last;
    }
  }
}
