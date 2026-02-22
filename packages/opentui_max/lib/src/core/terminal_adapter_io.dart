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
          ),
        );
        index += sequence.length;
        continue;
      }

      if (_pendingInput.startsWith('\x1b[A', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowUp));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[B', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowDown));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[C', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowRight));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[D', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowLeft));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOA', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowUp));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOB', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowDown));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOC', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowRight));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1bOD', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.arrowLeft));
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[H', index) ||
          _pendingInput.startsWith('\x1bOH', index) ||
          _pendingInput.startsWith('\x1b[1~', index) ||
          _pendingInput.startsWith('\x1b[7~', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.home));
        if (_pendingInput.startsWith('\x1b[H', index) ||
            _pendingInput.startsWith('\x1bOH', index)) {
          index += 3;
        } else {
          index += 4;
        }
        continue;
      }
      if (_pendingInput.startsWith('\x1b[F', index) ||
          _pendingInput.startsWith('\x1bOF', index) ||
          _pendingInput.startsWith('\x1b[4~', index) ||
          _pendingInput.startsWith('\x1b[8~', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.end));
        if (_pendingInput.startsWith('\x1b[F', index) ||
            _pendingInput.startsWith('\x1bOF', index)) {
          index += 3;
        } else {
          index += 4;
        }
        continue;
      }
      if (_pendingInput.startsWith('\x1b[3~', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.delete));
        index += 4;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[5~', index) ||
          _pendingInput.startsWith('\x1b[[5~', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.pageUp));
        index += _pendingInput.startsWith('\x1b[5~', index) ? 4 : 5;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[6~', index) ||
          _pendingInput.startsWith('\x1b[[6~', index)) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.pageDown));
        index += _pendingInput.startsWith('\x1b[6~', index) ? 4 : 5;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[Z', index)) {
        _keyController.add(
          const TuiKeyEvent.special(TuiSpecialKey.tab, shift: true),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[a', index)) {
        _keyController.add(
          const TuiKeyEvent.special(TuiSpecialKey.arrowUp, shift: true),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[b', index)) {
        _keyController.add(
          const TuiKeyEvent.special(TuiSpecialKey.arrowDown, shift: true),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[c', index)) {
        _keyController.add(
          const TuiKeyEvent.special(TuiSpecialKey.arrowRight, shift: true),
        );
        index += 3;
        continue;
      }
      if (_pendingInput.startsWith('\x1b[d', index)) {
        _keyController.add(
          const TuiKeyEvent.special(TuiSpecialKey.arrowLeft, shift: true),
        );
        index += 3;
        continue;
      }

      final codeUnit = _pendingInput.codeUnitAt(index);
      if (codeUnit == 27) {
        if (index == _pendingInput.length - 1) {
          break;
        }
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.escape));
        index += 1;
        continue;
      }
      if (codeUnit == 9) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.tab));
        index += 1;
        continue;
      }
      if (codeUnit == 13 || codeUnit == 10) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.enter));
        index += 1;
        continue;
      }
      if (codeUnit == 127 || codeUnit == 8) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.backspace));
        index += 1;
        continue;
      }
      if (codeUnit == 3) {
        _keyController.add(const TuiKeyEvent.special(TuiSpecialKey.ctrlC));
        index += 1;
        continue;
      }

      if (codeUnit >= 32) {
        _keyController.add(
          TuiKeyEvent.character(String.fromCharCode(codeUnit)),
        );
      }
      index += 1;
    }

    _pendingInput = _pendingInput.substring(index);
  }

  ({bool ctrl, bool alt, bool shift}) _decodeModifiers(int encodedModifier) {
    final modifier = encodedModifier - 1;
    final shift = (modifier & 1) != 0;
    final alt = (modifier & 2) != 0;
    final ctrl = (modifier & 4) != 0;
    return (ctrl: ctrl, alt: alt, shift: shift);
  }

  (String, TuiSpecialKey, ({bool ctrl, bool alt, bool shift}))?
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

  Future<void> _flushIfPossible() async {
    final output = _stdout;
    if (output is Stdout) {
      await output.flush();
      return;
    }
    await _stdout.flush();
  }
}
