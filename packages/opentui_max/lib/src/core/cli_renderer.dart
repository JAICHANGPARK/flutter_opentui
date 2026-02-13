import 'dart:async';

import 'engine.dart';
import 'events.dart';
import 'frame.dart';
import 'node.dart';

final class CliRenderer {
  CliRenderer({required this.engine, required this.root});

  final TuiEngine engine;
  final TuiBox root;

  TuiFrame? get frame => engine.lastFrame;

  void render() => engine.render();

  void mount(TuiNode node) {
    root.children
      ..clear()
      ..add(node);
    engine.mount(root);
  }

  Future<void> dispose() => engine.dispose();
}

Future<CliRenderer> createCliRenderer({
  TuiInputSource? inputSource,
  TuiOutputSink? outputSink,
  int width = 80,
  int height = 24,
}) async {
  final source = inputSource ?? MemoryInputSource();
  final sink = outputSink ?? MemoryOutputSink();
  final engine = TuiEngine(
    inputSource: source,
    outputSink: sink,
    viewportWidth: width,
    viewportHeight: height,
  );
  final root = TuiBox(id: 'root', width: width, height: height);
  engine.mount(root);
  return CliRenderer(engine: engine, root: root);
}
