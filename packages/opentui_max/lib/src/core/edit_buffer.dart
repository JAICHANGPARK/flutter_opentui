import 'syntax_style.dart';
import 'text_buffer.dart';
import 'types.dart';
import 'utils.dart';

typedef EditBufferListener = void Function(String eventName);

final class EditBufferState {
  const EditBufferState({required this.text, required this.cursor});

  final String text;
  final LogicalCursor cursor;
}

final class EditBuffer {
  EditBuffer._({required this.widthMethod})
    : textBuffer = TextBuffer.create(widthMethod),
      id = _nextId++;

  factory EditBuffer.create(WidthMethod widthMethod) {
    return EditBuffer._(widthMethod: widthMethod);
  }

  static int _nextId = 1;

  final WidthMethod widthMethod;
  final int id;
  final TextBuffer textBuffer;

  bool _destroyed = false;
  LogicalCursor _cursor = const LogicalCursor(row: 0, col: 0, offset: 0);

  final List<EditBufferState> _undoStack = <EditBufferState>[];
  final List<EditBufferState> _redoStack = <EditBufferState>[];
  final Set<EditBufferListener> _listeners = <EditBufferListener>{};

  void _guard() {
    if (_destroyed) {
      throw StateError('EditBuffer is destroyed');
    }
  }

  void addListener(EditBufferListener listener) {
    _listeners.add(listener);
  }

  void removeListener(EditBufferListener listener) {
    _listeners.remove(listener);
  }

  void _emit(String eventName) {
    for (final listener in _listeners.toList(growable: false)) {
      listener(eventName);
    }
  }

  String getText() {
    _guard();
    return textBuffer.getPlainText();
  }

  void setText(String text) {
    _guard();
    textBuffer.setText(text);
    _cursor = _cursorFromOffset(0);
    _undoStack.clear();
    _redoStack.clear();
    _emit('text_changed');
  }

  void setTextOwned(String text) => setText(text);

  void replaceText(String text) {
    _guard();
    _pushUndo();
    textBuffer.setText(text);
    _cursor = _cursorFromOffset(0);
    _redoStack.clear();
    _emit('text_replaced');
  }

  void replaceTextOwned(String text) => replaceText(text);

  int getLineCount() {
    _guard();
    return textBuffer.getLineCount();
  }

  void insertChar(String char) {
    insertText(char);
  }

  void insertText(String text) {
    _guard();
    if (text.isEmpty) {
      return;
    }
    _pushUndo();
    final current = getText();
    final next = current.replaceRange(_cursor.offset, _cursor.offset, text);
    textBuffer.setText(next);
    _cursor = _cursorFromOffset(_cursor.offset + text.runes.length);
    _redoStack.clear();
    _emit('insert');
  }

  void deleteChar() {
    _guard();
    final current = getText();
    if (_cursor.offset >= current.runes.length) {
      return;
    }
    _pushUndo();
    final runes = current.runes.toList(growable: true);
    runes.removeAt(_cursor.offset);
    textBuffer.setText(String.fromCharCodes(runes));
    _redoStack.clear();
    _emit('delete');
  }

  void deleteCharBackward() {
    _guard();
    if (_cursor.offset <= 0) {
      return;
    }
    _pushUndo();
    final current = getText();
    final runes = current.runes.toList(growable: true);
    runes.removeAt(_cursor.offset - 1);
    textBuffer.setText(String.fromCharCodes(runes));
    _cursor = _cursorFromOffset(_cursor.offset - 1);
    _redoStack.clear();
    _emit('backspace');
  }

  void deleteRange(int startLine, int startCol, int endLine, int endCol) {
    _guard();
    final start = positionToOffset(startLine, startCol);
    final end = positionToOffset(endLine, endCol);
    if (start >= end) {
      return;
    }
    _pushUndo();
    final text = getText();
    final runes = text.runes.toList(growable: false);
    final next = <int>[...runes.sublist(0, start), ...runes.sublist(end)];
    textBuffer.setText(String.fromCharCodes(next));
    _cursor = _cursorFromOffset(start);
    _redoStack.clear();
    _emit('range_delete');
  }

  void newLine() {
    insertText('\n');
  }

  void deleteLine() {
    _guard();
    final lines = splitLines(getText());
    if (lines.isEmpty) {
      return;
    }
    final row = clampInt(_cursor.row, 0, lines.length - 1);
    _pushUndo();
    lines.removeAt(row);
    textBuffer.setText(lines.join('\n'));
    final nextRow = row >= lines.length ? lines.length - 1 : row;
    _cursor = _cursorFromPosition(nextRow < 0 ? 0 : nextRow, 0);
    _redoStack.clear();
    _emit('line_delete');
  }

  void moveCursorLeft() {
    _guard();
    if (_cursor.offset <= 0) {
      return;
    }
    _cursor = _cursorFromOffset(_cursor.offset - 1);
    _emit('cursor_move');
  }

  void moveCursorRight() {
    _guard();
    if (_cursor.offset >= getText().runes.length) {
      return;
    }
    _cursor = _cursorFromOffset(_cursor.offset + 1);
    _emit('cursor_move');
  }

  void moveCursorUp() {
    _guard();
    final row = _cursor.row <= 0 ? 0 : _cursor.row - 1;
    _cursor = _cursorFromPosition(row, _cursor.col);
    _emit('cursor_move');
  }

  void moveCursorDown() {
    _guard();
    final maxRow = splitLines(getText()).length - 1;
    final row = _cursor.row >= maxRow ? maxRow : _cursor.row + 1;
    _cursor = _cursorFromPosition(row, _cursor.col);
    _emit('cursor_move');
  }

