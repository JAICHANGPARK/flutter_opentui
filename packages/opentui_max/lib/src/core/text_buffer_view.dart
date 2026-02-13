import 'frame.dart';
import 'text_buffer.dart';
import 'types.dart';
import 'utils.dart';

final class TextBufferView {
  TextBufferView._(this.textBuffer);

  factory TextBufferView.create(TextBuffer textBuffer) {
    return TextBufferView._(textBuffer);
  }

  final TextBuffer textBuffer;
  bool _destroyed = false;

  int? _selectionStart;
  int? _selectionEnd;

  int _viewportX = 0;
  int _viewportY = 0;
  int _viewportWidth = 80;
  int _viewportHeight = 24;

  int _wrapWidth = 0;
  WrapMode _wrapMode = WrapMode.none;

  int _tabIndicator = '>'.codeUnitAt(0);
  TuiColor _tabIndicatorColor = TuiColor.cyan;
  bool _truncate = false;

  void _guard() {
    if (_destroyed) {
      throw StateError('TextBufferView is destroyed');
    }
  }

  void setSelection(
    int start,
    int end, {
    TuiColor? bgColor,
    TuiColor? fgColor,
  }) {
    _guard();
    _selectionStart = start;
    _selectionEnd = end;
  }

  void updateSelection(int end, {TuiColor? bgColor, TuiColor? fgColor}) {
    _guard();
    _selectionStart ??= 0;
    _selectionEnd = end;
  }

  void resetSelection() {
    _guard();
    _selectionStart = null;
    _selectionEnd = null;
  }

  ({int start, int end})? getSelection() {
    _guard();
    final start = _selectionStart;
    final end = _selectionEnd;
    if (start == null || end == null) {
      return null;
    }
    if (start <= end) {
      return (start: start, end: end);
    }
    return (start: end, end: start);
  }

  bool hasSelection() {
    _guard();
    return getSelection() != null;
  }

  bool setLocalSelection(
    int anchorX,
    int anchorY,
    int focusX,
    int focusY, {
    TuiColor? bgColor,
    TuiColor? fgColor,
  }) {
    _guard();
    final start = _lineColToOffset(anchorY, anchorX);
    final end = _lineColToOffset(focusY, focusX);
    setSelection(start, end);
    return true;
  }

  bool updateLocalSelection(
    int anchorX,
    int anchorY,
    int focusX,
    int focusY, {
    TuiColor? bgColor,
    TuiColor? fgColor,
  }) {
    _guard();
    final start = _lineColToOffset(anchorY, anchorX);
    final end = _lineColToOffset(focusY, focusX);
    _selectionStart = start;
    _selectionEnd = end;
    return true;
  }

  void resetLocalSelection() {
    resetSelection();
  }

  void setWrapWidth(int? width) {
    _guard();
    _wrapWidth = width == null ? 0 : (width < 0 ? 0 : width);
  }

  void setWrapMode(WrapMode mode) {
    _guard();
    _wrapMode = mode;
  }

  void setViewportSize(int width, int height) {
    _guard();
    _viewportWidth = width < 0 ? 0 : width;
    _viewportHeight = height < 0 ? 0 : height;
  }

  void setViewport(int x, int y, int width, int height) {
    _guard();
    _viewportX = x;
    _viewportY = y;
    setViewportSize(width, height);
  }

  LineInfo get lineInfo {
    _guard();
    final lines = splitLines(textBuffer.getPlainText());
    var maxWidth = 0;
    for (final line in lines) {
      if (line.length > maxWidth) {
        maxWidth = line.length;
      }
    }
    return LineInfo(lineCount: lines.length, maxWidth: maxWidth, lines: lines);
  }

  LineInfo get logicalLineInfo => lineInfo;

  String getSelectedText() {
    _guard();
    final selection = getSelection();
    if (selection == null) {
      return '';
    }
    return textBuffer.getTextRange(selection.start, selection.end);
  }

  String getPlainText() {
    _guard();
    return textBuffer.getPlainText();
  }

  void setTabIndicator(String indicator) {
    _guard();
    _tabIndicator = indicator.runes.first;
  }

  void setTabIndicatorCodePoint(int indicator) {
    _guard();
    _tabIndicator = indicator;
  }

  void setTabIndicatorColor(TuiColor color) {
    _guard();
    _tabIndicatorColor = color;
  }

  void setTruncate(bool truncate) {
    _guard();
    _truncate = truncate;
  }

  ({int lineCount, int maxWidth})? measureForDimensions(int width, int height) {
    _guard();
    if (width <= 0 || height <= 0) {
      return null;
    }

    final lines = _virtualLines();
    var maxWidth = 0;
    for (final line in lines) {
      if (line.length > maxWidth) {
        maxWidth = line.length;
      }
    }
    return (lineCount: lines.length, maxWidth: maxWidth);
  }

  int getVirtualLineCount() {
    _guard();
    return _virtualLines().length;
  }

  int get viewportX => _viewportX;
  int get viewportY => _viewportY;
  int get viewportWidth => _viewportWidth;
  int get viewportHeight => _viewportHeight;
  WrapMode get wrapMode => _wrapMode;
  int get wrapWidth => _wrapWidth;
  int get tabIndicator => _tabIndicator;
  TuiColor get tabIndicatorColor => _tabIndicatorColor;
  bool get truncate => _truncate;

  void destroy() {
    _destroyed = true;
  }

  List<String> _virtualLines() {
    final rawLines = splitLines(textBuffer.getPlainText());
    final effectiveWidth = _wrapWidth > 0 ? _wrapWidth : _viewportWidth;
    if (_wrapMode == WrapMode.none || effectiveWidth <= 0) {
      return rawLines;
    }

    final virtual = <String>[];
    for (final raw in rawLines) {
      if (raw.isEmpty) {
        virtual.add('');
        continue;
      }

      if (_wrapMode == WrapMode.char) {
        for (var index = 0; index < raw.length; index += effectiveWidth) {
          final end = clampInt(index + effectiveWidth, index, raw.length);
          virtual.add(raw.substring(index, end));
        }
        continue;
      }

      // word wrap
      var current = '';
      for (final token in raw.split(' ')) {
        final next = current.isEmpty ? token : '$current $token';
        if (next.length <= effectiveWidth) {
          current = next;
        } else {
          if (current.isNotEmpty) {
            virtual.add(current);
          }
          current = token;
        }
      }
      virtual.add(current);
    }

    return virtual;
  }

  int _lineColToOffset(int line, int col) {
    final lines = splitLines(textBuffer.getPlainText());
    if (lines.isEmpty) {
      return 0;
    }
    final row = clampInt(line, 0, lines.length - 1);
    var offset = 0;
    for (var i = 0; i < row; i++) {
      offset += lines[i].length + 1;
    }
    final lineCol = clampInt(col, 0, lines[row].length);
    return offset + lineCol;
  }
}
