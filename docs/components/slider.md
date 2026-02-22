# Slider

범위값 선택 컴포넌트입니다.

## Construct

```dart
final slider = Slider(
  id: 'volume',
  min: 0,
  max: 100,
  value: 40,
  step: 5,
  width: 20,
);
```

## 기본 키 처리

- `ArrowLeft`, `ArrowDown`: 감소
- `ArrowRight`, `ArrowUp`: 증가
