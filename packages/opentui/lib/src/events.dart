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

final class TuiPasteEvent {
  const TuiPasteEvent({required this.text, this.sequence});

  final String text;
  final String? sequence;
}

final class TuiKeyEvent {
  const TuiKeyEvent.character(
    this.character, {
    this.ctrl = false,
    bool alt = false,
    this.shift = false,
    bool? meta,
    bool? option,
    this.name,
    this.sequence,
  }) : special = null,
       paste = null,
       alt = alt || meta == true || option == true,
       meta = meta ?? option ?? alt,
       option = option ?? meta ?? alt;

  const TuiKeyEvent.special(
    this.special, {
    this.ctrl = false,
    bool alt = false,
    this.shift = false,
    bool? meta,
    bool? option,
    this.name,
    this.sequence,
  }) : character = null,
       paste = null,
       alt = alt || meta == true || option == true,
       meta = meta ?? option ?? alt,
       option = option ?? meta ?? alt;

  TuiKeyEvent.paste(String text, {this.sequence, this.name = 'paste'})
    : character = null,
      special = null,
      ctrl = false,
      alt = false,
      shift = false,
      meta = false,
      option = false,
      paste = TuiPasteEvent(text: text, sequence: sequence);

  final String? character;
  final TuiSpecialKey? special;
  final bool ctrl;
  final bool alt;
  final bool shift;
  final bool meta;
  final bool option;
  final String? name;
  final String? sequence;
  final TuiPasteEvent? paste;

  bool get isCharacter => character != null;

  bool get isSpecial => special != null;

  bool get isPaste => paste != null;
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
