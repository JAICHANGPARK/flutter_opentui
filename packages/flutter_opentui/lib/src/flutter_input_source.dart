import 'dart:async';

import 'package:opentui/opentui.dart';

/// Metadata captured from Flutter key events when available.
final class FlutterKeyMetadata {
  const FlutterKeyMetadata({
    this.character,
    this.logicalKeyLabel,
    this.logicalKeyId,
    this.physicalKeyId,
    this.physicalKeyDebugName,
    this.isRepeat = false,
  });

  final String? character;
  final String? logicalKeyLabel;
  final int? logicalKeyId;
  final int? physicalKeyId;
  final String? physicalKeyDebugName;
  final bool isRepeat;
}

/// Captures a key dispatch emitted by [FlutterInputSource].
final class FlutterKeyDispatch {
  const FlutterKeyDispatch({
    required this.event,
    this.metadata,
    this.pastedText,
  });

  final TuiKeyEvent event;
  final FlutterKeyMetadata? metadata;

  /// Full pasted payload when [event] was emitted from [addPaste].
  final String? pastedText;

  bool get isFromPaste => pastedText != null;
}

/// In-memory [TuiInputSource] bridge used by Flutter adapters.
final class FlutterInputSource implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiMouseEvent> _mouseController =
      StreamController<TuiMouseEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();
  final StreamController<FlutterKeyDispatch> _dispatchController =
      StreamController<FlutterKeyDispatch>.broadcast();
  final StreamController<String> _pasteController =
      StreamController<String>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiMouseEvent> get mouseEvents => _mouseController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;

  /// Detailed dispatch stream including optional Flutter key metadata.
  Stream<FlutterKeyDispatch> get keyDispatches => _dispatchController.stream;

  /// Paste payload stream emitted by [addPaste].
  Stream<String> get pasteEvents => _pasteController.stream;

  /// Adds a raw [TuiKeyEvent] to the OpenTUI input stream.
  void addKeyEvent(
    TuiKeyEvent event, {
    FlutterKeyMetadata? metadata,
    String? pastedText,
  }) {
    _keyController.add(event);
    _dispatchController.add(
      FlutterKeyDispatch(
        event: event,
        metadata: metadata,
        pastedText: pastedText,
      ),
    );
  }

  /// Convenience helper for character key dispatches.
  void addCharacter(
    String character, {
    bool ctrl = false,
    bool alt = false,
    bool shift = false,
    bool? meta,
    bool? option,
    String? name,
    String? sequence,
    FlutterKeyMetadata? metadata,
  }) {
    addKeyEvent(
      TuiKeyEvent.character(
        character,
        ctrl: ctrl,
        alt: alt,
        shift: shift,
        meta: meta,
        option: option,
        name: name,
        sequence: sequence,
      ),
      metadata: metadata,
    );
  }

  /// Convenience helper for special key dispatches.
  void addSpecialKey(
    TuiSpecialKey specialKey, {
    bool ctrl = false,
    bool alt = false,
    bool shift = false,
    bool? meta,
    bool? option,
    String? name,
    String? sequence,
    FlutterKeyMetadata? metadata,
  }) {
    addKeyEvent(
      TuiKeyEvent.special(
        specialKey,
        ctrl: ctrl,
        alt: alt,
        shift: shift,
        meta: meta,
        option: option,
        name: name,
        sequence: sequence,
      ),
      metadata: metadata,
    );
  }

  /// Emits [text] as a paste event and optional per-character key events.
  void addPaste(
    String text, {
    bool ctrl = false,
    bool alt = false,
    bool shift = false,
    bool? meta,
    bool? option,
    String? sequence,
    bool emitCharacterEvents = true,
    FlutterKeyMetadata? metadata,
  }) {
    if (text.isEmpty) {
      return;
    }

    _pasteController.add(text);
    addKeyEvent(
      TuiKeyEvent.paste(text, sequence: sequence),
      metadata: metadata,
      pastedText: text,
    );
    if (!emitCharacterEvents) {
      return;
    }
    for (final rune in text.runes) {
      addKeyEvent(
        TuiKeyEvent.character(
          String.fromCharCode(rune),
          ctrl: ctrl,
          alt: alt,
          shift: shift,
          meta: meta,
          option: option,
          sequence: sequence,
        ),
        metadata: metadata,
        pastedText: text,
      );
    }
  }

  /// Emits a viewport resize event.
  void addResize({required int width, required int height}) {
    _resizeController.add(TuiResizeEvent(width: width, height: height));
  }

  /// Adds a raw [TuiMouseEvent] to the OpenTUI input stream.
  void addMouseEvent(TuiMouseEvent event) {
    _mouseController.add(event);
  }

  /// Convenience helper for mouse dispatches.
  void addMouse({
    required TuiMouseEventType type,
    required int x,
    required int y,
    TuiMouseButton button = TuiMouseButton.none,
    bool shift = false,
    bool alt = false,
    bool ctrl = false,
    bool? meta,
    bool? option,
    TuiScrollInfo? scroll,
  }) {
    addMouseEvent(
      TuiMouseEvent(
        type: type,
        x: x,
        y: y,
        button: button,
        shift: shift,
        alt: alt,
        ctrl: ctrl,
        meta: meta,
        option: option,
        scroll: scroll,
      ),
    );
  }

  /// Closes all event streams.
  Future<void> dispose() async {
    await _keyController.close();
    await _mouseController.close();
    await _resizeController.close();
    await _dispatchController.close();
    await _pasteController.close();
  }
}
