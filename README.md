# flutter_opentui

Monorepo for OpenTUI in Dart and Flutter.

## Packages

- `packages/opentui`: pure Dart TUI engine for terminal applications.
- `packages/flutter_opentui`: canonical Flutter plugin/widget adapter for rendering OpenTUI frames.
- `packages/opentui_flutter`: compatibility shim that re-exports `flutter_opentui`.
- `packages/opentui_native`: Zig FFI bindings package with bundled native artifact layout.
- `packages/opentui_max`: independent pure Dart max-compat layer with core/react/solid/web entrypoints.

## Examples

- `examples/dart_cli_counter`: CLI sample using `opentui`.
- `examples/flutter_terminal_demo`: Flutter sample using `flutter_opentui` with touch controls.
- `examples/flutter_opentui_demo`: compact Flutter sample using `flutter_opentui`.

## Development

```bash
dart pub get
dart run melos bootstrap
dart run melos run analyze
dart run melos run test
```
