# Keyboard & Paste

`TuiEngine` dispatches key events to the currently focused node.

## Event types

- character: `TuiKeyEvent.character(...)`
- special: `TuiKeyEvent.special(...)`
- paste: `TuiKeyEvent.paste(...)`

## Special keys

- `tab`, `enter`, `backspace`, `escape`
- `arrowUp`, `arrowDown`, `arrowLeft`, `arrowRight`
- `ctrlC`

## Metadata fields

- `name`
- `sequence`
- `ctrl`, `alt`, `shift`, `meta`, `option`
- `paste` (`TuiPasteEvent`)

## Example

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

## Focus traversal

- `Tab`: move forward
- `Shift+Tab`: move backward
