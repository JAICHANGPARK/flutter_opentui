import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart' hide Text;

void main() {
  runApp(const TerminalDemoApp());
}

class TerminalDemoApp extends StatelessWidget {
  const TerminalDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TerminalDemoScreen(),
    );
  }
}

class TerminalDemoScreen extends StatefulWidget {
  const TerminalDemoScreen({super.key});

  @override
  State<TerminalDemoScreen> createState() => _TerminalDemoScreenState();
}

class _TerminalDemoScreenState extends State<TerminalDemoScreen> {
  final OpenTuiController _controller = OpenTuiController();
  final OptimizedBuffer _statusBuffer = OptimizedBuffer(width: 32, height: 3)
    ..drawText(
      0,
      0,
      'status : online',
      style: const TuiStyle(foreground: TuiColor.green),
    )
    ..drawText(
      0,
      1,
      'layout : mobile/desktop',
      style: const TuiStyle(foreground: TuiColor.cyan),
    )
    ..drawText(0, 2, 'input  : keyboard + touch');

  late final OpenTuiScrollBoxRenderable _activityLog =
      OpenTuiScrollBoxRenderable(
          id: 'activity',
          border: true,
          title: 'ScrollBox',
          height: 5,
          scrollOffset: 1,
          maxVisibleChildren: 3,
        )
        ..add(TextRenderable(id: 'line-1', content: '[00:01] app started'))
        ..add(TextRenderable(id: 'line-2', content: '[00:02] input attached'))
        ..add(TextRenderable(id: 'line-3', content: '[00:03] frame ready'))
        ..add(TextRenderable(id: 'line-4', content: '[00:04] awaiting input'));

  late final TuiNode _root =
      TuiBox(
          id: 'root',
          title: 'OpenTUI Flutter Demo',
          border: true,
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(
          TuiAsciiFont(
            id: 'logo',
            text: 'OpenTUI',
            height: 5,
            style: const TuiStyle(foreground: TuiColor.cyan),
          ),
        )
        ..add(
          TuiTabSelect(
            id: 'tabs',
            height: 1,
            options: const <String>['Dashboard', 'Logs', 'Settings'],
          ),
        )
        ..add(
          TuiText(
            id: 'title',
            text: 'Try keyboard or touch controls below.',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(_activityLog.toNode())
        ..add(TuiInput(id: 'search', placeholder: 'Type query...'))
        ..add(
          TuiSelect(
            id: 'select',
            options: const <String>['Run', 'Inspect', 'Deploy', 'Exit'],
          ),
        )
        ..add(
          TuiFrameBufferNode(
            id: 'status',
            height: 3,
            buffer: _statusBuffer,
            transparent: true,
          ),
        );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: OpenTuiView(controller: _controller, root: _root),
            ),
            Container(
              color: Colors.grey.shade900,
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: <Widget>[
                  _TouchKey(
                    label: 'Tab',
                    onTap: () => _controller.sendSpecialKey(TuiSpecialKey.tab),
                  ),
                  _TouchKey(
                    label: '↑',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowUp),
                  ),
                  _TouchKey(
                    label: '↓',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowDown),
                  ),
                  _TouchKey(
                    label: '←',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowLeft),
                  ),
                  _TouchKey(
                    label: '→',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowRight),
                  ),
                  _TouchKey(
                    label: '⌫',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.backspace),
                  ),
                  _TouchKey(
                    label: 'Paste',
                    onTap: () => _controller.sendPaste('deploy --dry-run'),
                  ),
                  _TouchKey(
                    label: 'A',
                    onTap: () => _controller.sendCharacter('a'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _TouchKey extends StatelessWidget {
  const _TouchKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
      ),
      child: Text(label),
    );
  }
}
