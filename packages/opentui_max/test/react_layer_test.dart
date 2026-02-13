import 'package:opentui_max/react.dart';
import 'package:test/test.dart';

void main() {
  test('react renderer builds a box tree', () {
    final tree = box(
      props: const <String, Object?>{
        'border': true,
        'layoutDirection': 'column',
      },
      children: <Object?>[
        text('hello'),
        input(props: const <String, Object?>{'placeholder': 'name'}),
      ],
    );

    final renderer = OpenTuiReactRenderer();
    final result = renderer.render(tree);

    expect(result.root.id, startsWith('react_'));
    expect(result.root.children, hasLength(2));
  });
}
