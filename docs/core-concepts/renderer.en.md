# Renderer

The rendering entry point of `opentui` is `createCliRenderer()`.

## Core objects

- `CliRenderer`: manages mount/render/theme/console
- `TuiEngine`: layout + paint + focus + key dispatch
- `TuiFrame`: final frame buffer
- `TuiInputSource`, `TuiOutputSink`: input/output abstraction

## createCliRenderer

```dart
final renderer = await createCliRenderer(
  inputSource: terminal,
  outputSink: terminal,
  width: 80,
  height: 24,
  themeMode: null, // auto-detect from environment when null
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## Theme Mode

- `ThemeMode.dark`
- `ThemeMode.light`
- `null` (auto detect)

```dart
final mode = detectThemeModeFromEnvironment();
renderer.setThemeMode(mode);
```

## Lifecycle

```dart
renderer.mount(rootNode);
renderer.render();
await renderer.dispose();
```
