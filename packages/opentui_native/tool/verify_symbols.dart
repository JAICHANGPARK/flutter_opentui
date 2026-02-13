import 'dart:io';

import 'package:opentui_native/raw.dart';

final RegExp _exportFn = RegExp(r'^export fn\s+([A-Za-z0-9_]+)');
final RegExp _pubExportFn = RegExp(r'^pub export fn\s+([A-Za-z0-9_]+)');

Future<void> main() async {
  final packageRoot = Directory.current.path;
  final refRoot = '$packageRoot/../../ref/opentui/packages/core/src/zig';

  final files = <File>[
    File('$refRoot/lib.zig'),
    File('$refRoot/native-span-feed.zig'),
  ];

  final missingFiles = files
      .where((f) => !f.existsSync())
      .toList(growable: false);
  if (missingFiles.isNotEmpty) {
    stderr.writeln(
      'Missing upstream files: ${missingFiles.map((f) => f.path).join(', ')}',
    );
    exitCode = 1;
    return;
  }

  final upstream = <String>{};

  for (final file in files) {
    final lines = await file.readAsLines();
    for (final line in lines) {
      final match = _exportFn.firstMatch(line) ?? _pubExportFn.firstMatch(line);
      if (match != null) {
        upstream.add(match.group(1)!);
      }
    }
  }

  final local = OpenTuiNativeSymbols.allSet;

  final missing = (upstream.difference(local).toList()..sort());
  final extra = (local.difference(upstream).toList()..sort());

  if (missing.isNotEmpty || extra.isNotEmpty) {
    stderr.writeln('Symbol mismatch detected.');
    if (missing.isNotEmpty) {
      stderr.writeln('Missing (${missing.length}): ${missing.join(', ')}');
    }
    if (extra.isNotEmpty) {
      stderr.writeln('Extra (${extra.length}): ${extra.join(', ')}');
    }
    exitCode = 1;
    return;
  }

  final withoutSignature = local
      .where((symbol) => !OpenTuiRawSymbolTable.signatures.containsKey(symbol))
      .toList(growable: false);

  if (withoutSignature.isNotEmpty) {
    stderr.writeln(
      'Missing signature metadata: ${withoutSignature.join(', ')}',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'Symbol verification succeeded. Total symbols: ${local.length}',
  );
}
