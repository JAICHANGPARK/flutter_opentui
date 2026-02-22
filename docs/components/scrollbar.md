# Scrollbar

트랙/썸 기반 스크롤 상태 표시/입력 컴포넌트입니다.

## Construct

```dart
final scrollbar = Scrollbar(
  id: 'bar',
  height: 8,
  value: 0.4,
  thumbRatio: 0.25,
  step: 0.05,
  fastStep: 0.2,
  vertical: true,
);
```

## 기본 키 처리

- `ArrowUp`, `ArrowLeft`: 감소
- `ArrowDown`, `ArrowRight`: 증가
- `Shift + Arrow`: `fastStep` 적용
