import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('AnsiRenderer', () {
    test('renders only changed cells when previous frame exists', () {
      final previous = TuiFrame.blank(width: 4, height: 1);
      final next = previous.clone()..setCell(1, 0, const TuiCell(char: 'A'));

      final ansi = AnsiRenderer().renderDiff(previous: previous, next: next);

      expect(ansi, contains('\x1b[1;2H'));
      expect(ansi, contains('A'));
      expect(ansi, isNot(contains('\x1b[1;1H')));
    });
  });
}
