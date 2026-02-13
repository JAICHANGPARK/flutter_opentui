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

  Future<void> _flushIfPossible() async {
    final output = _stdout;
    if (output is Stdout) {
      await output.flush();
      return;
    }
    await _stdout.flush();
  }
}
