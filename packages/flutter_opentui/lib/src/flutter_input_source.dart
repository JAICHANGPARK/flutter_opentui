import 'dart:async';

import 'package:opentui/opentui.dart';

final class FlutterInputSource implements TuiInputSource {
  final StreamController<TuiKeyEvent> _keyController =
      StreamController<TuiKeyEvent>.broadcast();
  final StreamController<TuiResizeEvent> _resizeController =
      StreamController<TuiResizeEvent>.broadcast();

  @override
  Stream<TuiKeyEvent> get keyEvents => _keyController.stream;

  @override
  Stream<TuiResizeEvent> get resizeEvents => _resizeController.stream;

  void addKeyEvent(TuiKeyEvent event) {
    _keyController.add(event);
  }

  void addResize({required int width, required int height}) {
    _resizeController.add(TuiResizeEvent(width: width, height: height));
  }

  Future<void> dispose() async {
    await _keyController.close();
    await _resizeController.close();
  }
}
