import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Component API surface', () {
    test('construct helpers cover all ref-doc components', () {
      final buffer = OptimizedBuffer(width: 4, height: 1)..drawText(0, 0, 'ok');

      final components = <BaseRenderable>[
        Box(id: 'box'),
        Text(id: 'text', content: 'text'),
        Input(id: 'input'),
        Select(id: 'select', options: const <String>['one']),
        TabSelect(id: 'tabs', options: const <String>['A', 'B']),
        ASCIIFont(id: 'ascii', text: 'A'),
        FrameBuffer(id: 'frame', buffer: buffer),
        Markdown(id: 'markdown', markdown: '# Heading'),
        Code(id: 'code', code: 'print("ok");'),
        Diff(id: 'diff', previous: 'a', next: 'b'),
        LineNumber(id: 'line-number', lines: const <String>['line']),
        ScrollBox(id: 'scrollbox'),
        Scrollbar(id: 'scrollbar'),
        ScrollBar(id: 'scrollbar-alias'),
        Slider(id: 'slider'),
        Textarea(id: 'textarea'),
      ];

      final nodes = components
          .map((component) => component.toNode())
          .toList(growable: false);

      expect(nodes[0], isA<TuiBox>());
      expect(nodes[1], isA<TuiText>());
      expect(nodes[2], isA<TuiInput>());
      expect(nodes[3], isA<TuiSelect>());
      expect(nodes[4], isA<TuiTabSelect>());
      expect(nodes[5], isA<TuiAsciiFont>());
      expect(nodes[6], isA<TuiFrameBufferNode>());
      expect(nodes[7], isA<TuiMarkdown>());
      expect(nodes[8], isA<TuiCode>());
      expect(nodes[9], isA<TuiDiff>());
      expect(nodes[10], isA<TuiLineNumber>());
      expect(nodes[11], isA<TuiScrollBox>());
      expect(nodes[12], isA<TuiScrollbar>());
      expect(nodes[13], isA<TuiScrollbar>());
      expect(nodes[14], isA<TuiSlider>());
      expect(nodes[15], isA<TuiTextarea>());
    });

    test('scrollbox supports focusable keyboard scrolling with clamping', () {
      final scrollBox =
          TuiScrollBox(id: 'scrollbox', scrollStep: 1, fastScrollStep: 3)
            ..add(TuiText(id: 'line-1', text: '1'))
            ..add(TuiText(id: 'line-2', text: '2'))
            ..add(TuiText(id: 'line-3', text: '3'))
            ..add(TuiText(id: 'line-4', text: '4'));

      expect(scrollBox.focusable, isTrue);

      scrollBox.onKey(const TuiKeyEvent.special(TuiSpecialKey.arrowDown));
      expect(scrollBox.scrollOffset, 1);

      scrollBox.onKey(
        const TuiKeyEvent.special(TuiSpecialKey.arrowDown, shift: true),
      );
      expect(scrollBox.scrollOffset, 3);

      scrollBox.onKey(
        const TuiKeyEvent.special(TuiSpecialKey.arrowUp, shift: true),
      );
      expect(scrollBox.scrollOffset, 0);
    });

    test('engine clamps scrollbox overscroll to last visible child', () {
      final engine = TuiEngine(
        inputSource: MemoryInputSource(),
        outputSink: MemoryOutputSink(),
        viewportWidth: 10,
        viewportHeight: 2,
      );

      final scrollBox =
          TuiScrollBox(
              id: 'scrollbox',
              width: 10,
              height: 1,
              scrollOffset: 999,
              layoutDirection: TuiLayoutDirection.column,
            )
            ..add(TuiText(id: 'line-1', text: 'one'))
            ..add(TuiText(id: 'line-2', text: 'two'));

      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.absolute,
      )..add(scrollBox);

      engine.mount(root);
      engine.render();

      expect(scrollBox.scrollOffset, 1);
      final frame = engine.lastFrame;
      expect(frame, isNotNull);
      expect(frame!.cellAt(0, 0).char, 't');
    });

    test('scrollbar supports configurable normal and fast keyboard steps', () {
      final TuiScrollBar scrollbar = TuiScrollBar(
        id: 'scrollbar',
        value: 0.3,
        step: 0.1,
        fastStep: 0.4,
      );

      scrollbar.onKey(const TuiKeyEvent.special(TuiSpecialKey.arrowRight));
      expect(scrollbar.value, closeTo(0.4, 0.0001));

      scrollbar.onKey(
        const TuiKeyEvent.special(TuiSpecialKey.arrowRight, shift: true),
      );
      expect(scrollbar.value, closeTo(0.8, 0.0001));

      scrollbar.onKey(
        const TuiKeyEvent.special(TuiSpecialKey.arrowRight, shift: true),
      );
      expect(scrollbar.value, 1.0);

      scrollbar.onKey(
        const TuiKeyEvent.special(TuiSpecialKey.arrowLeft, shift: true),
      );
      expect(scrollbar.value, closeTo(0.6, 0.0001));
    });

    test('textarea auto-scrolls to keep cursor visible during render', () {
      final engine = TuiEngine(
        inputSource: MemoryInputSource(),
        outputSink: MemoryOutputSink(),
        viewportWidth: 20,
        viewportHeight: 4,
      );

      final textarea = TuiTextarea(
        id: 'textarea',
        width: 20,
        height: 2,
        value: 'one\ntwo\nthree\nfour',
      );
      final root = TuiBox(
        id: 'root',
        layoutDirection: TuiLayoutDirection.absolute,
      )..add(textarea);

      engine.mount(root);
      engine.render();

      expect(textarea.scrollTop, 2);
      expect(engine.lastFrame!.cellAt(0, 0).char, 't');
      expect(engine.lastFrame!.cellAt(0, 1).char, 'f');

      textarea.onKey(const TuiKeyEvent.special(TuiSpecialKey.arrowUp));
      textarea.onKey(const TuiKeyEvent.special(TuiSpecialKey.arrowUp));
      engine.render();

      expect(textarea.scrollTop, 1);
      expect(engine.lastFrame!.cellAt(0, 0).char, 't');
      expect(engine.lastFrame!.cellAt(0, 1).char, 't');
    });
  });
}
