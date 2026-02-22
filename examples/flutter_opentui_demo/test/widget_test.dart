import 'package:flutter_opentui/flutter_opentui.dart';
import 'package:flutter_opentui_demo/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders OpenTuiView', (WidgetTester tester) async {
    await tester.pumpWidget(const OpenTuiDemoApp());

    expect(find.byType(OpenTuiView), findsOneWidget);
  });
}
