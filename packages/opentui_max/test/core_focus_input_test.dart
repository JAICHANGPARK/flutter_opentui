import 'dart:async';

import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

Future<void> _pump() => Future<void>.delayed(Duration.zero);

void main() {
  test('tab cycles focus and input captures characters', () async {
    final inputSource = MemoryInputSource();
    final outputSink = MemoryOutputSink();
    final engine = TuiEngine(
      inputSource: inputSource,
      outputSink: outputSink,
      viewportWidth: 40,
      viewportHeight: 10,
    );

    final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column);
    final input = TuiInput(id: 'input', width: 20, placeholder: 'type here');
    final select = TuiSelect(
      id: 'select',
      width: 20,
      options: const <String>['A', 'B', 'C'],
    );
    root
      ..add(input)
      ..add(select);

    engine.mount(root);
    engine.render();

    expect(engine.focusedNode, same(input));

    inputSource.emitKey(const TuiKeyEvent.character('x'));
    await _pump();
    expect(input.value, equals('x'));

    inputSource.emitKey(const TuiKeyEvent.special(TuiSpecialKey.tab));
    await _pump();
    expect(engine.focusedNode, same(select));

    inputSource.emitKey(const TuiKeyEvent.special(TuiSpecialKey.arrowDown));
    await _pump();
    expect(select.selectedIndex, equals(1));

    await engine.dispose();
    await inputSource.dispose();
  });
}
