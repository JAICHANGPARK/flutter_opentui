import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_opentui/flutter_opentui.dart';

void main() {
  testWidgets('OpenTuiView updates viewport from layout constraints', (
    WidgetTester tester,
  ) async {
    final controller = OpenTuiController();
    final root = TuiBox(id: 'root')..add(TuiInput(id: 'input', width: 10));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 120,
            height: 48,
            child: OpenTuiView(
              controller: controller,
              root: root,
              cellWidth: 12,
              cellHeight: 12,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(controller.engine, isNotNull);
    expect(controller.engine!.viewportWidth, 10);
    expect(controller.engine!.viewportHeight, 4);
  });

  testWidgets('OpenTuiView receives re-render when controller sends text', (
    WidgetTester tester,
  ) async {
    final controller = OpenTuiController();
    final input = TuiInput(id: 'input', width: 20);
    final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column)
      ..add(input);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 100,
            child: OpenTuiView(
              controller: controller,
              root: root,
              cellWidth: 10,
              cellHeight: 20,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    final before = controller.latestFrame;
    expect(before, isNotNull);

    controller.sendText('a');
    await tester.pump();

    final after = controller.latestFrame;
    expect(after, isNotNull);
    expect(after, isNot(same(before)));
    expect(input.value, 'a');
  });
}
