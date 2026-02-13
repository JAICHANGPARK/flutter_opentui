import 'package:opentui_max/core.dart';
import 'package:opentui_max/react.dart';

Future<void> main() async {
  final inputSource = MemoryInputSource();
  final outputSink = MemoryOutputSink();
  final cli = await createCliRenderer(
    inputSource: inputSource,
    outputSink: outputSink,
    width: 40,
    height: 10,
  );

  final tree = box(
    props: const <String, Object?>{
      'border': true,
      'title': 'react demo',
      'padding': 1,
      'layoutDirection': 'column',
    },
    children: <Object?>[
      text('hello from react-style layer'),
      input(props: const <String, Object?>{'placeholder': 'type...'}),
      select(options: const <String>['alpha', 'beta', 'gamma']),
    ],
  );

  final root = OpenTuiReactRenderer().render(tree).root;
  cli.mount(root);
  cli.render();

  final frame = cli.frame;
  if (frame != null) {
    print(AnsiRenderer().renderFull(frame));
  }

  await cli.dispose();
  await inputSource.dispose();
}
