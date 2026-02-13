import 'dart:io';

const Map<String, List<String>> _required = <String, List<String>>{
  'macos': <String>['arm64', 'x64'],
  'linux': <String>['arm64', 'x64'],
  'windows': <String>['x64'],
  'android': <String>['arm64'],
  'ios': <String>['arm64'],
};

const Set<String> _allowedLibNames = <String>{
  'libopentui_native.so',
  'libopentui_native.dylib',
  'opentui_native.dll',
  '.gitkeep',
};

Future<void> main() async {
  final root = Directory('native');
  if (!root.existsSync()) {
    stderr.writeln('Missing native directory: ${root.path}');
    exitCode = 1;
    return;
  }

  final missing = <String>[];
  final invalid = <String>[];

  for (final entry in _required.entries) {
    final os = entry.key;
    for (final arch in entry.value) {
      final dir = Directory('${root.path}/$os/$arch');
      if (!dir.existsSync()) {
        missing.add('$os/$arch');
        continue;
      }

      final files = <String>[];
      await for (final entity in dir.list()) {
        if (entity is! File) {
          continue;
        }
        if (entity.uri.pathSegments.isEmpty) {
          continue;
        }
        files.add(entity.uri.pathSegments.last);
      }

      if (files.isEmpty) {
        invalid.add('$os/$arch (empty)');
        continue;
      }

      for (final fileName in files) {
        if (!_allowedLibNames.contains(fileName)) {
          invalid.add('$os/$arch/$fileName');
        }
      }
    }
  }

  if (missing.isNotEmpty || invalid.isNotEmpty) {
    stderr.writeln('Native platform coverage verification failed.');
    if (missing.isNotEmpty) {
      stderr.writeln('Missing directories: ${missing.join(', ')}');
    }
    if (invalid.isNotEmpty) {
      stderr.writeln('Invalid entries: ${invalid.join(', ')}');
    }
    exitCode = 1;
    return;
  }

  stdout.writeln('Native platform coverage verification succeeded.');
}
