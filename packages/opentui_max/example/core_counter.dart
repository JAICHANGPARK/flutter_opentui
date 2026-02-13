import 'package:opentui_max/core.dart';

Future<void> main() async {
  final input = MemoryInputSource();
  final output = MemoryOutputSink();
  final renderer = await createCliRenderer(
    inputSource: input,
    outputSink: output,
    width: 40,
    height: 8,
  );

  final root = TuiBox(id: 'root', border: true, padding: 1, title: 'counter');
  final counter = TuiText(id: 'counter', text: 'count: 0');
  root.add(counter);

  renderer.mount(root);
  renderer.render();

  for (var i = 1; i <= 3; i++) {
    counter.text = 'count: $i';
    renderer.render();
  }

  final frame = renderer.frame;
  if (frame != null) {
    final ansi = AnsiRenderer().renderFull(frame);
    print(ansi);
  }

  await renderer.dispose();
  await input.dispose();
}
