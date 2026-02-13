import 'package:opentui_max/core.dart';
import 'package:opentui_max/solid.dart';
import 'package:test/test.dart';

void main() {
  test('solid signal change re-renders cli renderer', () async {
    final signal = createSignal<int>(0);

    final cli = await createCliRenderer(
      inputSource: MemoryInputSource(),
      outputSink: MemoryOutputSink(),
      width: 20,
      height: 5,
    );

    final solid = OpenTuiSolidRenderer(
      builder: () {
        return TuiText(id: 'counter', text: 'count=${signal.value}');
      },
    );

    final session = solid.render(
      cliRenderer: cli,
      watch: <SolidSignal<dynamic>>[signal],
    );

    final before = cli.frame!.cellAt(6, 0).char;
    signal.value = 1;

    final after = cli.frame!.cellAt(6, 0).char;

    expect(before, equals('0'));
    expect(after, equals('1'));

    session.dispose();
    await cli.dispose();
  });
}
