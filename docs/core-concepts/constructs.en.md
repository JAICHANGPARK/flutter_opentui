# Constructs (`delegate` / `instantiate`)

Construct helpers (`Box`, `Text`, `Input`, ...) return concrete renderable objects in Dart.

## Basic usage

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

Utilities:

- `delegated.delegatedTarget('add')`
- `delegated.delegatedCall('add', (target) { ... })`
