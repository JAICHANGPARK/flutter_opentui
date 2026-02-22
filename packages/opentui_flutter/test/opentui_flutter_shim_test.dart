import 'package:flutter_test/flutter_test.dart';
import 'package:opentui_flutter/opentui_flutter.dart';

void main() {
  test('re-exports flutter_opentui APIs', () async {
    final controller = OpenTuiController();
    final root = TuiBox(id: 'root');

    expect(controller, isA<OpenTuiController>());
    expect(root, isA<TuiNode>());

    await controller.dispose();
  });
}
