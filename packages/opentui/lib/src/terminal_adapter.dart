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

      if (_pendingInput.startsWith('\x1b[A', index)) {
        _keyController.add(
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
            TuiSpecialKey.arrowLeft,
            name: 'left',
            sequence: '\x1b[D',
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
          const TuiKeyEvent.special(
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
