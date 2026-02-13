import 'package:opentui_native/opentui_native.dart';
import 'package:test/test.dart';

void main() {
  test('locator returns deterministic candidate paths', () {
    final candidates = OpenTuiNativeLibraryLocator.candidatePaths(
      baseDir: '/tmp/opentui_native_test',
    );

    expect(candidates, isNotEmpty);
    expect(candidates.first, contains('/tmp/opentui_native_test/native/'));
  });
}
