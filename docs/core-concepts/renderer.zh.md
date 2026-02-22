# Renderer

`opentui` 的渲染入口是 `createCliRenderer()`。

## 核心对象

- `CliRenderer`: 管理 mount/render/theme/console
- `TuiEngine`: layout + paint + focus + key dispatch
- `TuiFrame`: 最终帧缓冲
- `TuiInputSource`, `TuiOutputSink`: 输入输出抽象

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
- `null`（自动检测）

```dart
final mode = detectThemeModeFromEnvironment();
renderer.setThemeMode(mode);
```

## 生命周期

```dart
renderer.mount(rootNode);
renderer.render();
await renderer.dispose();
```