  void gotoLine(int line) {
    _guard();
    _cursor = _cursorFromPosition(line, 0);
    _emit('cursor_move');
  }

  void setCursor(int line, int col) => setCursorToLineCol(line, col);

  void setCursorToLineCol(int line, int col) {
    _guard();
    _cursor = _cursorFromPosition(line, col);
    _emit('cursor_move');
  }

  void setCursorByOffset(int offset) {
    _guard();
    _cursor = _cursorFromOffset(offset);
    _emit('cursor_move');
  }

  LogicalCursor getCursorPosition() {
    _guard();
    return _cursor;
  }

  LogicalCursor getNextWordBoundary() {
    _guard();
    final text = getText();
    final runes = text.runes.toList(growable: false);
    var i = _cursor.offset;
    while (i < runes.length &&
        String.fromCharCode(runes[i]).trim().isNotEmpty) {
      i++;
    }
    while (i < runes.length && String.fromCharCode(runes[i]).trim().isEmpty) {
      i++;
    }
    return _cursorFromOffset(i);
  }

  LogicalCursor getPrevWordBoundary() {
    _guard();
    final text = getText();
    final runes = text.runes.toList(growable: false);
    var i = _cursor.offset - 1;
    while (i >= 0 && String.fromCharCode(runes[i]).trim().isEmpty) {
      i--;
    }
    while (i >= 0 && String.fromCharCode(runes[i]).trim().isNotEmpty) {
      i--;
    }
    return _cursorFromOffset(i + 1);
  }

  LogicalCursor getEOL() {
    _guard();
    final lines = splitLines(getText());
    if (lines.isEmpty) {
      return const LogicalCursor(row: 0, col: 0, offset: 0);
    }
    final row = clampInt(_cursor.row, 0, lines.length - 1);
    return _cursorFromPosition(row, lines[row].length);
  }

  ({int row, int col})? offsetToPosition(int offset) {
    _guard();
    final cursor = _cursorFromOffset(offset);
    return (row: cursor.row, col: cursor.col);
  }

  int positionToOffset(int row, int col) {
    _guard();
    return _cursorFromPosition(row, col).offset;
  }

  int getLineStartOffset(int row) {
    _guard();
    return _cursorFromPosition(row, 0).offset;
  }

  String getTextRange(int startOffset, int endOffset) {
    _guard();
    return textBuffer.getTextRange(startOffset, endOffset);
  }

  String getTextRangeByCoords(
    int startRow,
    int startCol,
    int endRow,
    int endCol,
  ) {
    _guard();
    return getTextRange(
      positionToOffset(startRow, startCol),
      positionToOffset(endRow, endCol),
    );
  }

  void setSyntaxStyle(SyntaxStyle? style) {
    _guard();
    textBuffer.setSyntaxStyle(style);
  }

  void addHighlightByCharRange(Highlight highlight) {
    _guard();
    textBuffer.addHighlightByCharRange(highlight);
  }

  void addHighlight(int lineIdx, Highlight highlight) {
    _guard();
    textBuffer.addHighlight(lineIdx, highlight);
  }

  void clearAllHighlights() {
    _guard();
    textBuffer.clearAllHighlights();
  }

  bool canUndo() {
    _guard();
    return _undoStack.isNotEmpty;
  }

  bool canRedo() {
    _guard();
    return _redoStack.isNotEmpty;
  }

  void clearHistory() {
    _guard();
    _undoStack.clear();
    _redoStack.clear();
  }

  void undo() {
    _guard();
    if (_undoStack.isEmpty) {
      return;
    }
    _redoStack.add(_snapshot());
    final state = _undoStack.removeLast();
    _applyState(state);
    _emit('undo');
  }

  void redo() {
    _guard();
    if (_redoStack.isEmpty) {
      return;
    }
    _undoStack.add(_snapshot());
    final state = _redoStack.removeLast();
    _applyState(state);
    _emit('redo');
  }

  void clear() {
    _guard();
    textBuffer.clear();
    _cursor = const LogicalCursor(row: 0, col: 0, offset: 0);
    _undoStack.clear();
    _redoStack.clear();
  }

  void destroy() {
    if (_destroyed) {
      return;
    }
    _destroyed = true;
    _listeners.clear();
    textBuffer.destroy();
    _undoStack.clear();
    _redoStack.clear();
  }

  void _pushUndo() {
    _undoStack.add(_snapshot());
    if (_undoStack.length > 100) {
      _undoStack.removeAt(0);
    }
  }

  EditBufferState _snapshot() {
    return EditBufferState(text: getText(), cursor: _cursor);
  }

  void _applyState(EditBufferState state) {
    textBuffer.setText(state.text);
    _cursor = state.cursor;
  }

  LogicalCursor _cursorFromOffset(int offset) {
    final text = getText();
    final runes = text.runes.toList(growable: false);
    final safeOffset = clampInt(offset, 0, runes.length);

    var row = 0;
    var col = 0;
    for (var i = 0; i < safeOffset; i++) {
      if (runes[i] == 10) {
        row += 1;
        col = 0;
      } else {
        col += 1;
      }
    }

    return LogicalCursor(row: row, col: col, offset: safeOffset);
  }

  LogicalCursor _cursorFromPosition(int row, int col) {
    final lines = splitLines(getText());
    if (lines.isEmpty) {
      return const LogicalCursor(row: 0, col: 0, offset: 0);
    }

    final safeRow = clampInt(row, 0, lines.length - 1);
    final safeCol = clampInt(col, 0, lines[safeRow].length);

    var offset = 0;
    for (var i = 0; i < safeRow; i++) {
      offset += lines[i].length + 1;
    }
    offset += safeCol;

    return LogicalCursor(row: safeRow, col: safeCol, offset: offset);
  }
}
