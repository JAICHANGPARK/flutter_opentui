# Getting Started (Flutter)

`package:flutter_opentui`를 사용해 Flutter 화면에 터미널 스타일 UI를 렌더링합니다.

## 1. 설치

```bash
flutter pub add flutter_opentui
```

## 2. 최소 예제

```dart
import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: DemoScreen());
  }
}

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  final controller = OpenTuiController();

  late final TuiNode root =
      TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column, padding: 1)
        ..add(TuiText(id: 'title', text: 'Flutter OpenTUI'))
        ..add(TuiInput(id: 'input', placeholder: 'Type...'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: OpenTuiView(controller: controller, root: root),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## 3. 터치/버튼으로 입력 보내기

```dart
controller.sendSpecialKey(TuiSpecialKey.tab);
controller.sendCharacter('a');
controller.sendPaste('deploy --dry-run');
```

## 4. 다음 문서

- [OpenTuiView](./open-tui-view.md)
- [OpenTuiController & Input](./controller-input.md)
