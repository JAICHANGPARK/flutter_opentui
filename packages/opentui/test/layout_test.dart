import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Layout', () {
    test('row layout distributes remaining width to flexible children', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 20,
        viewportHeight: 10,
      );

      final left = TuiText(id: 'left', text: 'left', width: 6);
      final right = TuiText(id: 'right', text: 'right');
      final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.row)
        ..add(left)
        ..add(right);

      engine.mount(root);
      engine.render();

      expect(left.layoutBounds?.x, 0);
      expect(left.layoutBounds?.width, 6);
      expect(right.layoutBounds?.x, 6);
      expect(right.layoutBounds?.width, 14);
    });

    test('row layout uses flexGrow weights for flexible children', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 12,
        viewportHeight: 5,
      );

      final left = TuiText(id: 'left', text: 'left', flexGrow: 1);
      final right = TuiText(id: 'right', text: 'right', flexGrow: 2);
      final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.row)
        ..add(left)
        ..add(right);

      engine.mount(root);
      engine.render();

      expect(left.layoutBounds?.width, 4);
      expect(right.layoutBounds?.width, 8);
    });

    test('column layout uses flexGrow weights for flexible children', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 12,
        viewportHeight: 9,
      );

      final top = TuiText(id: 'top', text: 'top', flexGrow: 1);
      final middle = TuiText(id: 'middle', text: 'middle', flexGrow: 2);
      final bottom = TuiText(id: 'bottom', text: 'bottom', height: 1);
      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
            ..add(top)
            ..add(middle)
            ..add(bottom);

      engine.mount(root);
      engine.render();

      expect(top.layoutBounds?.height, 2);
      expect(middle.layoutBounds?.height, 6);
      expect(bottom.layoutBounds?.height, 1);
    });

    test('absolute layout respects left/top positioning', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 20,
        viewportHeight: 10,
      );

      final child = TuiText(id: 'child', text: 'x', left: 3, top: 2, width: 5);
      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.absolute,
      )..add(child);

      engine.mount(root);
      engine.render();

      expect(child.layoutBounds?.x, 3);
      expect(child.layoutBounds?.y, 2);
      expect(child.layoutBounds?.width, 5);
      expect(child.layoutBounds?.height, 1);
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
