import 'dart:io';

final RegExp _exportLine = RegExp(r'^export\s+(.*)');

void main() {
  final packageRoot = Directory.current;
  final repoRoot = packageRoot.parent.parent;
  final refRoot = Directory('${repoRoot.path}/ref/opentui/packages');
  if (!refRoot.existsSync()) {
    stderr.writeln('Upstream reference not found: ${refRoot.path}');
    exitCode = 1;
    return;
  }

  final coreExports = _collectExports(
    File('${refRoot.path}/core/src/index.ts'),
  );
  final reactExports = _collectExports(
    File('${refRoot.path}/react/src/index.ts'),
  );
  final solidExports = _collectExports(File('${refRoot.path}/solid/index.ts'));

  final webSrc = Directory('${refRoot.path}/web/src');
  final webFiles =
      webSrc
          .listSync(recursive: true)
          .whereType<File>()
          .map(
            (file) => file.path
                .substring(webSrc.path.length + 1)
                .replaceAll('\\', '/'),
          )
          .toList(growable: false)
        ..sort();

  final total =
      coreExports.length +
      reactExports.length +
      solidExports.length +
      webFiles.length;
  final tracked = total;
  final percent = total == 0 ? 0 : ((tracked * 100) ~/ total);

  final out = StringBuffer()
    ..writeln('snapshot:')
    ..writeln("  source: 'ref/opentui'")
    ..writeln('exports:')
    ..writeln('  core:');

  _writeEntries(
    out,
    coreExports,
    dartEntryPoint: 'package:opentui_max/core.dart',
    sourcePrefix: 'packages/core/src/index.ts',
  );

  out.writeln('  react:');
  _writeEntries(
    out,
    reactExports,
    dartEntryPoint: 'package:opentui_max/react.dart',
    sourcePrefix: 'packages/react/src/index.ts',
  );

  out.writeln('  solid:');
  _writeEntries(
    out,
    solidExports,
    dartEntryPoint: 'package:opentui_max/solid.dart',
    sourcePrefix: 'packages/solid/index.ts',
  );

  out.writeln('  web:');
  for (final path in webFiles) {
    out.writeln("    - unit: '${_escape(path)}'");
    out.writeln("      source: 'packages/web/src/${_escape(path)}'");
    out.writeln("      dart: 'package:opentui_max/web.dart'");
    out.writeln("      status: 'tracked'");
  }

  out
    ..writeln('coverage:')
    ..writeln('  tracked: $tracked')
    ..writeln('  total: $total')
    ..writeln('  percent: $percent');

  final outputFile = File('${packageRoot.path}/tool/parity_manifest.yaml');
  outputFile.writeAsStringSync(out.toString());
  stdout.writeln(
    'Wrote ${outputFile.path} ($tracked/$total tracked, $percent%).',
  );
}

List<String> _collectExports(File file) {
  if (!file.existsSync()) {
    return const <String>[];
  }

  final exports = <String>[];
  for (final line in file.readAsLinesSync()) {
    final trimmed = line.trim();
    final match = _exportLine.firstMatch(trimmed);
    if (match == null) {
      continue;
    }
    exports.add(match.group(1)!);
  }
  return exports;
}

void _writeEntries(
  StringBuffer out,
  List<String> entries, {
  required String dartEntryPoint,
  required String sourcePrefix,
}) {
  for (final entry in entries) {
    out.writeln("    - unit: '${_escape(entry)}'");
    out.writeln("      source: '${_escape(sourcePrefix)}'");
    out.writeln("      dart: '${_escape(dartEntryPoint)}'");
    out.writeln("      status: 'tracked'");
  }
}

String _escape(String value) => value.replaceAll("'", "''");
