import 'package:flutter/material.dart';
import 'package:opentui_flutter/opentui_flutter.dart';

void main() {
  runApp(const OpenTuiExampleApp());
}

class OpenTuiExampleApp extends StatelessWidget {
  const OpenTuiExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ExampleScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  final OpenTuiController _controller = OpenTuiController();

  late final TuiNode _root =
      TuiBox(
          id: 'root',
          border: true,
          title: 'OpenTUI Flutter Plugin Example',
          layoutDirection: TuiLayoutDirection.column,
          padding: 1,
        )
        ..add(
          TuiText(
            id: 'header',
            text: 'Mobile/desktop friendly: use keyboard or on-screen controls',
            style: const TuiStyle(foreground: TuiColor.green),
          ),
        )
        ..add(TuiInput(id: 'search', placeholder: 'Type command...'))
        ..add(
          TuiSelect(
            id: 'menu',
            options: const <String>['Open', 'Run', 'Deploy', 'Exit'],
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  _KeyButton(
                    label: 'Tab',
                    onTap: () => _sendSpecial(TuiSpecialKey.tab),
                  ),
                  _KeyButton(
                    label: 'Up',
                    onTap: () => _sendSpecial(TuiSpecialKey.arrowUp),
                  ),
                  _KeyButton(
                    label: 'Down',
                    onTap: () => _sendSpecial(TuiSpecialKey.arrowDown),
                  ),
                  _KeyButton(
                    label: 'Backspace',
                    onTap: () => _sendSpecial(TuiSpecialKey.backspace),
                  ),
                  _KeyButton(
                    label: 'Type A',
                    onTap: () => _controller.sendText('a'),
                  ),
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

class _KeyButton extends StatelessWidget {
  const _KeyButton({required this.label, required this.onTap});

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
