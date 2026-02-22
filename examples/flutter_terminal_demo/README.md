# flutter_terminal_demo

Flutter example using `flutter_opentui`.

For the full all-components catalog, use `examples/flutter_opentui_demo`.

Showcases:
- `TuiAsciiFont`
- `TuiTabSelect`
- `OpenTuiScrollBoxRenderable` (ScrollBox-style clipping)
- `TuiFrameBufferNode`
- `TuiInput` / `TuiSelect`
- Touch helpers via `sendSpecialKey`, `sendCharacter`, and `sendPaste`

## Run

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui
dart run melos bootstrap
cd examples/flutter_terminal_demo
flutter devices
```

macOS:

```bash
flutter run -d macos
```

iOS simulator:

```bash
flutter run -d ios
```

Android emulator/device:

```bash
flutter run -d android
```

Web (Chrome):

```bash
flutter run -d chrome
```

The demo supports both hardware keyboard input and touch controls.
