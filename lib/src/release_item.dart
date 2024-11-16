enum ReleaseType {
  apk,
  aab,
  ipa,
  web,
}

class ReleaseItem {
  final String path;
  final ReleaseType type;
  final String? flavor;
  final String? buildType;

  String get fileName {
    if (type == ReleaseType.web) {
      return 'folder';
    } else {
      return path.split('/').last;
    }
  }

  ReleaseItem({
    required this.path,
    required this.flavor,
    required this.type,
    this.buildType,
  });

  @override
  String toString() {
    return "${type.name.toString().toUpperCase()}: $fileName - $flavor - $buildType";
  }
}
