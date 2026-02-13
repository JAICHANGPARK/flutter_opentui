import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:opentui_flutter_example/main.dart';

void main() {
  testWidgets('example app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenTuiExampleApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Tab'), findsOneWidget);
  });
}
