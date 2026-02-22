# Input

단일 라인 입력 컴포넌트입니다.

## Construct

```dart
final input = Input(
  id: 'search',
  placeholder: 'Type query...',
  value: '',
);
```

## 기본 키 처리

- 문자 입력
- `Backspace`
- `ArrowLeft`, `ArrowRight`
- paste 이벤트 (`TuiKeyEvent.paste`)
