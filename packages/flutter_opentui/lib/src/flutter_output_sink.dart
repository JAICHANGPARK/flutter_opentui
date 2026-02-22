import 'dart:async';

import 'package:opentui/opentui.dart';

final class FlutterOutputSink implements TuiOutputSink {
  final StreamController<TuiFrame> _framesController =
      StreamController<TuiFrame>.broadcast();

  TuiFrame? _latestFrame;

  Stream<TuiFrame> get frames => _framesController.stream;

  TuiFrame? get latestFrame => _latestFrame;

  @override
  Future<void> present(TuiFrame frame) async {
    _latestFrame = frame.clone();
    _framesController.add(_latestFrame!);
  }

  Future<void> dispose() async {
    await _framesController.close();
  }
}
