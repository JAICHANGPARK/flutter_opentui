import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'ansi_renderer.dart';
import 'events.dart';
import 'frame.dart';

final class TerminalAdapter implements TuiInputSource, TuiOutputSink {
  TerminalAdapter({Stdin? stdin, IOSink? stdout})
    : _stdin = stdin ?? ioStdin,
      _stdout = stdout ?? ioStdout {
    _start();
  }

  static Stdin get ioStdin => stdin;
  static Stdout get ioStdout => stdout;

  final Stdin _stdin;
  final IOSink _stdout;
  final AnsiRenderer _renderer = AnsiRenderer();

  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiMouseEvent> _mouseController =
      StreamController<TuiMouseEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  StreamSubscription<List<int>>? _stdinSubscription;
  StreamSubscription<ProcessSignal>? _winchSubscription;

  bool _rawModeEnabled = false;
  String _pendingInput = '';
  TuiFrame? _previousFrame;

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiMouseEvent> get mouseEvents => _mouseController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;

  Future<void> clear() async {
    _stdout.write(_renderer.clearScreen());
    await _flushIfPossible();
  }

  @override
  Future<void> present(TuiFrame frame) async {
    final ansi = _renderer.renderDiff(previous: _previousFrame, next: frame);
    _stdout.write(ansi);
    _previousFrame = frame.clone();
    await _flushIfPossible();
  }

  Future<void> dispose() async {
    await _stdinSubscription?.cancel();
    await _winchSubscription?.cancel();

    if (_rawModeEnabled) {
      _stdin.echoMode = true;
      _stdin.lineMode = true;
    }

    await _keyController.close();
    await _mouseController.close();
    await _resizeController.close();
  }

  void _start() {
    _configureTerminalModes();

    _stdinSubscription = _stdin.listen(_onInput);

    final terminalStdout = _stdout;
    if (terminalStdout is Stdout && terminalStdout.hasTerminal) {
      _emitResize(terminalStdout);
      try {
        _winchSubscription = ProcessSignal.sigwinch.watch().listen((_) {
          _emitResize(terminalStdout);
        });
      } on Object {
        // sigwinch is not available on every runtime target.
      }
    }
  }

  void _configureTerminalModes() {
    if (!_stdin.hasTerminal) {
      return;
    }
    _stdin.echoMode = false;
    _stdin.lineMode = false;
    _rawModeEnabled = true;
  }

  void _emitResize(Stdout out) {
    _resizeController.add(
      TuiResizeEvent(width: out.terminalColumns, height: out.terminalLines),
    );
  }

  void _onInput(List<int> bytes) {
    _pendingInput += utf8.decode(bytes, allowMalformed: true);
    _drainInputBuffer();
  }

