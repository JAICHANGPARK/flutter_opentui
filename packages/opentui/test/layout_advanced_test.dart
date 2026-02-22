import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Advanced layout', () {
    test('row wrap places overflowing children on new lines', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 10,
        viewportHeight: 4,
      );

      final a = TuiText(id: 'a', text: 'A', width: 6, height: 1);
      final b = TuiText(id: 'b', text: 'B', width: 6, height: 1);
      final c = TuiText(id: 'c', text: 'C', width: 4, height: 1);
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.row,
              wrap: TuiWrap.wrap,
            )
            ..add(a)
            ..add(b)
            ..add(c);

      engine.mount(root);
      engine.render();

      expect(a.layoutBounds?.x, 0);
      expect(a.layoutBounds?.y, 0);
      expect(a.layoutBounds?.width, 6);
      expect(b.layoutBounds?.x, 0);
      expect(b.layoutBounds?.y, 1);
      expect(c.layoutBounds?.x, 6);
      expect(c.layoutBounds?.y, 1);
    });

    test('column wrap places overflowing children in new columns', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 8,
        viewportHeight: 4,
      );

      final a = TuiText(id: 'a', text: 'A', width: 2, height: 3);
      final b = TuiText(id: 'b', text: 'B', width: 2, height: 3);
      final c = TuiText(id: 'c', text: 'C', width: 2, height: 1);
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.column,
              wrap: TuiWrap.wrap,
            )
            ..add(a)
            ..add(b)
            ..add(c);

      engine.mount(root);
      engine.render();

      expect(a.layoutBounds?.x, 0);
      expect(a.layoutBounds?.y, 0);
      expect(b.layoutBounds?.x, 2);
      expect(b.layoutBounds?.y, 0);
      expect(c.layoutBounds?.x, 2);
      expect(c.layoutBounds?.y, 3);
    });

    test('row layout applies min and max width constraints', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 12,
        viewportHeight: 3,
      );

      final fixed = TuiText(
        id: 'fixed',
        text: 'fixed',
        width: 20,
        maxWidth: 5,
        height: 1,
      );
      final flexible = TuiText(
        id: 'flex',
        text: 'flex',
        flexGrow: 1,
        minWidth: 4,
        maxWidth: 6,
        height: 1,
      );
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.row,
              align: TuiAlign.start,
            )
            ..add(fixed)
            ..add(flexible);

      engine.mount(root);
      engine.render();

      expect(fixed.layoutBounds?.width, 5);
      expect(flexible.layoutBounds?.x, 5);
      expect(flexible.layoutBounds?.width, 6);
    });

    test('row layout applies child margins on main and cross axes', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 12,
        viewportHeight: 5,
      );

      final a = TuiText(id: 'a', text: 'A', width: 3, height: 1, margin: 1);
      final b = TuiText(
        id: 'b',
        text: 'B',
        width: 3,
        height: 1,
        marginLeft: 2,
        marginTop: 1,
      );
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.row,
              align: TuiAlign.start,
            )
            ..add(a)
            ..add(b);

      engine.mount(root);
      engine.render();

      expect(a.layoutBounds?.x, 1);
      expect(a.layoutBounds?.y, 1);
      expect(b.layoutBounds?.x, 7);
      expect(b.layoutBounds?.y, 1);
    });

    test('absolute layout applies margins and min/max constraints', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 10,
        viewportHeight: 4,
      );

      final child = TuiText(
        id: 'child',
        text: 'X',
        left: 0,
        top: 0,
        width: 1,
        height: 1,
        minWidth: 3,
        maxWidth: 5,
        minHeight: 2,
        marginLeft: 1,
        marginRight: 1,
        marginTop: 1,
      );
      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.absolute,
      )..add(child);

      engine.mount(root);
      engine.render();

      expect(child.layoutBounds?.x, 1);
      expect(child.layoutBounds?.y, 1);
      expect(child.layoutBounds?.width, 3);
      expect(child.layoutBounds?.height, 2);
    });

    test('edge paddings shrink box content bounds per side', () {
      final engine = TuiEngine(
        inputSource: _FakeInput(),
        outputSink: _MemoryOutput(),
        viewportWidth: 12,
        viewportHeight: 6,
      );

      final fixed = TuiText(id: 'fixed', text: 'X', width: 4, height: 1);
      final fill = TuiText(id: 'fill', text: 'fill', top: 1, height: 1);
      final root =
          TuiBox(
              id: 'root',
              layoutDirection: TuiLayoutDirection.absolute,
              border: true,
              paddingLeft: 2,
              paddingTop: 1,
              paddingRight: 1,
              paddingBottom: 2,
            )
            ..add(fixed)
            ..add(fill);

      engine.mount(root);
      engine.render();

      expect(fixed.layoutBounds?.x, 3);
      expect(fixed.layoutBounds?.y, 2);
      expect(fill.layoutBounds?.x, 3);
      expect(fill.layoutBounds?.y, 3);
      expect(fill.layoutBounds?.width, 7);
    });
  });
}

final class _FakeInput implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

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
