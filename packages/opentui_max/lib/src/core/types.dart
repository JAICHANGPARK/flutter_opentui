import 'frame.dart';

enum WidthMethod { wcwidth, unicodeScalar }

enum WrapMode { none, char, word }

final class Highlight {
  const Highlight({
    required this.start,
    required this.end,
    this.fg,
    this.bg,
    this.attributes = 0,
    this.ref,
  });

  final int start;
  final int end;
  final TuiColor? fg;
  final TuiColor? bg;
  final int attributes;
  final int? ref;

  Highlight copyWith({
    int? start,
    int? end,
    TuiColor? fg,
    TuiColor? bg,
    int? attributes,
    int? ref,
  }) {
    return Highlight(
      start: start ?? this.start,
      end: end ?? this.end,
      fg: fg ?? this.fg,
      bg: bg ?? this.bg,
      attributes: attributes ?? this.attributes,
      ref: ref ?? this.ref,
    );
  }
}

final class LogicalCursor {
  const LogicalCursor({
    required this.row,
    required this.col,
    required this.offset,
  });

  final int row;
  final int col;
  final int offset;
}

final class VisualCursor {
  const VisualCursor({required this.row, required this.col});

  final int row;
  final int col;
}

final class LineInfo {
  const LineInfo({
    required this.lineCount,
    required this.maxWidth,
    required this.lines,
  });

  final int lineCount;
  final int maxWidth;
  final List<String> lines;
}
