# FrameBuffer

사전에 그려둔 버퍼를 노드로 출력합니다.

## Construct

```dart
final buffer = OptimizedBuffer(width: 20, height: 3)
  ..drawText(0, 0, 'Status: READY');

final frameNode = FrameBuffer(
  id: 'status',
  buffer: buffer,
  transparent: true,
);
```
