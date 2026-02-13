import 'dart:convert';

import '../core/frame.dart';

final class OpenTuiWebRuntime {
  const OpenTuiWebRuntime();

  String renderFrame(TuiFrame frame, {String className = 'opentui-surface'}) {
    final html = StringBuffer();
    final escape = const HtmlEscape();

    html.write('<pre class="${escape.convert(className)}">');
    for (var y = 0; y < frame.height; y++) {
      for (var x = 0; x < frame.width; x++) {
        final cell = frame.cellAt(x, y);
        final fg = _hex(cell.style.foreground ?? TuiColor.white);
        final bg = _hex(cell.style.background ?? TuiColor.black);
        final weight = cell.style.bold ? '700' : '400';
        final text = escape.convert(cell.char);
        html.write(
          '<span style="color:$fg;background:$bg;font-weight:$weight;">$text</span>',
        );
      }
      if (y < frame.height - 1) {
        html.write('\n');
      }
    }
    html.write('</pre>');
    return html.toString();
  }

  String renderStyleSheet({String className = 'opentui-surface'}) {
    final escape = const HtmlEscape();
    final resolved = escape.convert(className);
    return '''
.$resolved {
  display: inline-block;
  white-space: pre;
  line-height: 1.2;
  font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
  padding: 8px;
  border-radius: 6px;
  background: #101418;
  color: #f4f7fb;
}
''';
  }

  String _hex(TuiColor color) {
    final r = color.r.toRadixString(16).padLeft(2, '0');
    final g = color.g.toRadixString(16).padLeft(2, '0');
    final b = color.b.toRadixString(16).padLeft(2, '0');
    return '#$r$g$b';
  }
}
