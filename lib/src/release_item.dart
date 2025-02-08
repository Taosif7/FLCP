import 'package:flcp/src/extensions.dart';

/// An enumeration of release file types.
enum ReleaseType {
  apk(false, 'apk'),
  aab(false, 'aab'),
  ipa(false, 'ipa'),
  web(true, 'zip'),
  exe(true, 'zip'),
  msix(false, 'msix');

  final bool isFolder;
  final String extension;

  const ReleaseType(this.isFolder, this.extension);
}

/// Represents a release item with file [path], release [type],
/// an optional [flavor], optional [buildType] and [date] stamp.
class ReleaseItem {
  final String path;
  final ReleaseType type;
  final String? flavor;
  final String? buildType;

  final DateTime date;

  /// Returns the file name or 'folder' for web/exe types.
  String get fileName {
    if (type == ReleaseType.web || type == ReleaseType.exe) {
      return 'folder';
    } else {
      return path.filename;
    }
  }

  ReleaseItem({
    required this.path,
    required this.flavor,
    required this.type,
    required this.date,
    this.buildType,
  });

  @override
  String toString() {
    return "${type.name.toString().toUpperCase()}: $fileName - $flavor - $buildType";
  }
}
