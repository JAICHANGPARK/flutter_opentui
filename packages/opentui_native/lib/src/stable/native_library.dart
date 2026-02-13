import 'dart:ffi';

import '../raw/bindings.dart';
import '../raw/symbols.dart';
import '../runtime/library_locator.dart';
import 'info.dart';

final class OpenTuiNativeLibrary {
  OpenTuiNativeLibrary._({
    required this.info,
    required DynamicLibrary? dynamicLibrary,
  }) : _dynamicLibrary = dynamicLibrary;

  final DynamicLibrary? _dynamicLibrary;
  final OpenTuiNativeInfo info;

  bool get isLoaded => _dynamicLibrary != null;

  DynamicLibrary get dynamicLibrary {
    final library = _dynamicLibrary;
    if (library == null) {
      throw StateError('Native library is not loaded.');
    }
    return library;
  }

  static OpenTuiNativeLibrary auto({
    String? overridePath,
    bool throwOnFailure = false,
  }) {
    final os = OpenTuiNativeLibraryLocator.detectOs();
    final arch = OpenTuiNativeLibraryLocator.detectArch();

    String? resolvedPath;
    DynamicLibrary? loadedLibrary;

    if (overridePath != null) {
      resolvedPath = overridePath;
    } else {
      resolvedPath = OpenTuiNativeLibraryLocator.resolveExistingLibraryPath();
    }

    if (resolvedPath != null) {
      try {
        loadedLibrary = DynamicLibrary.open(resolvedPath);
      } on Object {
        if (throwOnFailure) {
          rethrow;
        }
      }
    }

    final symbols = loadedLibrary == null
        ? <String>{}
        : OpenTuiRawBindings(loadedLibrary).loadedSymbols();

    return OpenTuiNativeLibrary._(
      dynamicLibrary: loadedLibrary,
      info: OpenTuiNativeInfo(
        os: os,
        arch: arch,
        upstreamTag: 'ref-snapshot-2026-02-13',
        upstreamCommit: 'local-ref',
        libraryPath: loadedLibrary == null ? null : resolvedPath,
        loadedSymbols: symbols,
      ),
    );
  }

  bool hasSymbol(String name) {
    if (_dynamicLibrary == null) {
      return false;
    }
    return OpenTuiNativeSymbols.allSet.contains(name) &&
        OpenTuiRawBindings(dynamicLibrary).hasSymbol(name);
  }

  Pointer<NativeType>? lookupRawPointer(String symbol) {
    if (_dynamicLibrary == null) {
      return null;
    }
    return OpenTuiRawBindings(dynamicLibrary).lookupRawPointer(symbol);
  }
}
