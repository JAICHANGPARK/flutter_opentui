# Keyboard & Paste

`TuiEngine` 会将按键事件分发给当前 focus 节点。

## 事件类型

- 字符事件: `TuiKeyEvent.character(...)`
- 特殊键事件: `TuiKeyEvent.special(...)`
- 粘贴事件: `TuiKeyEvent.paste(...)`

## 特殊键

- `tab`, `enter`, `backspace`, `escape`
- `arrowUp`, `arrowDown`, `arrowLeft`, `arrowRight`
- `ctrlC`

## 元数据字段

- `name`
- `sequence`
- `ctrl`, `alt`, `shift`, `meta`, `option`
- `paste` (`TuiPasteEvent`)

## 示例

```dart
inputSource.emitKey(
  const TuiKeyEvent.special(
    TuiSpecialKey.arrowDown,
    name: 'down',
    sequence: '\u001b[B',
  ),
);

inputSource.emitKey(
  TuiKeyEvent.paste('hello\nworld'),
);
```

## 焦点切换

- `Tab`: 向前切换
- `Shift+Tab`: 向后切换
