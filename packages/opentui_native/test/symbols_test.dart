import 'package:opentui_native/raw.dart';
import 'package:test/test.dart';

void main() {
  test('symbol list is unique and signature map covers all symbols', () {
    expect(OpenTuiNativeSymbols.all.length, OpenTuiNativeSymbols.allSet.length);

    final missing = OpenTuiNativeSymbols.allSet
        .where((s) => !OpenTuiRawSymbolTable.signatures.containsKey(s))
        .toList();
    expect(missing, isEmpty);
  });
}
