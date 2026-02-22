import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Component coverage', () {
    test('new renderables map to node/component types', () {
      final root =
          BoxRenderable(id: 'root', layoutDirection: TuiLayoutDirection.column)
            ..add(MarkdownRenderable(id: 'md', markdown: '# Header'))
            ..add(CodeRenderable(id: 'code', code: 'print("ok");'))
            ..add(DiffRenderable(id: 'diff', previous: 'a', next: 'b'))
            ..add(
              LineNumberRenderable(
                id: 'ln',
                lines: const <String>['one', 'two'],
              ),
            )
            ..add(ScrollBoxRenderable(id: 'sb'))
            ..add(ScrollbarRenderable(id: 'bar'))
            ..add(SliderRenderable(id: 'slider'))
            ..add(TextareaRenderable(id: 'ta'));

      final node = root.toNode() as TuiBox;

      expect(node.children[0], isA<TuiMarkdown>());
      expect(node.children[1], isA<TuiCode>());
      expect(node.children[2], isA<TuiDiff>());
      expect(node.children[3], isA<TuiLineNumber>());
      expect(node.children[4], isA<TuiScrollBox>());
      expect(node.children[5], isA<TuiScrollbar>());
      expect(node.children[6], isA<TuiSlider>());
      expect(node.children[7], isA<TuiTextarea>());
    });

    test('engine paints minimal output for new component nodes', () {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 30,
        viewportHeight: 10,
      );

      final scrollBox =
          TuiScrollBox(
              id: 'scrollbox',
              left: 15,
              top: 0,
              width: 10,
              height: 3,
              layoutDirection: TuiLayoutDirection.column,
              scrollOffset: 1,
            )
            ..add(TuiText(id: 's1', text: 'one'))
            ..add(TuiText(id: 's2', text: 'two'))
            ..add(TuiText(id: 's3', text: 'three'));

      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.absolute)
            ..add(
              TuiMarkdown(
                id: 'md',
                markdown: '# Title',
                left: 0,
                top: 0,
                width: 12,
                height: 1,
              ),
            )
            ..add(
              TuiDiff(
                id: 'diff',
                previous: 'a',
                next: 'b',
                left: 0,
                top: 1,
                width: 12,
                height: 2,
              ),
            )
            ..add(
              TuiLineNumber(
                id: 'ln',
                lines: const <String>['x', 'y'],
                left: 0,
                top: 3,
                width: 12,
                height: 2,
              ),
            )
            ..add(
              TuiSlider(id: 'slider', left: 0, top: 5, width: 10, value: 50),
            )
            ..add(
              TuiScrollbar(
                id: 'bar',
                left: 12,
                top: 0,
                width: 1,
                height: 6,
                value: 0.5,
                thumbRatio: 0.3,
              ),
            )
            ..add(
              TuiTextarea(
                id: 'ta',
                left: 0,
                top: 7,
                width: 12,
                height: 2,
                value: 'hi\nthere',
              ),
            )
            ..add(scrollBox);

      engine.mount(root);
      engine.render();

      final frame = output.frames.last;
      expect(frame.cellAt(0, 0).char, 'T');
      expect(frame.cellAt(0, 1).char, '-');
      expect(frame.cellAt(0, 2).char, '+');
      expect(frame.cellAt(0, 3).char, '1');
      expect(frame.cellAt(0, 5).char, isNot(' '));
      expect(frame.cellAt(12, 0).char, anyOf('|', '#'));
      expect(frame.cellAt(0, 7).char, 'h');
      expect(frame.cellAt(0, 8).char, 't');
      expect(frame.cellAt(15, 0).char, 't');
    });

    test('construct helpers compose declarative renderable trees', () {
      final tree = Box(
        id: 'root',
        layoutDirection: TuiLayoutDirection.column,
        children: <BaseRenderable>[
          Text(id: 'text', content: 'hello'),
          Markdown(id: 'md', markdown: '# heading'),
          Slider(id: 'slider', width: 8, value: 40),
          Scrollbar(id: 'bar', height: 4),
          Textarea(id: 'ta', value: 'line1\nline2'),
        ],
      );

      final children = tree.getChildren();
      expect(children, hasLength(5));
      expect(children[0], isA<TextRenderable>());
      expect(children[1], isA<MarkdownRenderable>());
      expect(children[2], isA<SliderRenderable>());
      expect(children[3], isA<ScrollbarRenderable>());
      expect(children[4], isA<TextareaRenderable>());
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
