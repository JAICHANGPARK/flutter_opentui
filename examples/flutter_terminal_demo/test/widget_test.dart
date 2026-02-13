import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_terminal_demo/main.dart';

void main() {
  testWidgets('demo renders controls', (WidgetTester tester) async {
    await tester.pumpWidget(const TerminalDemoApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Tab'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
  });
}
