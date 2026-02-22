import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Selection model', () {
    test('range normalizes coordinates and tracks included cells', () {
      const selection = TuiSelectionRange(
        anchor: TuiSelectionPoint(x: 4, y: 2),
        focus: TuiSelectionPoint(x: 1, y: 0),
      );

      expect(selection.start, const TuiSelectionPoint(x: 1, y: 0));
      expect(selection.end, const TuiSelectionPoint(x: 4, y: 2));
      expect(selection.containsCell(1, 0), isTrue);
      expect(selection.containsCell(0, 0), isFalse);
      expect(selection.containsCell(50, 1), isTrue);
      expect(selection.containsCell(4, 2), isTrue);
      expect(selection.containsCell(5, 2), isFalse);
    });
  });

  group('Engine selection lifecycle', () {
    test(
      'dragging over text updates selection stream and frame overlay',
      () async {
        final input = MemoryInputSource();
        final output = MemoryOutputSink();
        final engine = TuiEngine(
          inputSource: input,
          outputSink: output,
          viewportWidth: 10,
          viewportHeight: 2,
        );

        final root = TuiBox(id: 'root')
          ..add(TuiText(id: 'text', width: 10, height: 1, text: 'hello'));
        engine.mount(root);
        engine.render();

        final events = <TuiSelectionRange?>[];
        final selectionSubscription = engine.selectionChanges.listen(
          events.add,
        );

        input.emitMouse(
          TuiMouseEvent(
            type: TuiMouseEventType.down,
            x: 1,
            y: 0,
            button: TuiMouseButton.left,
          ),
        );
        input.emitMouse(
          TuiMouseEvent(
            type: TuiMouseEventType.drag,
            x: 3,
            y: 0,
            button: TuiMouseButton.left,
          ),
        );
        input.emitMouse(
          TuiMouseEvent(
            type: TuiMouseEventType.up,
            x: 3,
            y: 0,
            button: TuiMouseButton.left,
          ),
        );
        await Future<void>.delayed(Duration.zero);

        final selection = engine.selection;
        expect(selection, isNotNull);
        expect(selection!.start, const TuiSelectionPoint(x: 1, y: 0));
        expect(selection.end, const TuiSelectionPoint(x: 3, y: 0));
        expect(engine.isSelecting, isFalse);
        expect(events, isNotEmpty);

        final frame = engine.lastFrame;
        expect(frame, isNotNull);
        expect(frame!.cellAt(0, 0).style.inverse, isFalse);
        expect(frame.cellAt(1, 0).style.inverse, isTrue);
        expect(frame.cellAt(2, 0).style.inverse, isTrue);
        expect(frame.cellAt(3, 0).style.inverse, isTrue);

        await selectionSubscription.cancel();
        await engine.dispose();
        await input.dispose();
      },
    );

    test('selection clears when clicking non-selectable node', () async {
      final input = MemoryInputSource();
      final output = MemoryOutputSink();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 10,
        viewportHeight: 3,
      );

      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
            ..add(TuiText(id: 'text', width: 10, height: 1, text: 'hello'))
            ..add(TuiInput(id: 'input', width: 10, height: 1));
      engine.mount(root);
      engine.render();

      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.down,
          x: 1,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.drag,
          x: 4,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.up,
          x: 4,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(engine.selection, isNotNull);

      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.down,
          x: 1,
          y: 1,
          button: TuiMouseButton.left,
        ),
      );
      await Future<void>.delayed(Duration.zero);
      expect(engine.selection, isNull);

      await engine.dispose();
      await input.dispose();
    });

    test('text selectable flag gates selection start', () async {
      final input = MemoryInputSource();
      final output = MemoryOutputSink();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 10,
        viewportHeight: 2,
      );

      final root = TuiBox(id: 'root')
        ..add(
          TuiText(
            id: 'text',
            width: 10,
            height: 1,
            text: 'hello',
            selectable: false,
          ),
        );
      engine.mount(root);
      engine.render();

      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.down,
          x: 1,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.drag,
          x: 4,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      input.emitMouse(
        TuiMouseEvent(
          type: TuiMouseEventType.up,
          x: 4,
          y: 0,
          button: TuiMouseButton.left,
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(engine.selection, isNull);

      await engine.dispose();
      await input.dispose();
    });
  });
}
