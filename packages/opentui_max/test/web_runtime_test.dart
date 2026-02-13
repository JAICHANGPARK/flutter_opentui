import 'package:opentui_max/core.dart';
import 'package:opentui_max/web.dart';
import 'package:test/test.dart';

void main() {
  test('web runtime renders html and stylesheet', () {
    final frame = TuiFrame.blank(width: 3, height: 1);
    frame.setCell(
      0,
      0,
      const TuiCell(
        char: 'X',
        style: TuiStyle(
          foreground: TuiColor.green,
          background: TuiColor.black,
          bold: true,
        ),
      ),
    );

    final runtime = OpenTuiWebRuntime();
    final html = runtime.renderFrame(frame);
    final css = runtime.renderStyleSheet();

    expect(html, contains('<pre class="opentui-surface">'));
    expect(html, contains('X'));
    expect(css, contains('.opentui-surface'));
  });
}
