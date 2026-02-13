import 'dart:convert';

import 'syntax_style.dart';
import 'types.dart';
import 'utils.dart';

typedef TextChunk = ({String text, Object? fg, Object? bg, int attributes});

final class TextBuffer {
  TextBuffer._({required this.widthMethod});

  factory TextBuffer.create(WidthMethod widthMethod) {
    return TextBuffer._(widthMethod: widthMethod);
  }

  final WidthMethod widthMethod;
  final Map<int, List<Highlight>> _lineHighlights = <int, List<Highlight>>{};
  final List<Highlight> _charRangeHighlights = <Highlight>[];
  bool _destroyed = false;

  String _text = '';
  int _tabWidth = 2;
  int _nextHighlightRef = 1;
  SyntaxStyle? _syntaxStyle;

  void _guard() {
    if (_destroyed) {
      throw StateError('TextBuffer is destroyed');
    }
  }

  void setText(String text) {
    _guard();
    _text = text;
  }

  void append(String text) {
    _guard();
    _text += text;
  }

  void loadFile(String path) {
    _guard();
    throw UnsupportedError(
      'TextBuffer.loadFile is not implemented in pure Dart runtime. '
      'Read file contents externally and call setText(). path=$path',
    );
  }

  void setStyledText(List<TextChunk> chunks) {
    _guard();
    final buffer = StringBuffer();
    for (final chunk in chunks) {
      buffer.write(chunk.text);
    }
    _text = buffer.toString();
  }

  int getLineCount() {
    _guard();
    return splitLines(_text).length;
  }

  int get length {
    _guard();
    return _text.runes.length;
  }

  int get byteSize {
    _guard();
    return utf8.encode(_text).length;
  }

  String getPlainText() {
    _guard();
    return _text;
  }

  String getTextRange(int startOffset, int endOffset) {
    _guard();
    if (startOffset >= endOffset) {
      return '';
    }
    final runes = _text.runes.toList(growable: false);
    final start = clampInt(startOffset, 0, runes.length);
    final end = clampInt(endOffset, start, runes.length);
    return String.fromCharCodes(runes.sublist(start, end));
  }

  void addHighlightByCharRange(Highlight highlight) {
    _guard();
    _charRangeHighlights.add(_withRef(highlight));
  }

  void addHighlight(int lineIdx, Highlight highlight) {
    _guard();
    _lineHighlights
        .putIfAbsent(lineIdx, () => <Highlight>[])
        .add(_withRef(highlight));
  }

  void removeHighlightsByRef(int hlRef) {
    _guard();
    _charRangeHighlights.removeWhere((h) => h.ref == hlRef);
    for (final highlights in _lineHighlights.values) {
      highlights.removeWhere((h) => h.ref == hlRef);
    }
  }

  void clearLineHighlights(int lineIdx) {
    _guard();
    _lineHighlights.remove(lineIdx);
  }

  void clearAllHighlights() {
    _guard();
    _lineHighlights.clear();
    _charRangeHighlights.clear();
  }

  List<Highlight> getLineHighlights(int lineIdx) {
    _guard();
    return List<Highlight>.from(
      _lineHighlights[lineIdx] ?? const <Highlight>[],
    );
  }

  int getHighlightCount() {
    _guard();
    var count = _charRangeHighlights.length;
    for (final line in _lineHighlights.values) {
      count += line.length;
    }
    return count;
  }

  void setSyntaxStyle(SyntaxStyle? style) {
    _guard();
    _syntaxStyle = style;
  }

  SyntaxStyle? getSyntaxStyle() {
    _guard();
    return _syntaxStyle;
  }

  void setTabWidth(int width) {
    _guard();
    _tabWidth = width <= 0 ? 1 : width;
  }

  int getTabWidth() {
    _guard();
    return _tabWidth;
  }

  void clear() {
    _guard();
    _text = '';
    _lineHighlights.clear();
    _charRangeHighlights.clear();
  }

  void reset() {
    _guard();
    _text = '';
    _tabWidth = 2;
    _syntaxStyle = null;
    _lineHighlights.clear();
    _charRangeHighlights.clear();
  }

  void destroy() {
    if (_destroyed) {
      return;
    }
    _destroyed = true;
    _text = '';
    _lineHighlights.clear();
    _charRangeHighlights.clear();
    _syntaxStyle = null;
  }

  Highlight _withRef(Highlight highlight) {
    if (highlight.ref != null) {
      return highlight;
    }
    return highlight.copyWith(ref: _nextHighlightRef++);
  }
}
