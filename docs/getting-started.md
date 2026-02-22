# Getting Started (OpenTUI Dart)

이 문서는 `package:opentui`를 사용해 터미널 UI를 빠르게 띄우는 최소 경로를 설명합니다.

## 1. 설치

```bash
dart pub add opentui
```

## 2. 최소 실행 예제

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

  // Ctrl+C 종료까지 대기
  await renderer.keyInput.keypress
      .firstWhere((event) => event.special == TuiSpecialKey.ctrlC);

  await renderer.dispose();
  await terminal.dispose();
}
```

## 3. 다음 단계

- 레이아웃: [core-concepts/layout.md](./core-concepts/layout.md)
- 입력 이벤트: [core-concepts/keyboard.md](./core-concepts/keyboard.md)
- 선언형 조합: [core-concepts/constructs.md](./core-concepts/constructs.md)
- 컴포넌트 전체: [components/README.md](./components/README.md)
