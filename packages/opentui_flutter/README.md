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
