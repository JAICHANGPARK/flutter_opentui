# opentui_native

`opentui_native` provides Zig FFI bindings for OpenTUI with bundled prebuilt native libraries.

## Scope

- Stable wrappers:
  - `OpenTuiNativeLibrary`
  - `OpenTuiNativeRenderer`
  - `OpenTuiNativeBuffer`
  - `OpenTuiNativeTerminal`
- Raw symbol namespace (`package:opentui_native/raw.dart`) with typed metadata.
  - Raw API is marked `@experimental`.

## Platforms

Officially supported in `0.1.0`:

- macOS (arm64, x64)
- Linux (arm64, x64)
- Windows (x64)
- Android (arm64)
- iOS (arm64)

Not supported:

- Web (`dart:ffi` unavailable)

## Usage

```dart
import 'package:opentui_native/opentui_native.dart';

void main() {
  final lib = OpenTuiNativeLibrary.auto();
  final renderer = OpenTuiNativeRenderer.create(
    library: lib,
    width: 80,
    height: 24,
  );

  renderer.render(force: true);
  renderer.dispose();
}
```

## Build prebuilt artifacts

```bash
cd /Users/jaichang/Documents/GitHub/flutter_opentui/packages/opentui_native
./tool/build_prebuilt.sh
dart run tool/verify_checksums.dart
dart run tool/verify_platform_coverage.dart
```

Notes:
- Desktop and Android artifacts are built via Zig cross-targets.
- iOS artifact generation requires Apple SDK tooling and is validated as layout coverage in CI.
