import 'package:opentui_native/opentui_native.dart';
import 'package:test/test.dart';

void main() {
  test('auto load tolerates missing binaries', () {
    final library = OpenTuiNativeLibrary.auto(
      overridePath: '/tmp/does-not-exist/libopentui_native.so',
    );

    expect(library.isLoaded, isFalse);
    expect(library.info.libraryPath, isNull);
  });
}
