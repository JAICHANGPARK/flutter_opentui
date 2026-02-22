# Text

단일/멀티라인 텍스트를 렌더링합니다.

## Construct

```dart
final text = Text(
  id: 'message',
  content: 'OpenTUI text',
  style: const TuiStyle(foreground: TuiColor.green),
);
```

## 참고

- `\n` 포함 시 멀티라인 출력
- `width`가 작으면 해당 영역만 그려짐
