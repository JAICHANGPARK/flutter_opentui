import 'dart:io';

import 'package:crypto/crypto.dart';

final RegExp _linePattern = RegExp(r'^([a-fA-F0-9]{64})\s{2}(.+)$');

Future<void> main() async {
  final manifest = File('native/checksums.sha256');
  if (!manifest.existsSync()) {
    stderr.writeln('Missing checksum manifest: ${manifest.path}');
    exitCode = 1;
    return;
  }

  final entries = manifest
      .readAsLinesSync()
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  if (entries.isEmpty) {
    stderr.writeln('Checksum manifest is empty.');
    exitCode = 1;
    return;
  }

  var verified = 0;
  for (final line in entries) {
    final match = _linePattern.firstMatch(line);
    if (match == null) {
      stderr.writeln('Invalid checksum line: $line');
      exitCode = 1;
      return;
    }

    final expected = match.group(1)!.toLowerCase();
    final relativePath = match.group(2)!;
    final file = File('native/$relativePath');
    if (!file.existsSync()) {
      stderr.writeln('Missing artifact: ${file.path}');
      exitCode = 1;
      return;
    }

    final digest = sha256.convert(await file.readAsBytes()).toString();
    if (digest != expected) {
      stderr.writeln('Checksum mismatch: $relativePath');
      stderr.writeln('  expected: $expected');
      stderr.writeln('  actual:   $digest');
      exitCode = 1;
      return;
    }

    verified += 1;
  }

  stdout.writeln('Checksum verification succeeded for $verified artifacts.');
}
