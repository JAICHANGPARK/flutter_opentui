import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('ansi diff emits only changed cells for same sized frame', () {
    final renderer = AnsiRenderer();
    final previous = TuiFrame.blank(width: 4, height: 1);
    final next = previous.clone();

    next.setCell(1, 0, const TuiCell(char: 'A'));

    final output = renderer.renderDiff(previous: previous, next: next);

    expect(output, contains('A'));
    expect(output, contains('\x1b[1;2H'));
  });

  test('engine render is deterministic for same tree', () async {
    final input = MemoryInputSource();
    final output = MemoryOutputSink();
    final engine = TuiEngine(
      inputSource: input,
      outputSink: output,
      viewportWidth: 20,
      viewportHeight: 5,
    );

    final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column);
    root.add(TuiText(id: 'title', text: 'hello'));
    engine.mount(root);

    engine.render();
    engine.render();

    expect(output.presented.length, greaterThanOrEqualTo(2));
    expect(
      output.presented[0].cellAt(0, 0),
      equals(output.presented[1].cellAt(0, 0)),
    );

    await engine.dispose();
    await input.dispose();
  });
}
