import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Expanded layout', () {
    test('row layout supports justify/align and percent widths', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 20,
        viewportHeight: 6,
      );

      final childA = TuiText(id: 'a', text: 'A', widthPercent: 25, height: 2);
      final childB = TuiText(id: 'b', text: 'B', width: 5, height: 2);
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.row,
              justify: TuiJustify.center,
              align: TuiAlign.center,
            )
            ..add(childA)
            ..add(childB);

      engine.mount(root);
      engine.render();

      expect(childA.layoutBounds?.width, 5);
      expect(childB.layoutBounds?.width, 5);
      expect(childA.layoutBounds?.x, 5);
      expect(childB.layoutBounds?.x, 10);
      expect(childA.layoutBounds?.y, 2);
      expect(childB.layoutBounds?.y, 2);
    });

    test(
      'column layout supports justify end, align end, and percent heights',
      () {
        final input = _FakeInput();
        final output = _MemoryOutput();
        final engine = TuiEngine(
          inputSource: input,
          outputSink: output,
          viewportWidth: 20,
          viewportHeight: 10,
        );

        final childA = TuiText(id: 'a', text: 'A', width: 5, heightPercent: 20);
        final childB = TuiText(id: 'b', text: 'B', width: 4, height: 3);
        final root =
            TuiBox(
                id: 'root',
                layoutDirection: TuiLayoutDirection.column,
                justify: TuiJustify.end,
                align: TuiAlign.end,
              )
              ..add(childA)
              ..add(childB);

        engine.mount(root);
        engine.render();

        expect(childA.layoutBounds?.height, 2);
        expect(childA.layoutBounds?.y, 5);
        expect(childB.layoutBounds?.y, 7);
        expect(childA.layoutBounds?.x, 15);
        expect(childB.layoutBounds?.x, 16);
      },
    );

    test('absolute layout supports percent sizing', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 20,
        viewportHeight: 10,
      );

      final child = TuiText(
        id: 'child',
        text: 'x',
        left: 2,
        top: 1,
        widthPercent: 50,
        heightPercent: 30,
      );
      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.absolute,
      )..add(child);

      engine.mount(root);
      engine.render();

      expect(child.layoutBounds?.x, 2);
      expect(child.layoutBounds?.y, 1);
      expect(child.layoutBounds?.width, 10);
      expect(child.layoutBounds?.height, 3);
    });
  });
}

final class _FakeInput implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiMouseEvent> _mouseController =
      StreamController<TuiMouseEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiMouseEvent> get mouseEvents => _mouseController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;
}

final class _MemoryOutput implements TuiOutputSink {
  final List<TuiFrame> frames = <TuiFrame>[];

  @override
  Future<void> present(TuiFrame frame) async {
    frames.add(frame.clone());
  }
}
