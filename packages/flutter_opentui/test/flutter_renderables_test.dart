import 'package:flutter_opentui/flutter_opentui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('OpenTuiScrollBoxRenderable clips children by offset and limit', () {
    final scrollBox =
        OpenTuiScrollBoxRenderable(
            id: 'scroll',
            scrollOffset: 1,
            maxVisibleChildren: 2,
          )
          ..add(TextRenderable(id: 'line-1', content: 'one'))
          ..add(TextRenderable(id: 'line-2', content: 'two'))
          ..add(TextRenderable(id: 'line-3', content: 'three'));

    final node = scrollBox.toNode() as TuiBox;
    final childTexts = node.children
        .map((child) => (child as TuiText).text)
        .toList(growable: false);

    expect(childTexts, <String>['two', 'three']);
  });
}
