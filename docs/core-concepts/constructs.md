# Constructs (`delegate` / `instantiate`)

`opentui`의 construct helper(`Box`, `Text`, `Input` ...)는 Dart에서 **즉시 사용 가능한 Renderable 객체**를 반환합니다.

## 기본 사용

```dart
final app = Box(
  id: 'app',
  layoutDirection: TuiLayoutDirection.column,
  children: <BaseRenderable>[
    Text(content: 'Title'),
    Input(id: 'input', placeholder: 'Type...'),
  ],
);
```

## instantiate

기존 객체 또는 factory 함수를 안전하게 인스턴스화할 때 사용합니다.

```dart
final a = instantiate<BaseRenderable>(Box(id: 'root'));
final b = instantiate<BoxRenderable>(() => Box(id: 'factory-root'));
```

## delegate

외부 API 호출을 특정 자식 노드로 라우팅하고 싶을 때 사용합니다.

```dart
final delegated = delegate(
  <String, String>{'add': 'slot'},
  Box(
    id: 'root',
    children: <BaseRenderable>[Group(id: 'slot')],
  ),
);

delegated.add(Text(content: 'delegated child')); // slot에 추가됨
```

지원 유틸:

- `delegated.delegatedTarget('add')`
- `delegated.delegatedCall('add', (target) { ... })`

## 주의사항

- `delegate`는 맵에 없는 API는 루트 객체로 폴백합니다.
- construct helper 반환값은 `toNode()`로 엔진 트리에 붙일 수 있습니다.
