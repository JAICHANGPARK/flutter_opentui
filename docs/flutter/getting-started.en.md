# Getting Started (Flutter)

Render terminal-style UI inside Flutter with `package:flutter_opentui`.

## 1. Install

```bash
flutter pub add flutter_opentui
```

## 2. Minimal example

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

## 3. Send input from touch/buttons

```dart
controller.sendSpecialKey(TuiSpecialKey.tab);
controller.sendCharacter('a');
controller.sendPaste('deploy --dry-run');
```

## 4. Next docs

- [OpenTuiView](./open-tui-view.md)
- [OpenTuiController & Input](./controller-input.md)
