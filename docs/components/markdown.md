# Markdown

간단한 마크다운 텍스트를 표시합니다.

## Construct

```dart
final md = Markdown(
  id: 'md',
  markdown: '# Title\n- item',
);
```

## 참고

현재 구현은 경량 변환(헤딩/리스트/링크 단순화) 중심입니다.
