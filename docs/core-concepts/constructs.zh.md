# Constructs (`delegate` / `instantiate`)

`Box`、`Text`、`Input` 等构造器在 Dart 中返回可直接使用的 Renderable 对象。

## 基本用法

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

工具方法:

- `delegated.delegatedTarget('add')`
- `delegated.delegatedCall('add', (target) { ... })`
