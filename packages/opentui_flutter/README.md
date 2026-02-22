# opentui_flutter

`opentui_flutter` is a compatibility shim.

It re-exports `package:flutter_opentui/flutter_opentui.dart` so existing apps can
migrate without immediate import breaks.

## New Apps

Use `flutter_opentui` directly:

```bash
flutter pub add flutter_opentui
```

```dart
import 'package:flutter_opentui/flutter_opentui.dart';
```

## Existing Apps

You can keep:

```dart
import 'package:opentui_flutter/opentui_flutter.dart';
```

but new development should target `flutter_opentui`.

## API Surface

This shim re-exports the full `flutter_opentui` API, including:
- `OpenTuiView`, `OpenTuiController`, `FlutterInputSource`, `FlutterOutputSink`
- Core `opentui` nodes/components (`TuiTabSelect`, `TuiAsciiFont`, `TuiFrameBufferNode`, etc.)
- New Flutter input helpers (`sendSpecialKey`, `sendCharacter`, `sendPaste`) and key metadata dispatch support
