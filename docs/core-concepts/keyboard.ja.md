# Keyboard & Paste

`TuiEngine` はフォーカス中のノードへキーイベントを配信します。

## イベント種類

- 文字: `TuiKeyEvent.character(...)`
- 特殊キー: `TuiKeyEvent.special(...)`
- 貼り付け: `TuiKeyEvent.paste(...)`

## 特殊キー

- `tab`, `enter`, `backspace`, `escape`
- `arrowUp`, `arrowDown`, `arrowLeft`, `arrowRight`
- `ctrlC`

## メタデータ

- `name`
- `sequence`
- `ctrl`, `alt`, `shift`, `meta`, `option`
- `paste` (`TuiPasteEvent`)

## 例

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

## フォーカス移動

- `Tab`: 次へ
- `Shift+Tab`: 前へ
