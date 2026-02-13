import 'edit_buffer.dart';
import 'frame.dart';
import 'text_buffer_view.dart';
import 'types.dart';

final class Viewport {
  const Viewport({
    required this.offsetY,
    required this.offsetX,
    required this.height,
    required this.width,
  });

  final int offsetY;
  final int offsetX;
  final int height;
  final int width;
}

final class EditorView {
  EditorView._({
    required this.editBuffer,
    required int viewportWidth,
    required int viewportHeight,
  }) : _textView = TextBufferView.create(editBuffer.textBuffer),
       _viewportWidth = viewportWidth,
       _viewportHeight = viewportHeight {
    _textView.setViewport(0, 0, viewportWidth, viewportHeight);
  }

  factory EditorView.create(
    EditBuffer editBuffer,
    int viewportWidth,
    int viewportHeight,
  ) {
    return EditorView._(
      editBuffer: editBuffer,
      viewportWidth: viewportWidth,
      viewportHeight: viewportHeight,
    );
  }

  final EditBuffer editBuffer;
  final TextBufferView _textView;
  bool _destroyed = false;

  int _viewportX = 0;
  int _viewportY = 0;
  int _viewportWidth;
  int _viewportHeight;
  double _scrollMargin = 0;

  List<({String text, TuiColor? fg, TuiColor? bg, int attributes})>
  _placeholder =
      const <({String text, TuiColor? fg, TuiColor? bg, int attributes})>[];

  void _guard() {
    if (_destroyed) {
      throw StateError('EditorView is destroyed');
    }
  }

  void setViewportSize(int width, int height) {
    _guard();
    _viewportWidth = width < 0 ? 0 : width;
    _viewportHeight = height < 0 ? 0 : height;
    _textView.setViewportSize(_viewportWidth, _viewportHeight);
  }

  void setViewport(
    int x,
    int y,
    int width,
    int height, {
    bool moveCursor = true,
  }) {
    _guard();
    _viewportX = x;
    _viewportY = y;
    setViewportSize(width, height);

    if (moveCursor) {
      editBuffer.setCursorToLineCol(_viewportY, _viewportX);
    }
  }

  Viewport getViewport() {
    _guard();
    return Viewport(
      offsetY: _viewportY,
      offsetX: _viewportX,
      height: _viewportHeight,
      width: _viewportWidth,
    );
  }

  void setScrollMargin(double margin) {
    _guard();
    _scrollMargin = margin;
  }

  void setWrapMode(WrapMode mode) {
    _guard();
    _textView.setWrapMode(mode);
  }

  int getVirtualLineCount() {
    _guard();
    return _textView.getVirtualLineCount();
  }

  int getTotalVirtualLineCount() {
    _guard();
    return _textView.getVirtualLineCount();
  }

  void setSelection(
    int start,
    int end, {
    TuiColor? bgColor,
    TuiColor? fgColor,
  }) {
    _guard();
    _textView.setSelection(start, end, bgColor: bgColor, fgColor: fgColor);
  }

  void updateSelection(int end, {TuiColor? bgColor, TuiColor? fgColor}) {
    _guard();
    _textView.updateSelection(end, bgColor: bgColor, fgColor: fgColor);
  }

  void resetSelection() {
    _guard();
    _textView.resetSelection();
  }

  ({int start, int end})? getSelection() {
    _guard();
    return _textView.getSelection();
  }

  bool hasSelection() {
    _guard();
    return _textView.hasSelection();
  }

  bool setLocalSelection(
    int anchorX,
    int anchorY,
    int focusX,
    int focusY, {
    TuiColor? bgColor,
    TuiColor? fgColor,
    bool updateCursor = false,
    bool followCursor = false,
  }) {
    _guard();
    final ok = _textView.setLocalSelection(
      anchorX,
      anchorY,
      focusX,
      focusY,
      bgColor: bgColor,
      fgColor: fgColor,
    );
    if (ok && updateCursor) {
      editBuffer.setCursorToLineCol(focusY, focusX);
    }
    if (ok && followCursor) {
      _followCursor();
    }
    return ok;
  }

  bool updateLocalSelection(
    int anchorX,
    int anchorY,
    int focusX,
    int focusY, {
    TuiColor? bgColor,
    TuiColor? fgColor,
    bool updateCursor = false,
    bool followCursor = false,
  }) {
    _guard();
    final ok = _textView.updateLocalSelection(
      anchorX,
      anchorY,
      focusX,
      focusY,
      bgColor: bgColor,
      fgColor: fgColor,
    );
    if (ok && updateCursor) {
      editBuffer.setCursorToLineCol(focusY, focusX);
    }
    if (ok && followCursor) {
      _followCursor();
    }
    return ok;
  }

