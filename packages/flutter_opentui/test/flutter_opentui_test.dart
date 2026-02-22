import 'package:flutter_opentui/flutter_opentui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exports OpenTui APIs from opentui and flutter_opentui', () async {
    final controller = OpenTuiController();
    final root = TuiBox(id: 'root', layoutDirection: TuiLayoutDirection.column);

    expect(controller, isA<OpenTuiController>());
    expect(root, isA<TuiNode>());

    await controller.dispose();
  });
}
