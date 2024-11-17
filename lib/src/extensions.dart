import 'dart:io';

extension PathExtensions on String {
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
