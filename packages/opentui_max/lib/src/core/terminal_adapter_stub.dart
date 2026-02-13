import 'events.dart';
import 'frame.dart';

final class TerminalAdapter implements TuiInputSource, TuiOutputSink {
  TerminalAdapter();

  @override
  Stream<TuiKeyEvent> get keyEvents => const Stream<TuiKeyEvent>.empty();

  @override
  Stream<TuiResizeEvent> get resizeEvents =>
      const Stream<TuiResizeEvent>.empty();

  @override
  void present(TuiFrame frame) {
    // no-op on non-io runtimes
  }

  Future<void> clear() async {}

  Future<void> dispose() async {}
}
