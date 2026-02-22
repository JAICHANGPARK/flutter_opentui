import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('OpenTuiView maps home/delete keys to OpenTUI specials', (
    WidgetTester tester,
  ) async {
    final controller = OpenTuiController();
    final input = TuiInput(id: 'input', width: 20, value: 'abcd');
    final root = TuiBox(id: 'root')..add(input);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 80,
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
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.home);
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();

    expect(input.value, 'bcd');
    expect(input.cursorPosition, 0);
  });

  testWidgets(
    'OpenTuiView pointer down maps to mouse and updates input cursor',
    (WidgetTester tester) async {
      final controller = OpenTuiController();
      final input = TuiInput(id: 'input', width: 20, value: 'hello');
      final root = TuiBox(id: 'root')..add(input);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 240,
              height: 80,
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
      await tester.tapAt(const Offset(26, 10));
      await tester.pump();

      expect(input.cursorPosition, 2);
    },
  );

  testWidgets('OpenTuiView pointer scroll maps to mouse scroll events', (
    WidgetTester tester,
  ) async {
    final controller = OpenTuiController();
    final select = TuiSelect(
      id: 'select',
      width: 20,
      options: const <String>['one', 'two', 'three'],
    );
    final root = TuiBox(id: 'root')..add(select);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            height: 80,
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
    await tester.sendEventToBinding(
      const PointerScrollEvent(
        position: Offset(15, 10),
        scrollDelta: Offset(0, 24),
      ),
    );
    await tester.pump();

    expect(select.selectedIndex, 1);
  });
}
