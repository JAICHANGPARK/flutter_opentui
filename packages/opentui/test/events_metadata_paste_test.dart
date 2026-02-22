import 'dart:async';

import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Event metadata', () {
    test('key events keep old constructors and expose metadata aliases', () {
      const plain = TuiKeyEvent.character('a');
      expect(plain.character, 'a');
      expect(plain.alt, isFalse);
      expect(plain.meta, isFalse);
      expect(plain.option, isFalse);
      expect(plain.isCharacter, isTrue);
      expect(plain.isPaste, isFalse);

      const withMeta = TuiKeyEvent.character(
        'v',
        meta: true,
        name: 'v',
        sequence: '\x1bv',
      );
      expect(withMeta.alt, isTrue);
      expect(withMeta.meta, isTrue);
      expect(withMeta.option, isTrue);
      expect(withMeta.name, 'v');
      expect(withMeta.sequence, '\x1bv');
    });

    test(
      'paste events are represented and can be consumed by input nodes',
      () async {
        final inputSource = MemoryInputSource();
        final outputSink = _MemoryOutput();
        final engine = TuiEngine(
          inputSource: inputSource,
          outputSink: outputSink,
          viewportWidth: 20,
          viewportHeight: 3,
        );

        final input = TuiInput(id: 'input', width: 20, placeholder: '...');
        final root = TuiBox(id: 'root')..add(input);

        engine.mount(root);
        engine.render();

        inputSource.emitKey(TuiKeyEvent.paste('hello'));
        await Future<void>.delayed(Duration.zero);

        expect(input.value, 'hello');

        final paste = TuiKeyEvent.paste('abc');
        expect(paste.isPaste, isTrue);
        expect(paste.paste?.text, 'abc');

        await engine.dispose();
        await inputSource.dispose();
      },
    );
  });
}

final class _MemoryOutput implements TuiOutputSink {
  @override
  Future<void> present(TuiFrame frame) async {}
}
