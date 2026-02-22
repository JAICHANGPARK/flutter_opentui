# flutter_opentui

`flutter_opentui` is the canonical Flutter plugin for OpenTUI.

It contains:
- Flutter rendering/widget adapter APIs (`OpenTuiView`, `OpenTuiController`)
- Flutter input/output bridges for the `opentui` engine
- Native plugin registration stubs for Android, iOS, Web, macOS, Linux, and Windows
- OpenTUI-style components from `opentui` (`TuiBox`, `TuiText`, `TuiInput`, `TuiTextarea`, `TuiSelect`, `TuiTabSelect`, `TuiMarkdown`, `TuiCode`, `TuiDiff`, `TuiLineNumber`, `TuiSlider`, `TuiScrollbar`, `TuiScrollBox`, `TuiAsciiFont`, `TuiFrameBufferNode`)
- Flutter-facing extras (`OpenTuiScrollBoxRenderable`, key metadata + paste helpers)

For legacy compatibility, `opentui_flutter` now re-exports this package.

## Install

```bash
flutter pub add flutter_opentui
```

## Documentation

- Flutter getting started: [`../../docs/flutter/getting-started.md`](../../docs/flutter/getting-started.md)
- OpenTuiView: [`../../docs/flutter/open-tui-view.md`](../../docs/flutter/open-tui-view.md)
- Controller and input bridge: [`../../docs/flutter/controller-input.md`](../../docs/flutter/controller-input.md)
- Core/OpenTUI docs index: [`../../docs/README.md`](../../docs/README.md)

## Quickstart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: Demo());
  }
}

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final controller = OpenTuiController();
  final statusBuffer = OptimizedBuffer(width: 28, height: 3)
    ..drawText(0, 0, 'Status: READY')
    ..drawText(0, 1, 'Mode  : DEMO')
    ..drawText(0, 2, 'FPS   : 60');

  late final activityLog = OpenTuiScrollBoxRenderable(
    id: 'activity',
    border: true,
    title: 'ScrollBox',
    height: 5,
    scrollOffset: 1,
    maxVisibleChildren: 3,
  )
    ..add(TextRenderable(id: 'log-1', content: '[00:01] boot complete'))
    ..add(TextRenderable(id: 'log-2', content: '[00:02] sync services'))
    ..add(TextRenderable(id: 'log-3', content: '[00:03] hot reload'))
    ..add(TextRenderable(id: 'log-4', content: '[00:04] ready'));

  late final root =
      TuiBox(
        id: 'root',
        border: true,
        title: 'OpenTUI Flutter',
        layoutDirection: TuiLayoutDirection.column,
        padding: 1,
      )
        ..add(TuiAsciiFont(id: 'logo', text: 'OpenTUI', height: 5))
        ..add(TuiTabSelect(id: 'tabs', options: const ['Home', 'Logs', 'Settings']))
        ..add(activityLog.toNode())
        ..add(TuiInput(id: 'input', placeholder: 'Type here...'))
        ..add(TuiFrameBufferNode(id: 'status', height: 3, buffer: statusBuffer))
        ..add(TuiText(id: 'title', text: 'OpenTUI Flutter'));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: OpenTuiView(controller: controller, root: root)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

## Input Helpers

`OpenTuiController` keeps existing APIs and adds helper sends for richer input:

```dart
controller.sendSpecialKey(TuiSpecialKey.tab, shift: true);
controller.sendCharacter('k', ctrl: true);
controller.sendPaste('deploy --dry-run');
```
