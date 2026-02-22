# opentui

`opentui` is a pure Dart terminal UI engine inspired by OpenTUI. It includes a
node/render engine, renderables, declarative construct helpers, and a
`CliRenderer` wrapper for CLI-focused workflows.

## Features

- ANSI frame diff rendering with `TuiFrame` / `OptimizedBuffer`.
- Layout engine with `row` / `column` / `absolute`, `flexGrow`,
  `justify`/`align`, and percent sizing (`widthPercent` / `heightPercent`).
- Focus management and keyboard input with key metadata (`name`, `sequence`,
  `meta`, `option`) and paste event support.
- `CliRenderer` + `createCliRenderer()` with:
  - theme mode API (`ThemeMode.dark` / `ThemeMode.light` / `null`)
  - built-in console controller (`toggle`, position, size, entries, listeners)
- Core components and renderables:
  - `Box`, `Text`, `Input`, `Textarea`
  - `Select`, `TabSelect`, `Slider`, `Scrollbar`, `ScrollBox`
  - `Markdown`, `Code`, `Diff`, `LineNumber`
  - `ASCIIFont`, `FrameBuffer`
- Declarative construct helpers from `constructs.dart`:
  - `Box(...)`, `Text(...)`, `Input(...)`, `Markdown(...)`, etc.

## Install

```bash
dart pub add opentui
```

## Documentation

- Getting started: [`../../docs/getting-started.md`](../../docs/getting-started.md)
- Core concepts: [`../../docs/core-concepts`](../../docs/core-concepts)
- Components: [`../../docs/components`](../../docs/components)

## Example

```dart
import 'package:opentui/opentui.dart';

Future<void> main() async {
  final renderer = await createCliRenderer(width: 80, height: 24);

  final app = Box(
    id: 'app',
    layoutDirection: TuiLayoutDirection.column,
    padding: 1,
    children: <BaseRenderable>[
      Text(content: 'OpenTUI Dart'),
      Input(id: 'name', placeholder: 'Type here...'),
      Slider(id: 'volume', width: 20, value: 40),
    ],
  );

  renderer.mount(app.toNode());
  renderer.render();
}
```
