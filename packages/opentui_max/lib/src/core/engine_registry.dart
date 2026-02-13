import 'cli_renderer.dart';

final class OpenTuiEngineRegistry {
  CliRenderer? _renderer;

  CliRenderer? get renderer => _renderer;

  void attach(CliRenderer renderer) {
    _renderer = renderer;
  }

  void detach() {
    _renderer = null;
  }
}

final OpenTuiEngineRegistry engine = OpenTuiEngineRegistry();
