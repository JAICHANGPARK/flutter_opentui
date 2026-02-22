import 'dart:async';

import 'frame.dart';

enum TuiSpecialKey {
  tab,
  enter,
  backspace,
  delete,
  escape,
  arrowUp,
  arrowDown,
  arrowLeft,
  arrowRight,
  home,
  end,
  pageUp,
  pageDown,
  ctrlC,
}

enum TuiMouseEventType {
  down,
  up,
  move,
  drag,
  dragEnd,
  drop,
  over,
  out,
  scroll,
}

enum TuiMouseButton { left, middle, right, none }

enum TuiScrollDirection { up, down, left, right }

final class TuiScrollInfo {
  TuiScrollInfo({required this.direction, this.delta = 1});

  final TuiScrollDirection direction;
  final int delta;
}

abstract interface class TuiEvent {
  bool get defaultPrevented;
  bool get propagationStopped;

  void preventDefault();
  void stopPropagation();
}

mixin TuiEventMixin implements TuiEvent {
  bool _defaultPrevented = false;
  bool _propagationStopped = false;

  @override
  bool get defaultPrevented => _defaultPrevented;

  @override
  bool get propagationStopped => _propagationStopped;

  @override
  void preventDefault() {
    _defaultPrevented = true;
  }

  @override
  void stopPropagation() {
    _propagationStopped = true;
  }
}

final class TuiPasteEvent with TuiEventMixin implements TuiEvent {
  TuiPasteEvent({required this.text, this.sequence});

  final String text;
  final String? sequence;
}

final class TuiKeyEvent with TuiEventMixin implements TuiEvent {
  TuiKeyEvent.character(
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

  TuiKeyEvent.special(
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

final class TuiMouseEvent with TuiEventMixin implements TuiEvent {
  TuiMouseEvent({
    required this.type,
    required this.x,
    required this.y,
    this.button = TuiMouseButton.none,
    this.shift = false,
    this.alt = false,
    this.ctrl = false,
    bool? meta,
    bool? option,
    this.scroll,
    this.sequence,
  }) : meta = meta ?? option ?? alt,
       option = option ?? meta ?? alt;

  final TuiMouseEventType type;
  final TuiMouseButton button;
  final int x;
  final int y;
  final bool shift;
  final bool alt;
  final bool ctrl;
  final bool meta;
  final bool option;
  final TuiScrollInfo? scroll;
  final String? sequence;
}

final class TuiResizeEvent {
  const TuiResizeEvent({required this.width, required this.height});

  final int width;
  final int height;
}

abstract interface class TuiInputSource {
  Stream<TuiKeyEvent> get keyEvents;
  Stream<TuiMouseEvent> get mouseEvents;

  Stream<TuiResizeEvent> get resizeEvents;
}

abstract interface class TuiOutputSink {
  FutureOr<void> present(TuiFrame frame);
}

final class MemoryInputSource implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiMouseEvent> _mouseController =
      StreamController<TuiMouseEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiMouseEvent> get mouseEvents => _mouseController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;

  void emitKey(TuiKeyEvent event) {
    _keyController.add(event);
  }

  void emitMouse(TuiMouseEvent event) {
    _mouseController.add(event);
  }

  void emitResize(TuiResizeEvent event) {
    _resizeController.add(event);
  }

  Future<void> dispose() async {
    await _keyController.close();
    await _mouseController.close();
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
