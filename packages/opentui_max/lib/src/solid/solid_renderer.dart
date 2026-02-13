import '../core/cli_renderer.dart';
import '../core/node.dart';
import 'signal.dart';

final class SolidRenderResult {
  SolidRenderResult({required this.node, required this.dispose});

  final TuiNode node;
  final void Function() dispose;
}

final class OpenTuiSolidRenderer {
  OpenTuiSolidRenderer({required this.builder});

  final TuiNode Function() builder;

  SolidRenderResult render({
    CliRenderer? cliRenderer,
    List<SolidSignal<dynamic>> watch = const <SolidSignal<dynamic>>[],
  }) {
    var disposed = false;

    void repaint() {
      if (disposed || cliRenderer == null) {
        return;
      }
      cliRenderer.mount(builder());
      cliRenderer.render();
    }

    void listener(dynamic _) {
      repaint();
    }

    for (final signal in watch) {
      signal.listen(listener);
    }

    final node = builder();
    if (cliRenderer != null) {
      cliRenderer.mount(node);
      cliRenderer.render();
    }

    return SolidRenderResult(
      node: node,
      dispose: () {
        if (disposed) {
          return;
        }
        disposed = true;
        for (final signal in watch) {
          signal.unlisten(listener);
        }
      },
    );
  }
}
