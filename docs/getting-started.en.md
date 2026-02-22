# Getting Started (OpenTUI Dart)

This guide shows the minimum path to launch a terminal UI with `package:opentui`.

## 1. Install

```bash
dart pub add opentui
```

## 2. Minimal runnable example

```dart
import 'dart:io';

import 'package:opentui/opentui.dart';

Future<void> main() async {
  final terminal = TerminalAdapter();

  final renderer = await createCliRenderer(
    inputSource: terminal,
    outputSink: terminal,
    width: stdout.hasTerminal ? stdout.terminalColumns : 80,
    height: stdout.hasTerminal ? stdout.terminalLines : 24,
  );

  final app = Box(
    id: 'app',
    layoutDirection: TuiLayoutDirection.column,
    border: true,
    padding: 1,
    children: <BaseRenderable>[
      Text(id: 'title', content: 'OpenTUI Dart'),
      Input(id: 'input', placeholder: 'Type here...'),
      Slider(id: 'slider', width: 20, value: 40),
    ],
  );

  renderer.mount(app.toNode());
  renderer.render();

  await renderer.keyInput.keypress
      .firstWhere((event) => event.special == TuiSpecialKey.ctrlC);

  await renderer.dispose();
  await terminal.dispose();
}
```

## 3. Next steps

- Layout: [core-concepts/layout.md](./core-concepts/layout.md)
- Keyboard events: [core-concepts/keyboard.md](./core-concepts/keyboard.md)
- Declarative constructs: [core-concepts/constructs.md](./core-concepts/constructs.md)
- Components: [components/README.md](./components/README.md)
