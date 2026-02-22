import 'package:opentui/opentui.dart';
import 'package:test/test.dart';

void main() {
  group('CliRenderer', () {
    test('theme mode stream emits dark/light/null updates', () async {
      final renderer = await createCliRenderer(
        environment: const <String, String>{},
      );
      final events = <ThemeMode?>[];
      final subscription = renderer.onThemeMode(events.add);

      renderer.themeMode = ThemeMode.dark;
      renderer.themeMode = ThemeMode.light;
      renderer.themeMode = null;

      await Future<void>.delayed(Duration.zero);

      expect(events, <ThemeMode?>[ThemeMode.dark, ThemeMode.light, null]);

      await subscription.cancel();
      await renderer.dispose();
    });

    test('detectThemeModeFromEnvironment parses env hints', () {
      expect(
        detectThemeModeFromEnvironment(
          environment: <String, String>{'OPENTUI_THEME_MODE': 'dark'},
        ),
        ThemeMode.dark,
      );
      expect(
        detectThemeModeFromEnvironment(
          environment: <String, String>{'COLORFGBG': '15;0'},
        ),
        ThemeMode.dark,
      );
      expect(
        detectThemeModeFromEnvironment(
          environment: <String, String>{'COLORFGBG': '0;15'},
        ),
        ThemeMode.light,
      );
      expect(
        detectThemeModeFromEnvironment(
          environment: <String, String>{'ITERM_PROFILE': 'Solarized Light'},
        ),
        ThemeMode.light,
      );
      expect(
        detectThemeModeFromEnvironment(environment: const <String, String>{}),
        isNull,
      );
    });

    test(
      'createCliRenderer auto-detects theme when mode is not provided',
      () async {
        final renderer = await createCliRenderer(
          environment: <String, String>{'OPENTUI_THEME': 'light'},
        );

        expect(renderer.themeMode, ThemeMode.light);
        await renderer.dispose();
      },
    );

    test(
      'built-in console supports toggle, position, size, entries, and scroll',
      () async {
        final renderer = await createCliRenderer();
        final console = renderer.console;

        expect(console.isOpen, isFalse);
        expect(console.isFocused, isFalse);
        expect(console.scrollOffset, 0);

        console.toggle();
        expect(console.isOpen, isTrue);
        expect(console.isFocused, isTrue);

        console.blur();
        expect(console.isFocused, isFalse);

        console.toggle();
        expect(console.isOpen, isTrue);
        expect(console.isFocused, isTrue);

        console.toggle();
        expect(console.isOpen, isFalse);
        expect(console.isFocused, isFalse);

        console.setPosition(ConsolePosition.left);
        expect(console.position, ConsolePosition.left);

        console.setSizePercent(120);
        expect(console.sizePercent, 100);
        console.decreaseSize(95);
        expect(console.sizePercent, 10);

        console.log('hello');
        console.error('boom');
        console.scrollBy(1);

        expect(console.entries, hasLength(2));
        expect(console.entries.first.level, ConsoleLevel.log);
        expect(console.entries.last.level, ConsoleLevel.error);
        expect(console.scrollOffset, 1);

        await renderer.dispose();
      },
    );

    test(
      'console overlay appears in frame and keyboard controls toggle/focus/scroll/size',
      () async {
        final input = MemoryInputSource();
        final output = MemoryOutputSink();
        final renderer = await createCliRenderer(
          inputSource: input,
          outputSink: output,
          width: 32,
          height: 10,
          consolePosition: ConsolePosition.bottom,
          consoleSizePercent: 30,
        );

        renderer.mount(
          TuiBox(id: 'app', layoutDirection: TuiLayoutDirection.column)
            ..add(TuiText(id: 'app-text', text: 'APP')),
        );
        renderer.console.log('line-1');
        renderer.console.log('line-2');
        renderer.console.log('line-3');
        renderer.console.log('line-4');
        renderer.console.log('line-5');
        renderer.render();

        input.emitKey(const TuiKeyEvent.character('`'));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.isOpen, isTrue);
        expect(renderer.console.isFocused, isTrue);

        renderer.render();
        expect(_frameAsText(renderer.frame!), contains('line-5'));

        input.emitKey(const TuiKeyEvent.special(TuiSpecialKey.arrowUp));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.scrollOffset, 1);

        input.emitKey(const TuiKeyEvent.special(TuiSpecialKey.escape));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.isFocused, isFalse);
        expect(renderer.console.isOpen, isTrue);

        input.emitKey(const TuiKeyEvent.character('`'));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.isOpen, isTrue);
        expect(renderer.console.isFocused, isTrue);

        final beforeSize = renderer.console.sizePercent;
        input.emitKey(const TuiKeyEvent.character('+'));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.sizePercent, greaterThan(beforeSize));

        input.emitKey(const TuiKeyEvent.character('`'));
        await Future<void>.delayed(Duration.zero);
        expect(renderer.console.isOpen, isFalse);
        expect(renderer.console.isFocused, isFalse);

        await renderer.dispose();
      },
    );
  });
}

String _frameAsText(TuiFrame frame) {
  final lines = <String>[];
  for (var y = 0; y < frame.height; y++) {
    final buffer = StringBuffer();
    for (var x = 0; x < frame.width; x++) {
      buffer.write(frame.cellAt(x, y).char);
    }
    lines.add(buffer.toString());
  }
  return lines.join('\n');
}
