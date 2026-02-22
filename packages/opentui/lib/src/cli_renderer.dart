import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'console.dart';
import 'engine.dart';
import 'events.dart';
import 'frame.dart';
import 'node.dart';

enum ThemeMode { dark, light }

/// Detects terminal theme from environment variables.
///
/// This is a fallback heuristic for runtimes where DEC 2031 color-scheme
/// updates are unavailable. Returns `null` when no signal is detected.
ThemeMode? detectThemeModeFromEnvironment({Map<String, String>? environment}) {
  final env = environment ?? Platform.environment;

  final explicit = _parseThemeHint(
    env['OPENTUI_THEME_MODE'] ??
        env['OPENTUI_THEME'] ??
        env['TUI_THEME_MODE'] ??
        env['TUI_THEME'] ??
        env['TERM_THEME'] ??
        env['TERMINAL_THEME'],
  );
  if (explicit != null) {
    return explicit;
  }

  final colorFgBg = _detectFromColorFgBg(env['COLORFGBG']);
  if (colorFgBg != null) {
    return colorFgBg;
  }

  for (final key in _themeHintKeys) {
    final hint = _parseThemeHint(env[key]);
    if (hint != null) {
      return hint;
    }
  }

  return null;
}

const List<String> _themeHintKeys = <String>[
  'VSCODE_THEME_KIND',
  'VSCODE_COLOR_THEME',
  'WT_PROFILE_NAME',
  'ITERM_PROFILE',
  'TERM_PROGRAM',
  'TERM',
];

ThemeMode? _parseThemeHint(String? rawValue) {
  if (rawValue == null) {
    return null;
  }
  final normalized = rawValue.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }

  const darkTokens = <String>{'dark', 'night', 'dim', 'dracula', 'monokai'};
  const lightTokens = <String>{'light', 'day', 'bright', 'solarized light'};

  if (darkTokens.contains(normalized)) {
    return ThemeMode.dark;
  }
  if (lightTokens.contains(normalized)) {
    return ThemeMode.light;
  }
  if (normalized.contains('dark') || normalized.contains('night')) {
    return ThemeMode.dark;
  }
  if (normalized.contains('light') || normalized.contains('day')) {
    return ThemeMode.light;
  }
  return null;
}

ThemeMode? _detectFromColorFgBg(String? rawValue) {
  if (rawValue == null || rawValue.isEmpty) {
    return null;
  }
  final matches = RegExp(r'\d+').allMatches(rawValue);
  if (matches.isEmpty) {
    return null;
  }
  final backgroundIndex = int.tryParse(matches.last.group(0)!);
  if (backgroundIndex == null) {
    return null;
  }
  if (backgroundIndex <= 7) {
    return ThemeMode.dark;
  }
  return ThemeMode.light;
}

final class TuiKeyInput {
  TuiKeyInput(Stream<TuiKeyEvent> source) {
    _subscription = source.listen((event) {
      if (event.isPaste) {
        _pasteController.add(event.paste!);
        return;
      }
      _keyPressController.add(event);
    });
  }

  late final StreamSubscription<TuiKeyEvent> _subscription;
  final StreamController<TuiKeyEvent> _keyPressController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiPasteEvent> _pasteController =
      StreamController<TuiPasteEvent>.broadcast();

  Stream<TuiKeyEvent> get keypress => _keyPressController.stream;

  Stream<TuiPasteEvent> get paste => _pasteController.stream;

  StreamSubscription<TuiKeyEvent> onKeyPress(
    void Function(TuiKeyEvent event) listener,
  ) {
    return keypress.listen(listener);
  }

  StreamSubscription<TuiPasteEvent> onPaste(
    void Function(TuiPasteEvent event) listener,
  ) {
    return paste.listen(listener);
  }

  Future<void> dispose() async {
    await _subscription.cancel();
    await _keyPressController.close();
    await _pasteController.close();
  }
}

final class CliRenderer {
  CliRenderer({
    required this.engine,
    required this.root,
    required this.keyInput,
    required this.console,
    ThemeMode? themeMode,
  }) : _themeMode = themeMode ?? detectThemeModeFromEnvironment() {
    _previousConsoleSnapshot = console.snapshot;
    _consoleSubscription = console.addListener(_handleConsoleSnapshot);
    _keyPressSubscription = keyInput.onKeyPress(_handleKeyPress);
  }

  final TuiEngine engine;
  final TuiBox root;
  final TuiKeyInput keyInput;
  final OpenTuiConsole console;

  final StreamController<ThemeMode?> _themeModeController =
      StreamController<ThemeMode?>.broadcast();

