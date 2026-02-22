import 'package:flutter_test/flutter_test.dart';
import 'package:opentui_flutter/opentui_flutter.dart';

void main() {
  test('re-exports flutter_opentui APIs', () async {
    final controller = OpenTuiController();
    final root = TuiBox(id: 'root');
    final scrollBox = OpenTuiScrollBoxRenderable(id: 'scroll');

    expect(controller, isA<OpenTuiController>());
    expect(root, isA<TuiNode>());
    expect(scrollBox, isA<OpenTuiScrollBoxRenderable>());

    await controller.dispose();
  });
}
