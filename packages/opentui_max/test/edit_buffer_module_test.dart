import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('edit buffer supports cursor movement editing undo redo', () {
    final edit = EditBuffer.create(WidthMethod.unicodeScalar);

    edit.setText('abc');
    edit.setCursorByOffset(3);
    edit.insertChar('d');

    expect(edit.getText(), equals('abcd'));

    edit.deleteCharBackward();
    expect(edit.getText(), equals('abc'));

    edit.undo();
    expect(edit.getText(), equals('abcd'));

    edit.redo();
    expect(edit.getText(), equals('abc'));

    edit.gotoLine(0);
    edit.newLine();
    expect(edit.getLineCount(), equals(2));

    final eol = edit.getEOL();
    expect(eol.row, equals(edit.getCursorPosition().row));
  });

  test('edit buffer range APIs operate by offsets and coordinates', () {
    final edit = EditBuffer.create(WidthMethod.unicodeScalar)
      ..setText('aa\nbb\ncc');

    final range = edit.getTextRangeByCoords(0, 0, 1, 2);
    expect(range, equals('aa\nbb'));

    final offset = edit.positionToOffset(1, 1);
    final position = edit.offsetToPosition(offset);
    expect(position, isNotNull);
    expect(position!.row, equals(1));
    expect(position.col, equals(1));
  });
}
