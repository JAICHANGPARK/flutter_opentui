import 'dart:async';

import 'package:opentui/opentui.dart';

Future<void> main() async {
  final adapter = TerminalAdapter();
  final engine = TuiEngine(
    inputSource: adapter,
    outputSink: adapter,
    viewportWidth: 80,
    viewportHeight: 24,
  );

  var counter = 0;
  final counterText = TuiText(
    id: 'counter',
    text: 'Counter: 0',
    style: const TuiStyle(foreground: TuiColor.green, bold: true),
  );

  final root =
      TuiBox(
          id: 'root',
          title: 'OpenTUI Dart Counter',
          border: true,
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(counterText)
        ..add(
          TuiText(
            id: 'help',
            text: 'Use + / - to update counter. Tab to switch focus.',
            style: const TuiStyle(foreground: TuiColor.cyan),
          ),
        )
        ..add(TuiInput(id: 'input', placeholder: 'Type notes...'))
        ..add(
          TuiSelect(
            id: 'menu',
            options: const <String>['Open', 'Settings', 'Exit'],
          ),
        );

  engine.mount(root);
  await adapter.clear();
  engine.render();

  final done = Completer<void>();
  late final StreamSubscription<TuiKeyEvent> keySubscription;
  keySubscription = adapter.keyEvents.listen((event) {
    if (event.special == TuiSpecialKey.ctrlC) {
      if (!done.isCompleted) {
        done.complete();
      }
      return;
    }

    if (event.character == '+') {
      counter += 1;
      counterText.text = 'Counter: $counter';
      engine.render();
      return;
    }
    if (event.character == '-') {
      counter -= 1;
      counterText.text = 'Counter: $counter';
      engine.render();
    }
  });

  await done.future;
  await keySubscription.cancel();
  await engine.dispose();
  await adapter.dispose();
}
