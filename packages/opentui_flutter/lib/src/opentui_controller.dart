import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:opentui/opentui.dart';

import 'flutter_input_source.dart';
import 'flutter_output_sink.dart';

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

  void attachEngine(TuiEngine engine) {
    _frameSubscription?.cancel();
    _engine = engine;
    _frameSubscription = engine.frames.listen((TuiFrame frame) {
      _latestFrame = frame.clone();
      notifyListeners();
    });
  }

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

  void sendKeyEvent(TuiKeyEvent event) {
    _inputSource.addKeyEvent(event);
  }

  void sendText(String text) {
    for (final rune in text.runes) {
      sendKeyEvent(TuiKeyEvent.character(String.fromCharCode(rune)));
    }
  }

  void sendResize({required int width, required int height}) {
    _inputSource.addResize(width: width, height: height);
  }

  @override
  Future<void> dispose() async {
    await detach(disposeEngine: true);
    await _inputSource.dispose();
    await _outputSink.dispose();
    super.dispose();
  }
}