  void resetLocalSelection() {
    _guard();
    _textView.resetLocalSelection();
  }

  String getSelectedText() {
    _guard();
    return _textView.getSelectedText();
  }

  ({int row, int col}) getCursor() {
    _guard();
    final cursor = editBuffer.getCursorPosition();
    return (row: cursor.row, col: cursor.col);
  }

  String getText() {
    _guard();
    return editBuffer.getText();
  }

  VisualCursor getVisualCursor() {
    _guard();
    final cursor = editBuffer.getCursorPosition();
    return VisualCursor(
      row: cursor.row - _viewportY,
      col: cursor.col - _viewportX,
    );
  }

  void moveUpVisual() {
    _guard();
    editBuffer.moveCursorUp();
    _followCursor();
  }

  void moveDownVisual() {
    _guard();
    editBuffer.moveCursorDown();
    _followCursor();
  }

  void deleteSelectedText() {
    _guard();
    final selection = _textView.getSelection();
    if (selection == null) {
      return;
    }
    final startPos = editBuffer.offsetToPosition(selection.start);
    final endPos = editBuffer.offsetToPosition(selection.end);
    if (startPos == null || endPos == null) {
      return;
    }
    editBuffer.deleteRange(startPos.row, startPos.col, endPos.row, endPos.col);
    _textView.resetSelection();
  }

  void setCursorByOffset(int offset) {
    _guard();
    editBuffer.setCursorByOffset(offset);
    _followCursor();
  }

  VisualCursor getNextWordBoundary() {
    _guard();
    final boundary = editBuffer.getNextWordBoundary();
    return VisualCursor(row: boundary.row, col: boundary.col);
  }

  VisualCursor getPrevWordBoundary() {
    _guard();
    final boundary = editBuffer.getPrevWordBoundary();
    return VisualCursor(row: boundary.row, col: boundary.col);
  }

  VisualCursor getEOL() {
    _guard();
    final boundary = editBuffer.getEOL();
    return VisualCursor(row: boundary.row, col: boundary.col);
  }

  VisualCursor getVisualSOL() {
    _guard();
    final cursor = editBuffer.getCursorPosition();
    return VisualCursor(row: cursor.row, col: 0);
  }

  VisualCursor getVisualEOL() {
    _guard();
    final eol = editBuffer.getEOL();
    return VisualCursor(row: eol.row, col: eol.col);
  }

  LineInfo getLineInfo() {
    _guard();
    return _textView.lineInfo;
  }

  LineInfo getLogicalLineInfo() {
    _guard();
    return _textView.logicalLineInfo;
  }

  void setPlaceholderStyledText(
    List<({String text, TuiColor? fg, TuiColor? bg, int attributes})> chunks,
  ) {
    _guard();
    _placeholder = chunks;
  }

  void setTabIndicator(String indicator) {
    _guard();
    _textView.setTabIndicator(indicator);
  }

  void setTabIndicatorCodePoint(int indicator) {
    _guard();
    _textView.setTabIndicatorCodePoint(indicator);
  }

  void setTabIndicatorColor(TuiColor color) {
    _guard();
    _textView.setTabIndicatorColor(color);
  }

  ({int lineCount, int maxWidth})? measureForDimensions(int width, int height) {
    _guard();
    return _textView.measureForDimensions(width, height);
  }

  List<({String text, TuiColor? fg, TuiColor? bg, int attributes})>
  get placeholder =>
      List<({String text, TuiColor? fg, TuiColor? bg, int attributes})>.from(
        _placeholder,
      );

  double get scrollMargin => _scrollMargin;

  void destroy() {
    if (_destroyed) {
      return;
    }
    _destroyed = true;
    _textView.destroy();
  }

  void _followCursor() {
    final cursor = editBuffer.getCursorPosition();
    final margin = _scrollMargin.floor();

    final minY = _viewportY + margin;
    final maxY = _viewportY + _viewportHeight - 1 - margin;
    if (cursor.row < minY) {
      _viewportY = cursor.row - margin;
    } else if (cursor.row > maxY) {
      _viewportY = cursor.row - (_viewportHeight - 1 - margin);
    }
    if (_viewportY < 0) {
      _viewportY = 0;
    }

    final minX = _viewportX + margin;
    final maxX = _viewportX + _viewportWidth - 1 - margin;
    if (cursor.col < minX) {
      _viewportX = cursor.col - margin;
    } else if (cursor.col > maxX) {
      _viewportX = cursor.col - (_viewportWidth - 1 - margin);
    }
    if (_viewportX < 0) {
      _viewportX = 0;
    }
  }
}
