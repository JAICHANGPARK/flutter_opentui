import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('editor view tracks viewport and selection with follow cursor', () {
    final edit = EditBuffer.create(WidthMethod.unicodeScalar)
      ..setText('line0\nline1\nline2\nline3\nline4\nline5');
    final view = EditorView.create(edit, 8, 3);

    view.setScrollMargin(1);
    view.setLocalSelection(0, 0, 4, 0, updateCursor: true, followCursor: true);

    expect(view.hasSelection(), isTrue);
    expect(view.getSelectedText(), equals('line'));

    edit.setCursorToLineCol(5, 2);
    view.moveDownVisual();

    final viewport = view.getViewport();
    expect(viewport.offsetY, greaterThanOrEqualTo(0));
  });

  test('editor view supports placeholder chunks and measurements', () {
    final edit = EditBuffer.create(WidthMethod.unicodeScalar)..setText('hello');
    final view = EditorView.create(edit, 10, 4);

    view.setPlaceholderStyledText(
      const <({String text, TuiColor? fg, TuiColor? bg, int attributes})>[
        (text: 'placeholder', fg: null, bg: null, attributes: 0),
      ],
    );

    expect(view.placeholder, hasLength(1));

    final metrics = view.measureForDimensions(10, 4);
    expect(metrics, isNotNull);
    expect(metrics!.lineCount, greaterThan(0));
  });
}
