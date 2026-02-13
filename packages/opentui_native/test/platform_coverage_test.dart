import 'dart:io';

import 'package:test/test.dart';

const Map<String, List<String>> _required = <String, List<String>>{
  'macos': <String>['arm64', 'x64'],
  'linux': <String>['arm64', 'x64'],
  'windows': <String>['x64'],
  'android': <String>['arm64'],
  'ios': <String>['arm64'],
};

void main() {
  test('native platform coverage directory layout exists', () {
    for (final entry in _required.entries) {
      for (final arch in entry.value) {
        final dir = Directory('native/${entry.key}/$arch');
        expect(dir.existsSync(), isTrue, reason: 'missing ${dir.path}');
      }
    }
  });
}
