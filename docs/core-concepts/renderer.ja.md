# Renderer

`opentui` の描画エントリは `createCliRenderer()` です。

## 主要オブジェクト

- `CliRenderer`: mount/render/theme/console を管理
- `TuiEngine`: layout + paint + focus + key dispatch
- `TuiFrame`: 最終フレームバッファ
- `TuiInputSource`, `TuiOutputSink`: 入出力抽象

## createCliRenderer

```dart
final renderer = await createCliRenderer(
  inputSource: terminal,
  outputSink: terminal,
  width: 80,
  height: 24,
  themeMode: null,
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## Theme Mode

- `ThemeMode.dark`
- `ThemeMode.light`
- `null`（自動検出）

```dart
final mode = detectThemeModeFromEnvironment();
renderer.setThemeMode(mode);
```

## ライフサイクル

```dart
renderer.mount(rootNode);
renderer.render();
await renderer.dispose();
```
