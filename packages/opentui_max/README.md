# opentui_max

`opentui_max` is an independent, pure Dart OpenTUI port package targeting CLI + Flutter Desktop/Mobile/Web.

## Entry points

- `package:opentui_max/opentui_max.dart`
- `package:opentui_max/core.dart`
- `package:opentui_max/react.dart`
- `package:opentui_max/solid.dart`
- `package:opentui_max/web.dart`

## Scope in 0.1.0

- Core: frame buffer, ANSI diff renderer, layout, focus loop, input/select widgets.
- React-style layer: element tree -> core node tree adapter.
- Solid-style layer: signal + reactive renderer adapter.
- Web layer: frame-to-HTML runtime renderer.
- Parity tooling: `tool/parity_manifest.yaml` and generator for upstream export tracking.

## Compatibility layer

- `lib/src/compat/parity_aliases.dart` exposes upstream-friendly aliases such as:
  - `Renderable -> TuiNode`
  - `BoxRenderable -> TuiBox`
  - `TextRenderable -> TuiText`
  - `InputRenderable -> TuiInput`
  - `SelectRenderable -> TuiSelect`
- Alias mappings are documented in-code and tied to parity-manifest tracking.

## Platform support

- Dart CLI: macOS/Linux/Windows
- Flutter: Android/iOS/Web/macOS/Linux/Windows

## Examples

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui/packages/opentui_max

dart run example/core_counter.dart
dart run example/react_style_demo.dart
dart run example/solid_style_demo.dart
dart run example/web_playground.dart
```

## Parity tooling

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui/packages/opentui_max
dart run tool/generate_parity_manifest.dart
```
