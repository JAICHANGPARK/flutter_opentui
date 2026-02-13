import 'package:meta/meta.dart';

@immutable
final class TuiColor {
  const TuiColor(this.r, this.g, this.b)
    : assert(r >= 0 && r <= 255),
      assert(g >= 0 && g <= 255),
      assert(b >= 0 && b <= 255);

  static const white = TuiColor(255, 255, 255);
  static const black = TuiColor(0, 0, 0);
  static const green = TuiColor(0, 255, 0);
  static const cyan = TuiColor(0, 255, 255);

  final int r;
  final int g;
  final int b;

  String asForegroundAnsi() => '\x1b[38;2;$r;$g;${b}m';

  String asBackgroundAnsi() => '\x1b[48;2;$r;$g;${b}m';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TuiColor && other.r == r && other.g == g && other.b == b;
  }

  @override
  int get hashCode => Object.hash(r, g, b);
}

@immutable
final class TuiStyle {
  const TuiStyle({
    this.foreground,
    this.background,
    this.bold = false,
    this.inverse = false,
  });

  static const plain = TuiStyle();

  final TuiColor? foreground;
  final TuiColor? background;
  final bool bold;
  final bool inverse;

  TuiStyle copyWith({
    TuiColor? foreground,
    TuiColor? background,
    bool? bold,
    bool? inverse,
  }) {
    return TuiStyle(
      foreground: foreground ?? this.foreground,
      background: background ?? this.background,
      bold: bold ?? this.bold,
      inverse: inverse ?? this.inverse,
    );
  }

  String toAnsi() {
    final buffer = StringBuffer();
    if (bold) {
      buffer.write('\x1b[1m');
    }
    if (inverse) {
      buffer.write('\x1b[7m');
    }
    final fg = foreground;
    if (fg != null) {
      buffer.write(fg.asForegroundAnsi());
    }
    final bg = background;
    if (bg != null) {
      buffer.write(bg.asBackgroundAnsi());
    }
    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TuiStyle &&
        other.foreground == foreground &&
        other.background == background &&
        other.bold == bold &&
        other.inverse == inverse;
  }

  @override
  int get hashCode => Object.hash(foreground, background, bold, inverse);
}

@immutable
final class TuiCell {
  const TuiCell({required this.char, this.style = TuiStyle.plain})
    : assert(char.length == 1, 'TuiCell.char must be a single code point');

  final String char;
  final TuiStyle style;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TuiCell && other.char == char && other.style == style;
  }

  @override
  int get hashCode => Object.hash(char, style);
}

@immutable
final class TuiCellDelta {
  const TuiCellDelta({required this.x, required this.y, required this.cell});

  final int x;
  final int y;
  final TuiCell cell;
}

final class TuiFrame {
  TuiFrame.blank({
    required this.width,
    required this.height,
    TuiCell fill = const TuiCell(char: ' '),
  }) : _cells = List<TuiCell>.filled(width * height, fill, growable: false);

  TuiFrame._(this.width, this.height, this._cells);

  final int width;
  final int height;
  final List<TuiCell> _cells;

  TuiFrame clone() => TuiFrame._(width, height, List<TuiCell>.from(_cells));

  bool contains(int x, int y) => x >= 0 && y >= 0 && x < width && y < height;

  TuiCell cellAt(int x, int y) {
    if (!contains(x, y)) {
      throw RangeError('Cell out of range: ($x, $y)');
    }
    return _cells[(y * width) + x];
  }

  void setCell(int x, int y, TuiCell cell) {
    if (!contains(x, y)) {
      return;
    }
    _cells[(y * width) + x] = cell;
  }

  void drawText(
    int x,
    int y,
    String text, {
    TuiStyle style = TuiStyle.plain,
    int? maxWidth,
  }) {
    if (y < 0 || y >= height) {
      return;
    }

    final runes = text.runes.toList(growable: false);
    final widthLimit = maxWidth ?? runes.length;
    for (var i = 0; i < runes.length && i < widthLimit; i++) {
      final nextX = x + i;
      if (nextX < 0 || nextX >= width) {
        continue;
      }
      setCell(
        nextX,
        y,
        TuiCell(char: String.fromCharCode(runes[i]), style: style),
      );
    }
  }

  void fillRect(
    int x,
    int y,
    int rectWidth,
    int rectHeight, {
    TuiCell fill = const TuiCell(char: ' '),
  }) {
    for (var row = 0; row < rectHeight; row++) {
      for (var col = 0; col < rectWidth; col++) {
        setCell(x + col, y + row, fill);
      }
    }
  }

  Iterable<TuiCellDelta> diff(TuiFrame? previous) sync* {
    if (previous == null ||
        previous.width != width ||
        previous.height != height) {
      for (var y = 0; y < height; y++) {
        for (var x = 0; x < width; x++) {
          yield TuiCellDelta(x: x, y: y, cell: cellAt(x, y));
        }
      }
      return;
    }

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final current = cellAt(x, y);
        if (current != previous.cellAt(x, y)) {
          yield TuiCellDelta(x: x, y: y, cell: current);
        }
      }
    }
  }
}
