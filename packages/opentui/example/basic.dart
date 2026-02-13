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

  final root =
      TuiBox(
          id: 'root',
          border: true,
          title: 'OpenTUI Dart',
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(
          TuiText(
            id: 'help',
            text: 'Tab to switch focus. Type to edit. Arrow keys for select.',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(TuiInput(id: 'name', placeholder: 'Type your name...', height: 1))
        ..add(
          TuiSelect(
            id: 'menu',
            options: const <String>['Start', 'Settings', 'Exit'],
          ),
        );

  engine.mount(root);
  await adapter.clear();
  engine.render();

  await for (final event in adapter.keyEvents) {
    if (event.special == TuiSpecialKey.ctrlC) {
      break;
    }
  }

  await engine.dispose();
  await adapter.dispose();
}
