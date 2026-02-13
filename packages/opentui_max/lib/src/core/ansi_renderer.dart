import 'frame.dart';

final class AnsiRenderer {
  String renderDiff({required TuiFrame next, TuiFrame? previous}) {
    final buffer = StringBuffer();
    for (final delta in next.diff(previous)) {
      buffer
        ..write(_cursor(delta.x, delta.y))
        ..write('\x1b[0m')
        ..write(delta.cell.style.toAnsi())
        ..write(delta.cell.char);
    }
    buffer.write('\x1b[0m');
    return buffer.toString();
  }

  String renderFull(TuiFrame frame) => renderDiff(next: frame, previous: null);

  String clearScreen() => '\x1b[2J\x1b[H';

  static String _cursor(int x, int y) => '\x1b[${y + 1};${x + 1}H';
}
