import 'package:opentui_max/core.dart';
import 'package:opentui_max/web.dart';

void main() {
  final frame = TuiFrame.blank(width: 24, height: 4);
  frame.drawText(
    0,
    0,
    'OpenTUI Max Web',
    style: const TuiStyle(foreground: TuiColor.cyan, bold: true),
  );
  frame.drawText(0, 2, 'rendered as HTML spans');

  final runtime = OpenTuiWebRuntime();
  final html = runtime.renderFrame(frame);
  final css = runtime.renderStyleSheet();

  print('<style>$css</style>');
  print(html);
}
