# Console Overlay

`CliRenderer` 提供内置控制台覆盖层。

## 创建选项

```dart
final renderer = await createCliRenderer(
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## 运行时控制

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

## 默认按键行为

- `` ` ``: 切换显示/焦点
- `+` / `=`: 增大尺寸
- `-` / `_`: 减小尺寸
- `ArrowUp/ArrowLeft`: 向上滚动
- `ArrowDown/ArrowRight`: 向下滚动
- `Shift + Arrow`: 快速滚动
- `Escape`: blur

## 滚动 API

- `scrollOffset`
- `setScrollOffset(...)`
- `scrollBy(...)`
- `scrollToBottom()`
