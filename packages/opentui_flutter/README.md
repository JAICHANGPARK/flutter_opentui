# opentui_flutter

`opentui_flutter` is a Flutter plugin/widget adapter that renders `opentui` frames inside Flutter apps.

## Features

- `OpenTuiView` for terminal-like rendering.
- `OpenTuiController` to attach an engine and push key/text input.
- Works on Android, iOS, Web, macOS, Linux, and Windows.

## Install

```bash
flutter pub add opentui_flutter
```

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:opentui/opentui.dart';
import 'package:opentui_flutter/opentui_flutter.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final controller = OpenTuiController();

  @override
  Widget build(BuildContext context) {
    final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
      ..add(TuiText(id: 'title', text: 'OpenTUI Flutter'))
      ..add(TuiInput(id: 'input', placeholder: 'Type here...'));

    return OpenTuiView(controller: controller, root: root);
  }
}
```
