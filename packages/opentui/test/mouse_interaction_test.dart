import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Mouse interaction', () {
    test('mouse down focuses clicked input and updates cursor', () async {
      final inputSource = MemoryInputSource();
      final outputSink = MemoryOutputSink();
      final engine = TuiEngine(
        inputSource: inputSource,
        outputSink: outputSink,
        viewportWidth: 20,
        viewportHeight: 4,
      );

      final first = TuiInput(id: 'first', width: 10, height: 1, value: 'first');
      final second = TuiInput(
        id: 'second',
        width: 10,
        height: 1,
        value: 'hello',
      );
      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
            ..add(first)
            ..add(second);

      engine.mount(root);
      engine.render();
      expect(engine.focusedNode, same(first));

      inputSource.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.down,
          x: 2,
          y: 1,
          button: TuiMouseButton.left,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(engine.focusedNode, same(second));
      expect(second.cursorPosition, 2);

      await engine.dispose();
      await inputSource.dispose();
    });

    test(
      'scroll events fall back to focused node when hit-test misses',
      () async {
        final inputSource = MemoryInputSource();
        final outputSink = MemoryOutputSink();
        final engine = TuiEngine(
          inputSource: inputSource,
          outputSink: outputSink,
          viewportWidth: 10,
          viewportHeight: 2,
        );

        final scrollBox = TuiScrollBox(id: 'scrollbox', width: 10, height: 1)
          ..add(TuiText(id: 'line-1', text: 'one'))
          ..add(TuiText(id: 'line-2', text: 'two'))
          ..add(TuiText(id: 'line-3', text: 'three'));
        final root = TuiBox(id: 'root')..add(scrollBox);

        engine.mount(root);
        engine.render();
        expect(engine.focusedNode, same(scrollBox));
        expect(scrollBox.scrollOffset, 0);

        inputSource.emitMouse(
          TuiMouseEvent(
            type: TuiMouseEventType.scroll,
            x: 99,
            y: 99,
            scroll: TuiScrollInfo(direction: TuiScrollDirection.down, delta: 1),
          ),
        );
        await Future<void>.delayed(Duration.zero);

        expect(scrollBox.scrollOffset, 1);

        await engine.dispose();
        await inputSource.dispose();
      },
    );

    test('mouse click selects list row', () async {
      final inputSource = MemoryInputSource();
      final outputSink = MemoryOutputSink();
      final engine = TuiEngine(
        inputSource: inputSource,
        outputSink: outputSink,
        viewportWidth: 20,
        viewportHeight: 4,
      );

      final select = TuiSelect(
        id: 'select',
        width: 20,
        options: const <String>['one', 'two', 'three'],
      );
      final root = TuiBox(id: 'root')..add(select);

      engine.mount(root);
      engine.render();
      expect(select.selectedIndex, 0);

      inputSource.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.down,
          x: 1,
          y: 2,
          button: TuiMouseButton.left,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(select.selectedIndex, 2);
      expect(engine.focusedNode, same(select));

      await engine.dispose();
      await inputSource.dispose();
    });
  });
}
