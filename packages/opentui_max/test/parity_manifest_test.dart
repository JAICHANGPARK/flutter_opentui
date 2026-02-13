import 'dart:io';

import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('parity manifest has full tracked coverage and required namespaces', () {
    final file = File('tool/parity_manifest.yaml');
    expect(file.existsSync(), isTrue);

    final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
    final exports = yaml['exports'] as YamlMap;
    expect(exports.containsKey('core'), isTrue);
    expect(exports.containsKey('react'), isTrue);
    expect(exports.containsKey('solid'), isTrue);
    expect(exports.containsKey('web'), isTrue);

    final coverage = yaml['coverage'] as YamlMap;
    expect(coverage['tracked'], equals(coverage['total']));
    expect(coverage['percent'], equals(100));
  });
}
