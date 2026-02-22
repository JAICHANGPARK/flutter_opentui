# Console Overlay

`CliRenderer` は内蔵コンソールオーバーレイを提供します。

## 生成オプション

```dart
final renderer = await createCliRenderer(
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## 実行時制御

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

## 既定キー操作

- `` ` ``: トグル/フォーカス切替
- `+` / `=`: サイズ拡大
- `-` / `_`: サイズ縮小
- `ArrowUp/ArrowLeft`: 上へスクロール
- `ArrowDown/ArrowRight`: 下へスクロール
- `Shift + Arrow`: 高速スクロール
- `Escape`: blur

## スクロール API

- `scrollOffset`
- `setScrollOffset(...)`
- `scrollBy(...)`
- `scrollToBottom()`
