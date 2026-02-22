# opentui

`opentui` is the core OpenTUI Dart package: it provides the node model,
layout/paint engine, frame and buffer primitives, and lightweight renderable
adapters for building CLI UIs.

## Features

- ANSI frame diff rendering.
- Basic row/column/absolute layout with optional `flexGrow`.
- Focus management and keyboard input.
- Core nodes/components:
  - `TuiBox`
  - `TuiText`
  - `TuiInput`
  - `TuiSelect`
  - `TuiTabSelect`
  - `TuiAsciiFont`
  - `TuiFrameBufferNode`
- Frame/buffer primitives: `TuiFrame`, `OptimizedBuffer`, `RGBA`,
  `parseColor(...)`.
- Lightweight renderables:
  - `BaseRenderable` / `Renderable`
  - `BoxRenderable`
  - `TextRenderable`
  - `InputRenderable`
  - `SelectRenderable`
  - `TabSelectRenderable`
  - `ASCIIFontRenderable`
  - `FrameBufferRenderable`
  - `GroupRenderable`

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
