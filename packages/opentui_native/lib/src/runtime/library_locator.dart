import 'dart:io';

final class OpenTuiNativeLibraryLocator {
  const OpenTuiNativeLibraryLocator._();

  static String detectOs() {
    if (Platform.isMacOS) {
      return 'macos';
    }
    if (Platform.isLinux) {
      return 'linux';
    }
    if (Platform.isWindows) {
      return 'windows';
    }
    if (Platform.isAndroid) {
      return 'android';
    }
    if (Platform.isIOS) {
      return 'ios';
    }
    return 'unsupported';
  }

  static String detectArch() {
    final version = Platform.version.toLowerCase();
    if (version.contains('arm64') || version.contains('aarch64')) {
      return 'arm64';
    }
    if (version.contains('x64') || version.contains('x86_64')) {
      return 'x64';
    }
    return 'unknown';
  }

  static String dynamicLibraryFileName({String? os}) {
    final targetOs = os ?? detectOs();
    if (targetOs == 'windows') {
      return 'opentui_native.dll';
    }
    if (targetOs == 'macos' || targetOs == 'ios') {
      return 'libopentui_native.dylib';
    }
    return 'libopentui_native.so';
  }

  static List<String> candidatePaths({String? baseDir}) {
    final root =
        baseDir ??
        Platform.environment['OPENTUI_NATIVE_LIB_DIR'] ??
        Directory.current.path;
    final os = detectOs();
    final arch = detectArch();
    final fileName = dynamicLibraryFileName(os: os);

    return <String>[
      '$root/native/$os/$arch/$fileName',
      '$root/native/$os-$arch/$fileName',
      '$root/$fileName',
      fileName,
    ];
  }

  static String? resolveExistingLibraryPath({String? baseDir}) {
    for (final candidate in candidatePaths(baseDir: baseDir)) {
      final file = File(candidate);
      if (file.existsSync()) {
        return file.path;
      }
    }
    return null;
  }
}
