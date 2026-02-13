import '../core/cli_renderer.dart';
import '../core/node.dart';
import '../core/renderables.dart';

/// Compatibility aliases kept with a `Legacy` prefix to avoid symbol conflicts
/// with concrete renderable classes in `src/core/renderables.dart`.
typedef LegacyRenderableNode = TuiNode;
typedef LegacyRenderer = CliRenderer;
typedef LegacyBoxNode = TuiBox;
typedef LegacyTextNode = TuiText;
typedef LegacyInputNode = TuiInput;
typedef LegacySelectNode = TuiSelect;
typedef LegacyRenderableBase = BaseRenderable;

final class ParityAliasMapping {
  static const Map<String, String> upstreamToDart = <String, String>{
    'Renderable': 'BaseRenderable',
    'BoxRenderable': 'BoxRenderable',
    'TextRenderable': 'TextRenderable',
    'InputRenderable': 'InputRenderable',
    'SelectRenderable': 'SelectRenderable',
    'CliRenderer': 'CliRenderer',
    'createCliRenderer': 'createCliRenderer',
  };
}
