# Getting Started (OpenTUI Dart)

このドキュメントは、`package:opentui` でターミナル UI を素早く起動する最小手順を説明します。

## 1. インストール

```bash
dart pub add opentui
```

## 2. 最小実行例

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

## 3. 次のステップ

- レイアウト: [core-concepts/layout.md](./core-concepts/layout.md)
- キー入力: [core-concepts/keyboard.md](./core-concepts/keyboard.md)
- 構成ヘルパー: [core-concepts/constructs.md](./core-concepts/constructs.md)
- コンポーネント: [components/README.md](./components/README.md)
