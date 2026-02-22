# Textarea

멀티라인 입력 컴포넌트입니다.

## Construct

```dart
final textarea = Textarea(
  id: 'editor',
  height: 5,
  value: 'line 1\nline 2',
);
```

## 기본 키 처리

- 문자 입력
- `Enter` 줄바꿈
- `Backspace`
- `ArrowLeft`, `ArrowRight`, `ArrowUp`, `ArrowDown`
- 커서 가시성 유지용 자동 스크롤
