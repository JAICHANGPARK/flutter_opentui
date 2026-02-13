# opentui

`opentui` is a pure Dart terminal UI engine for CLI applications.

## Features

- ANSI frame diff rendering.
- Basic row/column/absolute layout.
- Focus management and keyboard input.
- Primitive components: `TuiText`, `TuiBox`, `TuiInput`, `TuiSelect`.

## Install

```bash
dart pub add opentui
```

## Example

```dart
import 'package:opentui/opentui.dart';

Future<void> main() async {
  final adapter = TerminalAdapter();
  final engine = TuiEngine(
    inputSource: adapter,
    outputSink: adapter,
    viewportWidth: 80,
    viewportHeight: 24,
  );

  final root = TuiBox(
    id: 'root',
    border: true,
    layoutDirection: TuiLayoutDirection.column,
  )
    ..add(TuiText(id: 'title', text: 'OpenTUI Dart'))
    ..add(TuiInput(id: 'input', placeholder: 'Type here...'));

  engine.mount(root);
  engine.render();
}
```
