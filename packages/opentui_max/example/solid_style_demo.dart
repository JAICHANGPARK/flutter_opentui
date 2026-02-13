import 'package:opentui_max/core.dart';
import 'package:opentui_max/solid.dart';

Future<void> main() async {
  final count = createSignal<int>(0);

  final cli = await createCliRenderer(
    inputSource: MemoryInputSource(),
    outputSink: MemoryOutputSink(),
    width: 40,
    height: 8,
  );

  final solid = OpenTuiSolidRenderer(
    builder: () {
      final root = TuiBox(id: 'root', border: true, title: 'solid demo');
      root.add(TuiText(id: 'value', text: 'count=${count.value}'));
      return root;
    },
  );

  final session = solid.render(
    cliRenderer: cli,
    watch: <SolidSignal<dynamic>>[count],
  );

  count.value = 1;
  count.value = 2;

  final frame = cli.frame;
  if (frame != null) {
    print(AnsiRenderer().renderFull(frame));
  }

  session.dispose();
  await cli.dispose();
}