  ThemeMode? _themeMode;
  TuiNode? _mountedNode;
  TuiBox? _consoleNode;
  int _consoleWidth = 0;
  int _consoleHeight = 0;

  late ConsoleSnapshot _previousConsoleSnapshot;
  late final StreamSubscription<ConsoleSnapshot> _consoleSubscription;
  late final StreamSubscription<TuiKeyEvent> _keyPressSubscription;

  TuiFrame? get frame => engine.lastFrame;

  ThemeMode? get themeMode => _themeMode;

  Stream<ThemeMode?> get themeModeChanges => _themeModeController.stream;

  StreamSubscription<ThemeMode?> onThemeMode(
    void Function(ThemeMode? mode) listener,
  ) {
    return themeModeChanges.listen(listener);
  }

  set themeMode(ThemeMode? value) {
    if (_themeMode == value) {
      return;
    }
    _themeMode = value;
    if (!_themeModeController.isClosed) {
      _themeModeController.add(value);
    }
    if (_mountedNode != null && console.isOpen) {
      _recomposeRoot(mountOnEngine: true);
    }
  }

  void setThemeMode(ThemeMode? value) {
    themeMode = value;
  }

  void render() => engine.render();

  void mount(TuiNode node) {
    _mountedNode = node;
    _recomposeRoot(mountOnEngine: true);
  }

  Future<void> dispose() async {
    await _keyPressSubscription.cancel();
    await _consoleSubscription.cancel();
    await keyInput.dispose();
    await _themeModeController.close();
    await console.dispose();
    await engine.dispose();
  }

  void _handleKeyPress(TuiKeyEvent event) {
    final character = event.character;
    if (!event.ctrl && !event.alt && character == '`') {
      console.toggle();
      return;
    }

    if (!console.isOpen) {
      return;
    }

    if (!event.ctrl && !event.alt) {
      if (character == '+' || character == '=') {
        console.increaseSize();
        return;
      }
      if (character == '-' || character == '_') {
        console.decreaseSize();
        return;
      }
    }

    if (!console.isFocused) {
      return;
    }

    if (event.special == TuiSpecialKey.escape) {
      console.blur();
      return;
    }

    final scrollStep = event.shift ? 5 : 1;
    if (event.special == TuiSpecialKey.arrowUp ||
        event.special == TuiSpecialKey.arrowLeft) {
      console.scrollBy(scrollStep, maxOffset: _maxConsoleScrollOffset());
      return;
    }
    if (event.special == TuiSpecialKey.arrowDown ||
        event.special == TuiSpecialKey.arrowRight) {
      console.scrollBy(-scrollStep, maxOffset: _maxConsoleScrollOffset());
    }
  }

  void _handleConsoleSnapshot(ConsoleSnapshot snapshot) {
    final structureChanged = _didConsoleStructureChange(
      _previousConsoleSnapshot,
      snapshot,
    );
    _previousConsoleSnapshot = snapshot;

    if (_mountedNode == null) {
      return;
    }

    if (structureChanged) {
      _recomposeRoot(mountOnEngine: true);
    } else {
      _syncConsoleEntries();
    }
    engine.render();
  }

  bool _didConsoleStructureChange(
    ConsoleSnapshot previous,
    ConsoleSnapshot next,
  ) {
    return previous.isOpen != next.isOpen ||
        previous.isFocused != next.isFocused ||
        previous.position != next.position ||
        previous.sizePercent != next.sizePercent;
  }

  void _recomposeRoot({required bool mountOnEngine}) {
    root.children.clear();
    _consoleNode = null;
    _consoleWidth = 0;
    _consoleHeight = 0;

    final mountedNode = _mountedNode;
    if (mountedNode == null) {
      if (mountOnEngine) {
        engine.mount(root);
      }
      return;
    }

    final viewport = TuiBox(
      id: 'cli-renderer-viewport',
      layoutDirection: TuiLayoutDirection.absolute,
      width: engine.viewportWidth,
      height: engine.viewportHeight,
    );

    final layout = _computeLayout(
      width: math.max(0, engine.viewportWidth),
      height: math.max(0, engine.viewportHeight),
      consoleOpen: console.isOpen,
      consolePosition: console.position,
      consoleSizePercent: console.sizePercent,
    );

    final contentHost = TuiBox(
      id: 'cli-renderer-content',
      left: layout.content.x,
      top: layout.content.y,
      width: layout.content.width,
      height: layout.content.height,
      layoutDirection: TuiLayoutDirection.column,
    )..add(mountedNode);

    if (!console.isOpen) {
      viewport.add(contentHost);
      root.add(viewport);
      if (mountOnEngine) {
        engine.mount(root);
      }
      return;
    }

    final consoleHost = TuiBox(
      id: 'cli-renderer-console',
      left: layout.console.x,
      top: layout.console.y,
      width: layout.console.width,
      height: layout.console.height,
      border: true,
      title: console.isFocused ? 'Console (focused)' : 'Console',
      layoutDirection: TuiLayoutDirection.column,
      style: _consolePanelStyle(),
      borderStyle: _consoleBorderStyle(),
    );

    _consoleNode = consoleHost;
    _consoleWidth = layout.console.width;
    _consoleHeight = layout.console.height;

    if (console.isFocused) {
      viewport
        ..add(consoleHost)
        ..add(contentHost);
    } else {
      viewport
        ..add(contentHost)
        ..add(consoleHost);
    }

    root.add(viewport);
    _syncConsoleEntries();
    if (mountOnEngine) {
      engine.mount(root);
    }
  }

