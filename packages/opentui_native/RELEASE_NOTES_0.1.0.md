# opentui_native 0.1.0 Release Notes

Date: 2026-02-13

## Highlights

- Initial `opentui_native` release for OpenTUI Zig FFI integration.
- Stable API surface added:
  - `OpenTuiNativeInfo`
  - `OpenTuiNativeLibrary`
  - `OpenTuiNativeRenderer`
  - `OpenTuiNativeBuffer`
  - `OpenTuiNativeTerminal`
- Raw API surface added via `package:opentui_native/raw.dart` with symbol metadata.
- Upstream symbol table generated from `ref/opentui/packages/core/src/zig` and validated by tooling.

## Platform policy

- Official: macOS, Linux, Windows, Android, iOS native directories.
- Web: not supported (`dart:ffi` unavailable).
- iOS: artifact layout is covered; binary build requires Apple SDK toolchain.

## Tooling

- `tool/build_prebuilt.sh` for prebuilt generation.
- `tool/verify_symbols.dart` for Zig export parity checks.
- `tool/verify_checksums.dart` for artifact hash verification.
- `tool/verify_platform_coverage.dart` for required platform layout verification.

## Publish checklist

1. Ensure prebuilt binaries and `native/checksums.sha256` are up to date.
2. Run:
   - `dart analyze .`
   - `dart test`
   - `dart run tool/verify_symbols.dart`
   - `dart run tool/verify_checksums.dart`
   - `dart run tool/verify_platform_coverage.dart`
3. Run `dart pub publish --dry-run`.
4. Publish: `dart pub publish`.
