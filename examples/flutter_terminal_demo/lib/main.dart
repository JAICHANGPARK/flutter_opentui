import 'package:flutter/material.dart';
import 'package:flutter_opentui/flutter_opentui.dart';

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

  late final TuiNode _root =
      TuiBox(
          id: 'root',
          title: 'OpenTUI Flutter Demo',
          border: true,
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(
          TuiText(
            id: 'title',
            text: 'Try keyboard or touch controls below.',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(TuiInput(id: 'search', placeholder: 'Type query...'))
        ..add(
          TuiSelect(
            id: 'select',
            options: const <String>['Dashboard', 'Logs', 'Settings', 'Exit'],
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
                    onTap: () => _sendSpecial(TuiSpecialKey.tab),
                  ),
                  _TouchKey(
                    label: '↑',
                    onTap: () => _sendSpecial(TuiSpecialKey.arrowUp),
                  ),
                  _TouchKey(
                    label: '↓',
                    onTap: () => _sendSpecial(TuiSpecialKey.arrowDown),
                  ),
                  _TouchKey(
                    label: '⌫',
                    onTap: () => _sendSpecial(TuiSpecialKey.backspace),
                  ),
                  _TouchKey(label: 'A', onTap: () => _controller.sendText('a')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendSpecial(TuiSpecialKey key) {
    _controller.sendKeyEvent(TuiKeyEvent.special(key));
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