  _RendererLayout _computeLayout({
    required int width,
    required int height,
    required bool consoleOpen,
    required ConsolePosition consolePosition,
    required int consoleSizePercent,
  }) {
    if (!consoleOpen) {
      return _RendererLayout(
        content: _Bounds(x: 0, y: 0, width: width, height: height),
        console: _Bounds(x: 0, y: 0, width: 0, height: 0),
      );
    }

    final horizontal =
        consolePosition == ConsolePosition.left ||
        consolePosition == ConsolePosition.right;
    final percent = consoleSizePercent.clamp(10, 100).toInt();
    if (horizontal) {
      final consoleWidth = _scaledLength(width, percent);
      final contentWidth = math.max(0, width - consoleWidth);
      if (consolePosition == ConsolePosition.left) {
        return _RendererLayout(
          content: _Bounds(
            x: consoleWidth,
            y: 0,
            width: contentWidth,
            height: height,
          ),
          console: _Bounds(x: 0, y: 0, width: consoleWidth, height: height),
        );
      }
      return _RendererLayout(
        content: _Bounds(x: 0, y: 0, width: contentWidth, height: height),
        console: _Bounds(
          x: contentWidth,
          y: 0,
          width: consoleWidth,
          height: height,
        ),
      );
    }

    final consoleHeight = _scaledLength(height, percent);
    final contentHeight = math.max(0, height - consoleHeight);
    if (consolePosition == ConsolePosition.top) {
      return _RendererLayout(
        content: _Bounds(
          x: 0,
          y: consoleHeight,
          width: width,
          height: contentHeight,
        ),
        console: _Bounds(x: 0, y: 0, width: width, height: consoleHeight),
      );
    }
    return _RendererLayout(
      content: _Bounds(x: 0, y: 0, width: width, height: contentHeight),
      console: _Bounds(
        x: 0,
        y: contentHeight,
        width: width,
        height: consoleHeight,
      ),
    );
  }

  int _scaledLength(int total, int percent) {
    if (total <= 0) {
      return 0;
    }
    final scaled = (total * percent / 100).floor();
    return scaled.clamp(1, total).toInt();
  }

  void _syncConsoleEntries() {
    final consoleNode = _consoleNode;
    if (consoleNode == null) {
      return;
    }

    final expanded = _buildConsoleLines();
    final bodyHeight = _consoleBodyHeight();
    final maxOffset = math.max(0, expanded.length - bodyHeight);
    final clampedOffset = console.scrollOffset.clamp(0, maxOffset).toInt();
    if (clampedOffset != console.scrollOffset) {
      console.setScrollOffset(clampedOffset, maxOffset: maxOffset);
      return;
    }

    final end = expanded.length - clampedOffset;
    final start = math.max(0, end - bodyHeight);
    final visible = expanded.sublist(start, end);

    consoleNode.children.clear();
    if (visible.isEmpty) {
      consoleNode.add(
        TuiText(
          id: 'cli-renderer-console-empty',
          text: '(no logs yet)',
          style: _lineStyle(ConsoleLevel.debug),
        ),
      );
      return;
    }

    final maxWidth = math.max(1, _consoleWidth - 2);
    for (var i = 0; i < visible.length; i++) {
      final line = visible[i];
      consoleNode.add(
        TuiText(
          id: 'cli-renderer-console-line-$i',
          text: _truncate(line.text, maxWidth),
          style: _lineStyle(line.level),
        ),
      );
    }
  }

  int _consoleBodyHeight() {
    final body = _consoleHeight - 2;
    return body < 1 ? 1 : body;
  }

