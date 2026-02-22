# TabSelect

가로 탭 선택 UI입니다.

## Construct

```dart
final tabs = TabSelect(
  id: 'tabs',
  options: const <String>['Home', 'Logs', 'Settings'],
  selectedIndex: 0,
  separator: ' | ',
);
```

## 기본 키 처리

- `ArrowLeft`, `ArrowRight`
- `ArrowUp`, `ArrowDown`
