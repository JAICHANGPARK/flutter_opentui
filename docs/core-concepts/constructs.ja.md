# Constructs (`delegate` / `instantiate`)

`Box`, `Text`, `Input` などの construct helper は Dart で即利用可能な Renderable を返します。

## 基本使用

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

```dart
final a = instantiate<BaseRenderable>(Box(id: 'root'));
final b = instantiate<BoxRenderable>(() => Box(id: 'factory-root'));
```

## delegate

```dart
final delegated = delegate(
  <String, String>{'add': 'slot'},
  Box(
    id: 'root',
    children: <BaseRenderable>[Group(id: 'slot')],
  ),
);

delegated.add(Text(content: 'delegated child'));
```

ユーティリティ:

- `delegated.delegatedTarget('add')`
- `delegated.delegatedCall('add', (target) { ... })`