  int _maxConsoleScrollOffset() {
    final expanded = _buildConsoleLines();
    return math.max(0, expanded.length - _consoleBodyHeight());
  }

  List<_ConsoleLine> _buildConsoleLines() {
    final lines = <_ConsoleLine>[];
    for (final entry in console.entries) {
      final prefix =
          '[${_levelLabel(entry.level)} ${_formatTime(entry.timestamp)}] ';
      final split = entry.message.split('\n');
      for (var i = 0; i < split.length; i++) {
        final line = i == 0 ? '$prefix${split[i]}' : '  ${split[i]}';
        lines.add(_ConsoleLine(text: line, level: entry.level));
      }
    }
    return lines;
  }

  String _levelLabel(ConsoleLevel level) {
    switch (level) {
      case ConsoleLevel.log:
        return 'LOG';
      case ConsoleLevel.info:
        return 'INF';
      case ConsoleLevel.warn:
        return 'WRN';
      case ConsoleLevel.error:
        return 'ERR';
      case ConsoleLevel.debug:
        return 'DBG';
    }
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _truncate(String value, int maxWidth) {
    if (maxWidth <= 0 || value.length <= maxWidth) {
      return value;
    }
    if (maxWidth <= 3) {
      return value.substring(0, maxWidth);
    }
    return '${value.substring(0, maxWidth - 3)}...';
  }

  TuiStyle _consolePanelStyle() {
    if (themeMode == ThemeMode.light) {
      return const TuiStyle(
        foreground: TuiColor.black,
        background: TuiColor(245, 245, 245),
      );
    }
    return const TuiStyle(
      foreground: TuiColor.white,
      background: TuiColor(24, 24, 24),
    );
  }

  TuiStyle _consoleBorderStyle() {
    if (themeMode == ThemeMode.light) {
      return const TuiStyle(foreground: TuiColor(130, 130, 130));
    }
    return const TuiStyle(foreground: TuiColor(96, 96, 96));
  }

  TuiStyle _lineStyle(ConsoleLevel level) {
    final background = themeMode == ThemeMode.light
        ? const TuiColor(245, 245, 245)
        : const TuiColor(24, 24, 24);
    final foreground = themeMode == ThemeMode.light
        ? TuiColor.black
        : TuiColor.white;
    switch (level) {
      case ConsoleLevel.log:
        return TuiStyle(foreground: foreground, background: background);
      case ConsoleLevel.info:
        return TuiStyle(
          foreground: const TuiColor(0, 180, 255),
          background: background,
        );
      case ConsoleLevel.warn:
        return TuiStyle(
          foreground: const TuiColor(255, 180, 0),
          background: background,
        );
      case ConsoleLevel.error:
        return TuiStyle(
          foreground: const TuiColor(255, 92, 92),
          background: background,
          bold: true,
        );
      case ConsoleLevel.debug:
        return TuiStyle(
          foreground: const TuiColor(150, 150, 150),
          background: background,
        );
    }
  }
}

Future<CliRenderer> createCliRenderer({
  TuiInputSource? inputSource,
  TuiOutputSink? outputSink,
  int width = 80,
  int height = 24,
  ThemeMode? themeMode,
  ConsolePosition consolePosition = ConsolePosition.bottom,
  int consoleSizePercent = 30,
  bool startConsoleOpen = false,
  Map<String, String>? environment,
}) async {
  final source = inputSource ?? MemoryInputSource();
  final sink = outputSink ?? MemoryOutputSink();
  final engine = TuiEngine(
    inputSource: source,
    outputSink: sink,
    viewportWidth: width,
    viewportHeight: height,
  );
  final root = TuiBox(
    id: 'root',
    width: width,
    height: height,
    layoutDirection: TuiLayoutDirection.column,
  );
  engine.mount(root);

  final resolvedThemeMode =
      themeMode ?? detectThemeModeFromEnvironment(environment: environment);

  return CliRenderer(
    engine: engine,
    root: root,
    keyInput: TuiKeyInput(source.keyEvents),
    console: OpenTuiConsole(
      position: consolePosition,
      sizePercent: consoleSizePercent,
      startOpen: startConsoleOpen,
    ),
    themeMode: resolvedThemeMode,
  );
}

final class _RendererLayout {
  const _RendererLayout({required this.content, required this.console});

  final _Bounds content;
  final _Bounds console;
}

final class _Bounds {
  const _Bounds({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}

final class _ConsoleLine {
  const _ConsoleLine({required this.text, required this.level});

  final String text;
  final ConsoleLevel level;
}
