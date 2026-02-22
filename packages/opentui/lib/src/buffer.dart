import 'frame.dart';

final class OptimizedBuffer {
  OptimizedBuffer({
    required int width,
    required int height,
    TuiCell fill = const TuiCell(char: ' '),
  }) : _frame = TuiFrame.blank(width: width, height: height, fill: fill);

  TuiFrame _frame;

  int get width => _frame.width;

  int get height => _frame.height;

  TuiFrame get frame => _frame;

  void resize(
    int width,
    int height, {
    TuiCell fill = const TuiCell(char: ' '),
  }) {
    final next = TuiFrame.blank(width: width, height: height, fill: fill);
    final copyWidth = width < _frame.width ? width : _frame.width;
    final copyHeight = height < _frame.height ? height : _frame.height;

    for (var y = 0; y < copyHeight; y++) {
      for (var x = 0; x < copyWidth; x++) {
        next.setCell(x, y, _frame.cellAt(x, y));
      }
    }
    _frame = next;
  }

  void clear({TuiCell fill = const TuiCell(char: ' ')}) {
    _frame.fillRect(0, 0, _frame.width, _frame.height, fill: fill);
  }

  bool contains(int x, int y) => _frame.contains(x, y);

  TuiCell cellAt(int x, int y) => _frame.cellAt(x, y);

  void setCell(int x, int y, TuiCell cell) {
    _frame.setCell(x, y, cell);
  }

  void drawText(
    int x,
    int y,
    String text, {
    TuiStyle style = TuiStyle.plain,
    int? maxWidth,
  }) {
    _frame.drawText(x, y, text, style: style, maxWidth: maxWidth);
  }

  void fillRect(
    int x,
    int y,
    int width,
    int height, {
    TuiCell fill = const TuiCell(char: ' '),
  }) {
    _frame.fillRect(x, y, width, height, fill: fill);
  }

  TuiFrame snapshot() => _frame.clone();
}
