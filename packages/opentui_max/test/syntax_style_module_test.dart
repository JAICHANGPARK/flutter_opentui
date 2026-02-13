import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('syntax style registers styles and resolves merged attributes', () {
    final style = SyntaxStyle.create();
    style.registerStyle(
      'keyword',
      const StyleDefinition(fg: TuiColor.cyan, bold: true),
    );
    style.registerStyle(
      'keyword.control',
      const StyleDefinition(bg: TuiColor.black, underline: true),
    );

    final merged = style.mergeStyles(const <String>[
      'keyword',
      'keyword.control',
    ]);

    expect(style.getStyleCount(), equals(2));
    expect(style.getStyleId('keyword.control'), isNotNull);
    expect(merged.fg, equals(TuiColor.cyan));
    expect(merged.bg, equals(TuiColor.black));
    expect(merged.attributes, isNonZero);
  });
}
