import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('text buffer supports set/append/range/highlights', () {
    final buffer = TextBuffer.create(WidthMethod.unicodeScalar);
    buffer.setText('hello');
    buffer.append('\nworld');

    expect(buffer.getLineCount(), equals(2));
    expect(buffer.length, equals(11));
    expect(buffer.getTextRange(0, 5), equals('hello'));

    buffer.addHighlight(0, const Highlight(start: 0, end: 5));
    buffer.addHighlightByCharRange(const Highlight(start: 0, end: 11));

    expect(buffer.getHighlightCount(), equals(2));
    expect(buffer.getLineHighlights(0), hasLength(1));

    buffer.clearAllHighlights();
    expect(buffer.getHighlightCount(), equals(0));
  });

  test('text buffer view supports selection and wrap metrics', () {
    final buffer = TextBuffer.create(WidthMethod.unicodeScalar)
      ..setText('one two three four');
    final view = TextBufferView.create(buffer);

    view.setWrapMode(WrapMode.word);
    view.setWrapWidth(6);
    expect(view.getVirtualLineCount(), greaterThan(1));

    view.setSelection(0, 3);
    expect(view.getSelectedText(), equals('one'));

    final metrics = view.measureForDimensions(10, 4);
    expect(metrics, isNotNull);
    expect(metrics!.lineCount, greaterThan(0));
  });
}
