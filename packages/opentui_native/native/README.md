# Native Artifacts

Prebuilt native artifacts for `opentui_native` are placed under:

- `native/macos/arm64/`
- `native/macos/x64/`
- `native/linux/arm64/`
- `native/linux/x64/`
- `native/windows/x64/`
- `native/android/arm64/`
- `native/ios/arm64/`

Expected file names:

- macOS/iOS: `libopentui_native.dylib`
- Linux/Android: `libopentui_native.so`
- Windows: `opentui_native.dll`

## Integrity

- `native/checksums.sha256` tracks sha256 hashes for all bundled artifacts.
- Run `dart run tool/verify_checksums.dart` to validate manifest integrity.
- Run `dart run tool/verify_platform_coverage.dart` to validate required platform directory coverage.
