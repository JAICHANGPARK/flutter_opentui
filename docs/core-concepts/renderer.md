# Renderer

`opentui`의 렌더 진입점은 `createCliRenderer()` 입니다.

## 핵심 객체

- `CliRenderer`: mount/render/theme/console 관리
- `TuiEngine`: layout + paint + focus + key dispatch
- `TuiFrame`: 최종 프레임 버퍼
- `TuiInputSource`, `TuiOutputSink`: 입출력 추상화

## createCliRenderer

```dart
final renderer = await createCliRenderer(
  inputSource: terminal,
  outputSink: terminal,
  width: 80,
  height: 24,
  themeMode: null, // null이면 환경 기반 자동 감지
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## Theme Mode

- `ThemeMode.dark`
- `ThemeMode.light`
- `null` (자동 감지)

자동 감지는 `detectThemeModeFromEnvironment()` 헬퍼를 통해 수행합니다.

```dart
final mode = detectThemeModeFromEnvironment();
renderer.setThemeMode(mode);
```

## 생명주기

```dart
renderer.mount(rootNode);
renderer.render();
await renderer.dispose();
```

`mount()`는 루트 트리를 설정하고, `render()`는 현재 상태를 한 프레임으로 출력합니다.
