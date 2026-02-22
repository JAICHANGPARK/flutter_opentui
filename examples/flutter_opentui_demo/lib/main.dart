import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart' hide Text;

void main() {
  runApp(const OpenTuiDemoApp());
}

class OpenTuiDemoApp extends StatelessWidget {
  const OpenTuiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OpenTuiDemoScreen(),
    );
  }
}

class OpenTuiDemoScreen extends StatefulWidget {
  const OpenTuiDemoScreen({super.key});

  @override
  State<OpenTuiDemoScreen> createState() => _OpenTuiDemoScreenState();
}

class _OpenTuiDemoScreenState extends State<OpenTuiDemoScreen> {
  final OpenTuiController _controller = OpenTuiController();

  final OptimizedBuffer _statusBuffer = OptimizedBuffer(width: 34, height: 3)
    ..drawText(
      0,
      0,
      'Status: READY',
      style: const TuiStyle(foreground: TuiColor.green),
    )
    ..drawText(
      0,
      1,
      'Engine: flutter_opentui',
      style: const TuiStyle(foreground: TuiColor.cyan),
    )
    ..drawText(0, 2, 'All components mounted');

  late final TuiScrollBox _showcase =
      TuiScrollBox(
          id: 'showcase',
          border: true,
          title: 'All OpenTUI Components',
          height: 13,
          padding: 1,
          scrollStep: 1,
          fastScrollStep: 3,
          layoutDirection: TuiLayoutDirection.column,
        )
        ..add(
          TuiText(
            id: 'text',
            text: 'Text: OpenTUI component showcase inside one tree.',
            style: const TuiStyle(foreground: TuiColor.white),
          ),
        )
        ..add(
          TuiInput(
            id: 'input',
            height: 1,
            placeholder: 'Input: type with quick keys',
          ),
        )
        ..add(
          TuiTextarea(
            id: 'textarea',
            height: 3,
            value: 'Textarea line 1\nTextarea line 2\nTextarea line 3',
          ),
        )
        ..add(
          TuiSelect(
            id: 'select',
            height: 3,
            options: const <String>[
              'Select: Build',
              'Select: Test',
              'Select: Run',
            ],
          ),
        )
        ..add(
          TuiTabSelect(
            id: 'tab-select',
            height: 1,
            options: const <String>['TabSelect: Home', 'Logs', 'Metrics'],
          ),
        )
        ..add(
          TuiMarkdown(
            id: 'markdown',
            height: 2,
            markdown: '# Markdown\n- stripped heading and list',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(
          TuiCode(
            id: 'code',
            height: 2,
            code: 'Code: print("hello");',
            style: const TuiStyle(foreground: TuiColor.cyan),
          ),
        )
        ..add(
          TuiDiff(
            id: 'diff',
            height: 3,
            previous: 'port=3000\nmode=dev',
            next: 'port=8080\nmode=prod',
          ),
        )
        ..add(
          TuiLineNumber(
            id: 'line-number',
            height: 3,
            lines: const <String>['LineNumber alpha', 'LineNumber beta'],
          ),
        )
        ..add(
          TuiSlider(
            id: 'slider',
            height: 1,
            width: 24,
            value: 65,
            min: 0,
            max: 100,
            step: 5,
          ),
        )
        ..add(
          TuiScrollbar(
            id: 'scrollbar',
            height: 4,
            width: 1,
            value: 0.4,
            thumbRatio: 0.3,
          ),
        )
        ..add(
          TuiFrameBufferNode(
            id: 'frame-buffer',
            height: 3,
            buffer: _statusBuffer,
            transparent: true,
          ),
        );

  late final TuiNode _root =
      TuiBox(
          id: 'root',
          border: true,
          title: 'flutter_opentui demo',
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(
          TuiAsciiFont(
            id: 'ascii-font',
            text: 'OpenTUI',
            height: 5,
            style: const TuiStyle(foreground: TuiColor.cyan),
          ),
        )
        ..add(
          TuiText(
            id: 'header',
            text: 'Root Box + ScrollBox showcase (Tab cycles focus).',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(_showcase);

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
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _QuickInput(
                    label: 'Tab',
                    onTap: () => _controller.sendSpecialKey(TuiSpecialKey.tab),
                  ),
                  _QuickInput(
                    label: 'Up',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowUp),
                  ),
                  _QuickInput(
                    label: 'Down',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowDown),
                  ),
                  _QuickInput(
                    label: 'Left',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowLeft),
                  ),
                  _QuickInput(
                    label: 'Right',
                    onTap: () =>
                        _controller.sendSpecialKey(TuiSpecialKey.arrowRight),
                  ),
                  _QuickInput(
                    label: 'Paste',
                    onTap: () => _controller.sendPaste('deploy --dry-run'),
                  ),
                  _QuickInput(
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

class _QuickInput extends StatelessWidget {
  const _QuickInput({required this.label, required this.onTap});

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
