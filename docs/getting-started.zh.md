# Getting Started (OpenTUI Dart)

本文档说明如何使用 `package:opentui` 以最小步骤快速启动终端 UI。

## 1. 安装

```bash
dart pub add opentui
```

## 2. 最小可运行示例

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

## 3. 下一步

- 布局: [core-concepts/layout.md](./core-concepts/layout.md)
- 键盘事件: [core-concepts/keyboard.md](./core-concepts/keyboard.md)
- 声明式构造器: [core-concepts/constructs.md](./core-concepts/constructs.md)
- 组件总览: [components/README.md](./components/README.md)
