# Console Overlay

`CliRenderer` provides a built-in console overlay.

## Creation options

```dart
final renderer = await createCliRenderer(
  consolePosition: ConsolePosition.bottom,
  consoleSizePercent: 30,
  startConsoleOpen: false,
);
```

## Runtime control

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

## Default key behavior

- `` ` ``: toggle/focus switch
- `+` / `=`: increase size
- `-` / `_`: decrease size
- `ArrowUp/ArrowLeft`: scroll up
- `ArrowDown/ArrowRight`: scroll down
- `Shift + Arrow`: fast scroll
- `Escape`: blur

## Scroll API

- `scrollOffset`
- `setScrollOffset(...)`
- `scrollBy(...)`
- `scrollToBottom()`
