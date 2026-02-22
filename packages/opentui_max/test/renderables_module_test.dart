import 'package:opentui_max/core.dart';
import 'package:test/test.dart';

void main() {
  test('renderables convert into TuiNode trees', () {
    final root = BoxRenderable(
      id: 'root',
      border: const <TuiBorderSide>[TuiBorderSide.left],
      padding: 1,
      borderPreset: TuiBorderPreset.double,
      titleAlignment: TuiTitleAlignment.center,
    );
    root.add(TextRenderable(id: 'text', content: 'hello'));
    root.add(InputRenderable(id: 'input', placeholder: 'name'));

    final node = root.toNode();
    expect(node.id, equals('root'));
    expect(node.children, hasLength(2));
    expect((node as TuiBox).borderPreset, equals(TuiBorderPreset.double));
    expect(node.hasBorderLeft, isTrue);
    expect(node.hasBorderTop, isFalse);
    expect(node.titleAlignment, equals(TuiTitleAlignment.center));
  });

  test('diff renderable computes plus minus lines', () {
    final diff = DiffRenderable(previous: 'a\nb', next: 'a\nc');
    final node = diff.toNode() as TuiText;
    expect(node.text, contains('- b'));
    expect(node.text, contains('+ c'));
  });

  test('textarea renderable wires edit buffer and editor view', () {
    final textarea = TextareaRenderable();
    textarea.editBuffer.setText('abc');

    final node = textarea.toNode() as TuiText;
    expect(node.text, equals('abc'));
  });
}
