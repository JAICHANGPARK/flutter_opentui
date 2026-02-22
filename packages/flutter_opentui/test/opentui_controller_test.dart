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
}
