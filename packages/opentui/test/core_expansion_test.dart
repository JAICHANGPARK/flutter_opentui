import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Core expansion', () {
    test('tab select handles horizontal navigation via engine input', () async {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 30,
        viewportHeight: 6,
      );

      final tabs = TuiTabSelect(
        id: 'tabs',
        options: const <String>['home', 'logs', 'settings'],
      );
      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.column,
      )..add(tabs);

      engine.mount(root);
      engine.render();

      expect(engine.focusedNode, same(tabs));
      expect(tabs.selectedIndex, 0);
      expect(output.frames.last.cellAt(1, 0).char, 'h');

      input.addKey(TuiKeyEvent.special(TuiSpecialKey.arrowRight));
      await Future<void>.delayed(Duration.zero);
      expect(tabs.selectedIndex, 1);

      input.addKey(TuiKeyEvent.special(TuiSpecialKey.arrowLeft));
      await Future<void>.delayed(Duration.zero);
      expect(tabs.selectedIndex, 0);

      await engine.dispose();
      await input.dispose();
    });

    test('ascii font node paints multi-line glyph text', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 8,
        viewportHeight: 5,
      );

      engine.mount(TuiAsciiFont(id: 'ascii', text: 'A'));
      engine.render();

      final frame = output.frames.last;
      expect(frame.cellAt(1, 0).char, '/');
      expect(frame.cellAt(0, 2).char, '|');
    });

    test('frame buffer node paints buffer cells and supports transparency', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 10,
        viewportHeight: 3,
      );

      final buffer = OptimizedBuffer(width: 3, height: 1)
        ..drawText(0, 0, ' Z ');

      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.absolute)
            ..add(TuiText(id: 'base', text: 'abc', width: 3, height: 1))
            ..add(
              TuiFrameBufferNode(
                id: 'overlay',
                left: 0,
                top: 0,
                width: 3,
                height: 1,
                buffer: buffer,
                transparent: true,
              ),
            );

      engine.mount(root);
      engine.render();

      final frame = output.frames.last;
      expect(frame.cellAt(0, 0).char, 'a');
      expect(frame.cellAt(1, 0).char, 'Z');
      expect(frame.cellAt(2, 0).char, 'c');
    });
  });

  group('Color parsing', () {
    test(
      'parseColor supports RGBA, ints, hex, rgb strings, and named colors',
      () {
        expect(parseColor(const RGBA(1, 2, 3, 128)), const TuiColor(1, 2, 3));
        expect(parseColor(0x112233), const TuiColor(0x11, 0x22, 0x33));
        expect(parseColor('#0f0'), const TuiColor(0, 255, 0));
        expect(parseColor('#102030'), const TuiColor(0x10, 0x20, 0x30));
        expect(parseColor('rgb(7, 8, 9)'), const TuiColor(7, 8, 9));
        expect(parseColor('cyan'), TuiColor.cyan);
        expect(parseColor('invalid-color'), isNull);
      },
    );
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

  void addKey(TuiKeyEvent event) {
    _keyController.add(event);
  }

  Future<void> dispose() async {
    await _keyController.close();
    await _mouseController.close();
    await _resizeController.close();
  }
}

final class _MemoryOutput implements TuiOutputSink {
  final List<TuiFrame> frames = <TuiFrame>[];

  @override
  Future<void> present(TuiFrame frame) async {
    frames.add(frame.clone());
  }
}