  void _drainInputBuffer() {
    var index = 0;

    while (index < _pendingInput.length) {
      final mouse = _matchSgrMouse(index);
      if (mouse != null) {
        _mouseController.add(mouse.$2);
        index += mouse.$1.length;
        continue;
      }

      if (_pendingInput.startsWith('\x1b[200~', index)) {
        final pasteStart = index + 6;
        final pasteEnd = _pendingInput.indexOf('\x1b[201~', pasteStart);
        if (pasteEnd < 0) {
          break;
        }
        final pastedText = _pendingInput.substring(pasteStart, pasteEnd);
        _keyController.add(
          TuiKeyEvent.paste(
            pastedText,
            sequence: _pendingInput.substring(index, pasteEnd + 6),
          ),
        );
        index = pasteEnd + 6;
        continue;
      }

      final modifiedCsi = _matchModifiedCsi(index);
      if (modifiedCsi != null) {
        final sequence = modifiedCsi.$1;
        final special = modifiedCsi.$2;
        final modifiers = modifiedCsi.$3;
        _keyController.add(
          TuiKeyEvent.special(
            special,
            ctrl: modifiers.ctrl,
            alt: modifiers.alt,
            shift: modifiers.shift,
            meta: modifiers.meta,
            option: modifiers.option,
            name: _specialName(special),
            sequence: sequence,
          ),
        );
        index += sequence.length;
        continue;
      }

      if (_pendingInput.startsWith('\x1b[A', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowUp,
            name: 'up',
            sequence: '\x1b[A',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[B', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowDown,
            name: 'down',
            sequence: '\x1b[B',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[C', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowRight,
            name: 'right',
            sequence: '\x1b[C',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[D', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowLeft,
            name: 'left',
            sequence: '\x1b[D',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOA', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowUp,
            name: 'up',
            sequence: '\x1bOA',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOB', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowDown,
            name: 'down',
            sequence: '\x1bOB',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOC', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowRight,
            name: 'right',
            sequence: '\x1bOC',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOD', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowLeft,
            name: 'left',
            sequence: '\x1bOD',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[H', index) ||
          _pendingInput.startsWith('\x1bOH', index)) {
        final sequence = _pendingInput.startsWith('\x1b[H', index)
            ? '\x1b[H'
            : '\x1bOH';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.home,
            name: 'home',
            sequence: sequence,
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[F', index) ||
          _pendingInput.startsWith('\x1bOF', index)) {
        final sequence = _pendingInput.startsWith('\x1b[F', index)
            ? '\x1b[F'
            : '\x1bOF';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.end,
            name: 'end',
            sequence: sequence,
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[1~', index) ||
          _pendingInput.startsWith('\x1b[7~', index)) {
        final sequence = _pendingInput.startsWith('\x1b[1~', index)
            ? '\x1b[1~'
            : '\x1b[7~';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.home,
            name: 'home',
            sequence: sequence,
          ),
        );
        index += 4;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[4~', index) ||
          _pendingInput.startsWith('\x1b[8~', index)) {
        final sequence = _pendingInput.startsWith('\x1b[4~', index)
            ? '\x1b[4~'
            : '\x1b[8~';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.end,
            name: 'end',
            sequence: sequence,
          ),
        );
        index += 4;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[3~', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.delete,
            name: 'delete',
            sequence: '\x1b[3~',
          ),
        );
        index += 4;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[5~', index) ||
          _pendingInput.startsWith('\x1b[[5~', index)) {
        final sequence = _pendingInput.startsWith('\x1b[5~', index)
            ? '\x1b[5~'
            : '\x1b[[5~';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.pageUp,
            name: 'pageup',
            sequence: sequence,
          ),
        );
        index += sequence.length;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[6~', index) ||
          _pendingInput.startsWith('\x1b[[6~', index)) {
        final sequence = _pendingInput.startsWith('\x1b[6~', index)
            ? '\x1b[6~'
            : '\x1b[[6~';
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.pageDown,
            name: 'pagedown',
            sequence: sequence,
          ),
        );
        index += sequence.length;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[Z', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.tab,
            shift: true,
            name: 'tab',
            sequence: '\x1b[Z',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[a', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowUp,
            shift: true,
            name: 'up',
            sequence: '\x1b[a',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[b', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowDown,
            shift: true,
            name: 'down',
            sequence: '\x1b[b',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[c', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowRight,
            shift: true,
            name: 'right',
            sequence: '\x1b[c',
          ),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[d', index)) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.arrowLeft,
            shift: true,
            name: 'left',
            sequence: '\x1b[d',
          ),
        );
        index += 3;
        continue;
      }

      final codeUnit = _pendingInput.codeUnitAt(index);
      if (codeUnit == 27) {
        if (index == _pendingInput.length - 1) {
          break;
        }
        final nextCodeUnit = _pendingInput.codeUnitAt(index + 1);
        if (nextCodeUnit >= 32 && nextCodeUnit <= 126) {
          final character = String.fromCharCode(nextCodeUnit);
          _keyController.add(
            TuiKeyEvent.character(
              character,
              alt: true,
              meta: true,
              option: true,
              shift: _isUpperAlpha(character),
              name: _characterName(character),
              sequence: _pendingInput.substring(index, index + 2),
            ),
          );
          index += 2;
          continue;
        }
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.escape,
            name: 'escape',
            sequence: '\x1b',
          ),
        );
        index += 1;
        continue;
      }
      if (codeUnit == 9) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.tab,
            name: 'tab',
            sequence: '\t',
          ),
        );
        index += 1;
        continue;
      }
      if (codeUnit == 13 || codeUnit == 10) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.enter,
            name: 'enter',
            sequence: '\n',
          ),
        );
        index += 1;
        continue;
      }
      if (codeUnit == 127 || codeUnit == 8) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.backspace,
            name: 'backspace',
            sequence: '\x7f',
          ),
        );
        index += 1;
        continue;
      }
      if (codeUnit == 3) {
        _keyController.add(
          TuiKeyEvent.special(
            TuiSpecialKey.ctrlC,
            ctrl: true,
            name: 'c',
            sequence: '\x03',
          ),
        );
        index += 1;
        continue;
      }

      if (codeUnit >= 32) {
        final character = String.fromCharCode(codeUnit);
        _keyController.add(
          TuiKeyEvent.character(
            character,
            shift: _isUpperAlpha(character),
            name: _characterName(character),
            sequence: character,
          ),
        );
      }
      index += 1;
    }

    _pendingInput = _pendingInput.substring(index);
  }

  ({bool ctrl, bool alt, bool shift, bool meta, bool option}) _decodeModifiers(
    int encodedModifier,
  ) {
    final modifier = encodedModifier - 1;
    final shift = (modifier & 1) != 0;
    final alt = (modifier & 2) != 0;
    final ctrl = (modifier & 4) != 0;
    return (ctrl: ctrl, alt: alt, shift: shift, meta: alt, option: alt);
  }

  (
    String,
    TuiSpecialKey,
    ({bool ctrl, bool alt, bool shift, bool meta, bool option}),
  )?
  _matchModifiedCsi(int index) {
    final remaining = _pendingInput.substring(index);
    final match = RegExp(
      r'^\x1b\[(\d+);(\d+)([ABCDHF~])',
    ).matchAsPrefix(remaining);
    if (match == null) {
      return null;
    }

    final primary = match.group(1)!;
    final modifierCode = int.tryParse(match.group(2) ?? '');
    final suffix = match.group(3)!;
    if (modifierCode == null) {
      return null;
    }

    final special = _mapCsiSpecial(primary: primary, suffix: suffix);
    if (special == null) {
      return null;
    }

    final sequence = match.group(0)!;
    return (sequence, special, _decodeModifiers(modifierCode));
  }

  (String, TuiMouseEvent)? _matchSgrMouse(int index) {
    final remaining = _pendingInput.substring(index);
    final match = RegExp(
      r'^\x1b\[<(\d+);(\d+);(\d+)([Mm])',
    ).matchAsPrefix(remaining);
    if (match == null) {
      return null;
    }

    final rawButtonCode = int.tryParse(match.group(1)!);
    final wireX = int.tryParse(match.group(2)!);
    final wireY = int.tryParse(match.group(3)!);
    final marker = match.group(4)!;
    if (rawButtonCode == null || wireX == null || wireY == null) {
      return null;
    }

    final isScroll = (rawButtonCode & 64) != 0;
    final isMotion = (rawButtonCode & 32) != 0;
    final buttonCode = rawButtonCode & 3;
    final button = switch (buttonCode) {
      0 => TuiMouseButton.left,
      1 => TuiMouseButton.middle,
      2 => TuiMouseButton.right,
      _ => TuiMouseButton.none,
    };

    final shift = (rawButtonCode & 4) != 0;
    final alt = (rawButtonCode & 8) != 0;
    final ctrl = (rawButtonCode & 16) != 0;

    final type = isScroll
        ? TuiMouseEventType.scroll
        : isMotion
        ? (buttonCode == 3 ? TuiMouseEventType.move : TuiMouseEventType.drag)
        : (marker == 'M' ? TuiMouseEventType.down : TuiMouseEventType.up);
    final scroll = isScroll
        ? TuiScrollInfo(
            direction: switch (buttonCode) {
              0 => TuiScrollDirection.up,
              1 => TuiScrollDirection.down,
              2 => TuiScrollDirection.left,
              3 => TuiScrollDirection.right,
              _ => TuiScrollDirection.down,
            },
            delta: 1,
          )
        : null;

    final sequence = match.group(0)!;
    final event = TuiMouseEvent(
      type: type,
      x: wireX - 1,
      y: wireY - 1,
      button: isScroll ? TuiMouseButton.none : button,
      shift: shift,
      alt: alt,
      ctrl: ctrl,
      meta: alt,
      option: alt,
      scroll: scroll,
      sequence: sequence,
    );
    return (sequence, event);
  }

  TuiSpecialKey? _mapCsiSpecial({
    required String primary,
    required String suffix,
  }) {
    if (suffix == 'A') {
      return TuiSpecialKey.arrowUp;
    }
    if (suffix == 'B') {
      return TuiSpecialKey.arrowDown;
    }
    if (suffix == 'C') {
      return TuiSpecialKey.arrowRight;
    }
    if (suffix == 'D') {
      return TuiSpecialKey.arrowLeft;
    }
    if (suffix == 'H') {
      return TuiSpecialKey.home;
    }
    if (suffix == 'F') {
      return TuiSpecialKey.end;
    }
    if (suffix != '~') {
      return null;
    }
    switch (primary) {
      case '1':
      case '7':
        return TuiSpecialKey.home;
      case '3':
        return TuiSpecialKey.delete;
      case '4':
      case '8':
        return TuiSpecialKey.end;
      case '5':
        return TuiSpecialKey.pageUp;
      case '6':
        return TuiSpecialKey.pageDown;
      default:
        return null;
    }
  }

  String _specialName(TuiSpecialKey key) {
    switch (key) {
      case TuiSpecialKey.tab:
        return 'tab';
      case TuiSpecialKey.enter:
        return 'enter';
      case TuiSpecialKey.backspace:
        return 'backspace';
      case TuiSpecialKey.delete:
        return 'delete';
      case TuiSpecialKey.escape:
        return 'escape';
      case TuiSpecialKey.arrowUp:
        return 'up';
      case TuiSpecialKey.arrowDown:
        return 'down';
      case TuiSpecialKey.arrowLeft:
        return 'left';
      case TuiSpecialKey.arrowRight:
        return 'right';
      case TuiSpecialKey.home:
        return 'home';
      case TuiSpecialKey.end:
        return 'end';
      case TuiSpecialKey.pageUp:
        return 'pageup';
      case TuiSpecialKey.pageDown:
        return 'pagedown';
      case TuiSpecialKey.ctrlC:
        return 'c';
    }
  }

  bool _isUpperAlpha(String value) {
    if (value.length != 1) {
      return false;
    }
    final code = value.codeUnitAt(0);
    return code >= 65 && code <= 90;
  }

  String _characterName(String character) {
    if (character.length != 1) {
      return character;
    }
    return character.toLowerCase();
  }

  Future<void> _flushIfPossible() async {
    final output = _stdout;
    if (output is Stdout) {
      await output.flush();
      return;
    }
    await _stdout.flush();
  }
}
