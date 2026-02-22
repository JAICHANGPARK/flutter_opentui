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
- `examples/flutter_opentui_demo`: Flutter component catalog showing all OpenTUI node components.
- Flutter examples include `android/`, `ios/`, `macos/`, and `web/` projects for direct platform runs.

`examples/dart_cli_counter` includes:
- `bin/main.dart`: simple counter + input/select focus sample.
- `bin/opencode.dart`: OpenCode-style multi-panel CLI workspace demo.

## Docs

- docs index: [`docs/README.md`](docs/README.md)
- OpenTUI getting started: [`docs/getting-started.md`](docs/getting-started.md)
- Flutter getting started: [`docs/flutter/getting-started.md`](docs/flutter/getting-started.md)
- components guide: [`docs/components/README.md`](docs/components/README.md)

## Development

```bash
dart pub get
dart run melos bootstrap
dart run melos run analyze
dart run melos run test
```
