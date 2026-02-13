import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Focus and input', () {
    test('tab switches focus and arrow keys update select', () async {
      final input = _FakeInput();
      final output = _MemoryOutput();
      final engine = TuiEngine(
        inputSource: input,
        outputSink: output,
        viewportWidth: 30,
        viewportHeight: 8,
      );

      final textInput = TuiInput(id: 'input', placeholder: 'type...');
      final select = TuiSelect(
        id: 'select',
        options: const <String>['one', 'two', 'three'],
      );
      final root =
          TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
            ..add(textInput)
            ..add(select);

      engine.mount(root);
      engine.render();

      expect(engine.focusedNode, same(textInput));

      input.addKey(const TuiKeyEvent.character('a'));
      await Future<void>.delayed(Duration.zero);
      expect(textInput.value, 'a');

      input.addKey(const TuiKeyEvent.special(TuiSpecialKey.tab));
      await Future<void>.delayed(Duration.zero);
      expect(engine.focusedNode, same(select));

      input.addKey(const TuiKeyEvent.special(TuiSpecialKey.arrowDown));
      await Future<void>.delayed(Duration.zero);
      expect(select.selectedIndex, 1);

      await engine.dispose();
      await input.dispose();
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

  void addKey(TuiKeyEvent event) {
    _keyController.add(event);
  }

  Future<void> dispose() async {
    await _keyController.close();
    await _resizeController.close();
  }
}

final class _MemoryOutput implements TuiOutputSink {
  @override
  Future<void> present(TuiFrame frame) async {}
}
