import 'dart:async';

import 'frame.dart';

enum TuiSpecialKey {
  tab,
  enter,
  backspace,
  escape,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  ctrlC,
}

final class TuiKeyEvent {
  const TuiKeyEvent.character(
    this.character, {
    this.ctrl = false,
    this.alt = false,
    this.shift = false,
  }) : special = null;

  const TuiKeyEvent.special(
    this.special, {
    this.ctrl = false,
    this.alt = false,
    this.shift = false,
  }) : character = null;

  final String? character;
  final TuiSpecialKey? special;
  final bool ctrl;
  final bool alt;
  final bool shift;

  bool get isCharacter => character != null;
}

final class TuiResizeEvent {
  const TuiResizeEvent({required this.width, required this.height});

  final int width;
  final int height;
}

abstract interface class TuiInputSource {
  Stream<TuiKeyEvent> get keyEvents;

  Stream<TuiResizeEvent> get resizeEvents;
}

abstract interface class TuiOutputSink {
  FutureOr<void> present(TuiFrame frame);
}

final class MemoryInputSource implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;

  void emitKey(TuiKeyEvent event) {
    _keyController.add(event);
  }

  void emitResize(TuiResizeEvent event) {
    _resizeController.add(event);
  }

  Future<void> dispose() async {
    await _keyController.close();
    await _resizeController.close();
  }
}

final class MemoryOutputSink implements TuiOutputSink {
  final List<TuiFrame> presented = <TuiFrame>[];

  @override
  void present(TuiFrame frame) {
    presented.add(frame.clone());
  }
}
