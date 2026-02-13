# opentui_max 0.1.0 Release Notes

Date: 2026-02-13

## Highlights

- Initial `opentui_max` release as an independent pure Dart package.
- Entry points added:
  - `package:opentui_max/opentui_max.dart`
  - `package:opentui_max/core.dart`
  - `package:opentui_max/react.dart`
  - `package:opentui_max/solid.dart`
  - `package:opentui_max/web.dart`

## Core modules

- Engine, frame buffer, ANSI diff renderer, node/layout model, CLI adapter.
- Added pure Dart modules for:
  - `types`, `utils`, `buffer`
  - `syntax_style`
  - `text_buffer`, `text_buffer_view`
  - `edit_buffer`, `editor_view`
  - `renderables`, `console`, `native_span_feed`
  - `post/filters`, `animation/Timeline`

## Layer adapters

- React-style element tree adapter (`OpenTuiReactRenderer`).
- Solid-style signal and renderer adapter (`SolidSignal`, `OpenTuiSolidRenderer`).
- Web runtime frame-to-HTML renderer (`OpenTuiWebRuntime`).

## Parity tracking

- Added `tool/parity_manifest.yaml` with export tracking against `ref/opentui` snapshot.
- Added generator: `tool/generate_parity_manifest.dart`.

## Publish checklist

1. Run:
   - `dart analyze .`
   - `dart test`
   - `dart run tool/generate_parity_manifest.dart`
2. Confirm parity manifest committed and tests green.
3. Run `dart pub publish --dry-run`.
4. Publish: `dart pub publish`.
