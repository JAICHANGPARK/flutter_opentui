import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:test/test.dart';

final RegExp _linePattern = RegExp(r'^([a-fA-F0-9]{64})\s{2}(.+)$');

void main() {
  test('checksum manifest entries exist and match sha256', () {
    final manifest = File('native/checksums.sha256');
    expect(manifest.existsSync(), isTrue);

    final lines = manifest
        .readAsLinesSync()
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    expect(lines, isNotEmpty);

    for (final line in lines) {
      final match = _linePattern.firstMatch(line);
      expect(match, isNotNull, reason: 'invalid checksum line: $line');

      final expected = match!.group(1)!.toLowerCase();
      final relativePath = match.group(2)!;
      final file = File('native/$relativePath');
      expect(file.existsSync(), isTrue, reason: 'missing file: ${file.path}');

      final actual = sha256.convert(file.readAsBytesSync()).toString();
      expect(
        actual,
        equals(expected),
        reason: 'hash mismatch for $relativePath',
      );
    }
  });
}
