import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:opentui/opentui.dart';

import 'flutter_input_source.dart';
import 'flutter_output_sink.dart';

/// Coordinates OpenTUI engine lifecycle and Flutter input/output bridges.
final class OpenTuiController extends ChangeNotifier {
  OpenTuiController({
    FlutterInputSource? inputSource,
    FlutterOutputSink? outputSink,
  }) : _inputSource = inputSource ?? FlutterInputSource(),
       _outputSink = outputSink ?? FlutterOutputSink();

  final FlutterInputSource _inputSource;
  final FlutterOutputSink _outputSink;

  TuiEngine? _engine;
  TuiFrame? _latestFrame;
  StreamSubscription<TuiFrame>? _frameSubscription;

  FlutterInputSource get inputSource => _inputSource;

  FlutterOutputSink get outputSink => _outputSink;

  TuiEngine? get engine => _engine;

  TuiFrame? get latestFrame => _latestFrame ?? _outputSink.latestFrame;

  /// Attaches an existing engine and starts listening for rendered frames.
  void attachEngine(TuiEngine engine) {
    _frameSubscription?.cancel();
    _engine = engine;
    _frameSubscription = engine.frames.listen((TuiFrame frame) {
      _latestFrame = frame.clone();
      notifyListeners();
    });
  }

  /// Detaches from the current engine.
  ///
  /// When [disposeEngine] is `true`, the engine is disposed as part of detach.
  Future<void> detach({bool disposeEngine = false}) async {
    await _frameSubscription?.cancel();
    _frameSubscription = null;

    if (disposeEngine) {
      final current = _engine;
      if (current != null) {
        await current.dispose();
      }
    }

    _engine = null;
  }

  /// Sends a raw key event to the OpenTUI input stream.
  void sendKeyEvent(TuiKeyEvent event, {FlutterKeyMetadata? metadata}) {
    _inputSource.addKeyEvent(event, metadata: metadata);
  }

  /// Sends a character key event.
  void sendCharacter(
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
    _inputSource.addCharacter(
      character,
      ctrl: ctrl,
      alt: alt,
      shift: shift,
      meta: meta,
      option: option,
      name: name,
      sequence: sequence,
      metadata: metadata,
    );
  }

  /// Sends a special key event.
  void sendSpecialKey(
    TuiSpecialKey key, {
    bool ctrl = false,
    bool alt = false,
    bool shift = false,
    bool? meta,
    bool? option,
    String? name,
    String? sequence,
    FlutterKeyMetadata? metadata,
  }) {
    _inputSource.addSpecialKey(
      key,
      ctrl: ctrl,
      alt: alt,
      shift: shift,
      meta: meta,
      option: option,
      name: name,
      sequence: sequence,
      metadata: metadata,
    );
  }

  /// Sends text as a sequence of character key events.
  void sendText(String text, {FlutterKeyMetadata? metadata}) {
    for (final rune in text.runes) {
      sendCharacter(String.fromCharCode(rune), metadata: metadata);
    }
  }

  /// Sends text as a paste event and per-character key events.
  void sendPaste(
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
    _inputSource.addPaste(
      text,
      ctrl: ctrl,
      alt: alt,
      shift: shift,
      meta: meta,
      option: option,
      sequence: sequence,
      emitCharacterEvents: emitCharacterEvents,
      metadata: metadata,
    );
  }

  /// Sends a viewport resize event.
  void sendResize({required int width, required int height}) {
    _inputSource.addResize(width: width, height: height);
  }

  /// Sends a raw mouse event to the OpenTUI input stream.
  void sendMouseEvent(TuiMouseEvent event) {
    _inputSource.addMouseEvent(event);
  }

  /// Sends a mouse event with convenience parameters.
  void sendMouse({
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
    _inputSource.addMouse(
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
    );
  }

  @override
  Future<void> dispose() async {
    await detach(disposeEngine: true);
    await _inputSource.dispose();
    await _outputSink.dispose();
    super.dispose();
  }
}
