import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_opentui/flutter_opentui.dart';

void main() {
  test('controller forwards key events to input source', () async {
    final controller = OpenTuiController();
    final completer = Completer<TuiKeyEvent>();
    final subscription = controller.inputSource.keyEvents.listen((event) {
      if (!completer.isCompleted) {
        completer.complete(event);
      }
    });

    controller.sendKeyEvent(const TuiKeyEvent.character('k'));

    final captured = await completer.future.timeout(const Duration(seconds: 1));
    expect(captured.character, 'k');

    await subscription.cancel();
    await controller.dispose();
  });

  test('controller helper forwards special keys with modifiers', () async {
    final controller = OpenTuiController();
    final completer = Completer<TuiKeyEvent>();
    final subscription = controller.inputSource.keyEvents.listen((event) {
      if (!completer.isCompleted) {
        completer.complete(event);
      }
    });

    controller.sendSpecialKey(
      TuiSpecialKey.enter,
      ctrl: true,
      alt: true,
      shift: true,
    );

    final captured = await completer.future.timeout(const Duration(seconds: 1));
    expect(captured.special, TuiSpecialKey.enter);
    expect(captured.ctrl, isTrue);
    expect(captured.alt, isTrue);
    expect(captured.shift, isTrue);

    await subscription.cancel();
    await controller.dispose();
  });

  test(
    'controller sendPaste emits paste event and character key events',
    () async {
      final controller = OpenTuiController();
      final keys = <TuiKeyEvent>[];
      final keySubscription = controller.inputSource.keyEvents.listen(keys.add);
      final pasteCompleter = Completer<String>();
      final pasteSubscription = controller.inputSource.pasteEvents.listen((
        text,
      ) {
        if (!pasteCompleter.isCompleted) {
          pasteCompleter.complete(text);
        }
      });

      controller.sendPaste('ok');

      expect(
        await pasteCompleter.future.timeout(const Duration(seconds: 1)),
        'ok',
      );
      await Future<void>.delayed(Duration.zero);
      expect(keys.map((event) => event.character ?? '').join(), 'ok');

      await pasteSubscription.cancel();
      await keySubscription.cancel();
      await controller.dispose();
    },
  );

  test('controller forwards key metadata dispatch', () async {
    final controller = OpenTuiController();
    final completer = Completer<FlutterKeyDispatch>();
    final subscription = controller.inputSource.keyDispatches.listen((
      dispatch,
    ) {
      if (!completer.isCompleted) {
        completer.complete(dispatch);
      }
    });

    const metadata = FlutterKeyMetadata(
      character: 'A',
      logicalKeyLabel: 'A',
      logicalKeyId: 65,
      physicalKeyId: 4,
      isRepeat: true,
    );
    controller.sendCharacter('a', metadata: metadata);

    final dispatch = await completer.future.timeout(const Duration(seconds: 1));
    expect(dispatch.event.character, 'a');
    expect(dispatch.metadata, metadata);
    expect(dispatch.isFromPaste, isFalse);

    await subscription.cancel();
    await controller.dispose();
  });
}
