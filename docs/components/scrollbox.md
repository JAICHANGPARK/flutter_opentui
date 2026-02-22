# ScrollBox

스크롤 가능한 컨테이너입니다.

## Construct

```dart
final scrollBox = ScrollBox(
  id: 'scroll',
  height: 6,
  border: true,
  scrollOffset: 0,
  scrollStep: 1,
  fastScrollStep: 5,
  children: <BaseRenderable>[
    Text(content: 'line 1'),
    Text(content: 'line 2'),
    Text(content: 'line 3'),
  ],
);
```

## 기본 키 처리

- `ArrowUp`, `ArrowLeft`: 위/왼쪽 방향 스크롤
- `ArrowDown`, `ArrowRight`: 아래/오른쪽 방향 스크롤
- `Shift + Arrow`: `fastScrollStep` 적용
