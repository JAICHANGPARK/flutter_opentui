# Keyboard & Paste

`TuiEngine`는 focus된 노드에 키 이벤트를 전달합니다.

## 이벤트 타입

- 문자: `TuiKeyEvent.character(...)`
- 특수키: `TuiKeyEvent.special(...)`
- 붙여넣기: `TuiKeyEvent.paste(...)`

## 특수키 enum

- `tab`, `enter`, `backspace`, `escape`
- `arrowUp`, `arrowDown`, `arrowLeft`, `arrowRight`
- `ctrlC`

## 메타데이터

`TuiKeyEvent`는 아래 필드를 제공합니다.

- `name`
- `sequence`
- `ctrl`, `alt`, `shift`, `meta`, `option`
- `paste` (`TuiPasteEvent`) 

## 예제

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

## 포커스 이동

기본적으로 `Tab`은 focusable 노드 사이를 순환합니다.

- `Shift+Tab` 역순 순환
- 현재 focus 노드의 `onKey`가 실제 입력 처리 수행
