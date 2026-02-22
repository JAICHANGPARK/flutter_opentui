# flutter_opentui_demo

Component catalog example rendering all implemented OpenTUI node components:
- `TuiBox`, `TuiText`, `TuiInput`, `TuiTextarea`
- `TuiSelect`, `TuiTabSelect`
- `TuiMarkdown`, `TuiCode`, `TuiDiff`, `TuiLineNumber`
- `TuiSlider`, `TuiScrollbar`, `TuiScrollBox`
- `TuiAsciiFont`, `TuiFrameBufferNode`
- Touch input helpers (`sendSpecialKey`, `sendCharacter`, `sendPaste`)

Catalog UX:
- Left panel `Component Index` lists all components.
- Selecting an item auto-jumps the right `Component Preview` panel.
- `Prev` / `Next` quick buttons jump between components.

## Run

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui
dart run melos bootstrap
cd examples/flutter_opentui_demo
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
