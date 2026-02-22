# Console Overlay

`CliRenderer`는 내장 콘솔 오버레이를 제공합니다.

## 생성 옵션

```dart
final renderer = await createCliRenderer(
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## 런타임 제어

```dart
renderer.console.toggle();
renderer.console.open();
renderer.console.close();
renderer.console.focus();
renderer.console.blur();
renderer.console.setPosition(ConsolePosition.left);
renderer.console.setSizePercent(40);
renderer.console.log('message');
renderer.console.error('error');
```

## 키 동작 (기본)

- `` ` ``: 토글/포커스 전환
- `+` / `=`: 콘솔 크기 증가
- `-` / `_`: 콘솔 크기 감소
- `ArrowUp/ArrowLeft`: 위로 스크롤
- `ArrowDown/ArrowRight`: 아래로 스크롤
- `Shift + Arrow`: 가속 스크롤
- `Escape`: blur

## 스크롤 API

- `scrollOffset`
- `setScrollOffset(...)`
- `scrollBy(...)`
- `scrollToBottom()`

오버레이는 `CliRenderer`가 루트 프레임에 직접 합성합니다.
