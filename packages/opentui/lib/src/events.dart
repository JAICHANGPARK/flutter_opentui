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
