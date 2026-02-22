import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('Renderables', () {
    test('renderables convert into node trees with new component types', () {
      final buffer = OptimizedBuffer(width: 2, height: 1)..drawText(0, 0, 'fb');

      final root =
          BoxRenderable(
              id: 'root',
              layoutDirection: TuiLayoutDirection.column,
              border: true,
            )
            ..add(
              TabSelectRenderable(
                id: 'tabs',
                options: const <String>['one', 'two'],
                selectedIndex: 1,
              ),
            )
            ..add(ASCIIFontRenderable(id: 'ascii', content: 'dart'))
            ..add(FrameBufferRenderable(id: 'fb', buffer: buffer));

      final node = root.toNode() as TuiBox;
      expect(node.children, hasLength(3));
      expect(node.children[0], isA<TuiTabSelect>());
      expect(node.children[1], isA<TuiAsciiFont>());
      expect(node.children[2], isA<TuiFrameBufferNode>());

      final tabNode = node.children[0] as TuiTabSelect;
      expect(tabNode.selectedIndex, 1);

      final frameNode = node.children[2] as TuiFrameBufferNode;
      expect(frameNode.buffer, same(buffer));
    });

    test('group renderable behaves like a plain container box', () {
      final group = GroupRenderable(id: 'group')
        ..add(TextRenderable(id: 'text', content: 'hello'));

      final node = group.toNode() as TuiBox;
      expect(node.border, isFalse);
      expect(node.padding, 0);
      expect(node.children.single, isA<TuiText>());
    });

    test('renderable flexGrow maps to node flexGrow', () {
      final renderable = SelectRenderable(
        id: 'select',
        options: const <String>['a', 'b'],
        flexGrow: 3,
      );

      final node = renderable.toNode() as TuiSelect;
      expect(node.flexGrow, 3);
    });

    test('instantiate accepts existing renderables and factories', () {
      final node = Box(id: 'root');
      final instantiatedExisting = instantiate<BaseRenderable>(node);
      final instantiatedFactory = instantiate<BoxRenderable>(
        () => Box(id: 'from-factory'),
      );

      expect(identical(instantiatedExisting, node), isTrue);
      expect(instantiatedFactory.id, 'from-factory');
    });

    test('delegate routes add calls to mapped descendants', () {
      final delegated = delegate(
        <String, String>{'add': 'slot'},
        Box(
          id: 'root',
          children: <BaseRenderable>[Group(id: 'slot')],
        ),
      );

      delegated.add(Text(id: 'delegated-text', content: 'hello'));

      final slot = delegated.delegatedTarget('add');
      expect(slot, isNotNull);
      expect(slot!.id, 'slot');
      expect(slot.getChildren().single.id, 'delegated-text');
    });
  });
}
