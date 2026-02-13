import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'native_library.dart';

typedef _SetCursorPositionNative =
    Void Function(Pointer<Void> rendererPtr, Int32 x, Int32 y, Uint8 visible);
typedef _SetCursorPositionDart =
    void Function(Pointer<Void> rendererPtr, int x, int y, int visible);

typedef _SetCursorStyleNative =
    Void Function(
      Pointer<Void> rendererPtr,
      Pointer<Utf8> stylePtr,
      Uint64 styleLen,
      Uint8 blinking,
    );
typedef _SetCursorStyleDart =
    void Function(
      Pointer<Void> rendererPtr,
      Pointer<Utf8> stylePtr,
      int styleLen,
      int blinking,
    );

typedef _SetupTerminalNative =
    Void Function(Pointer<Void> rendererPtr, Uint8 useAlternateScreen);
typedef _SetupTerminalDart =
    void Function(Pointer<Void> rendererPtr, int useAlternateScreen);

typedef _RestoreTerminalModesNative = Void Function(Pointer<Void> rendererPtr);
typedef _RestoreTerminalModesDart = void Function(Pointer<Void> rendererPtr);

typedef _WriteOutNative =
    Void Function(
      Pointer<Void> rendererPtr,
      Pointer<Utf8> dataPtr,
      Uint64 dataLen,
    );
typedef _WriteOutDart =
    void Function(
      Pointer<Void> rendererPtr,
      Pointer<Utf8> dataPtr,
      int dataLen,
    );

final class OpenTuiNativeTerminal {
  OpenTuiNativeTerminal.fromRenderer({
    required OpenTuiNativeLibrary library,
    required Pointer<Void> rendererPtr,
  }) : _rendererPtr = rendererPtr,
       _setCursorPosition = library.dynamicLibrary
           .lookupFunction<_SetCursorPositionNative, _SetCursorPositionDart>(
             'setCursorPosition',
           ),
       _setCursorStyle = library.dynamicLibrary
           .lookupFunction<_SetCursorStyleNative, _SetCursorStyleDart>(
             'setCursorStyle',
           ),
       _setupTerminal = library.dynamicLibrary
           .lookupFunction<_SetupTerminalNative, _SetupTerminalDart>(
             'setupTerminal',
           ),
       _restoreTerminalModes = library.dynamicLibrary
           .lookupFunction<
             _RestoreTerminalModesNative,
             _RestoreTerminalModesDart
           >('restoreTerminalModes'),
       _writeOut = library.dynamicLibrary
           .lookupFunction<_WriteOutNative, _WriteOutDart>('writeOut');

  final Pointer<Void> _rendererPtr;
  final _SetCursorPositionDart _setCursorPosition;
  final _SetCursorStyleDart _setCursorStyle;
  final _SetupTerminalDart _setupTerminal;
  final _RestoreTerminalModesDart _restoreTerminalModes;
  final _WriteOutDart _writeOut;

  void setCursorPosition({
    required int x,
    required int y,
    bool visible = true,
  }) {
    _setCursorPosition(_rendererPtr, x, y, visible ? 1 : 0);
  }

  void setCursorStyle({required String style, bool blinking = false}) {
    final ptr = style.toNativeUtf8();
    try {
      _setCursorStyle(_rendererPtr, ptr, style.length, blinking ? 1 : 0);
    } finally {
      calloc.free(ptr);
    }
  }

  void setupTerminal({bool useAlternateScreen = true}) {
    _setupTerminal(_rendererPtr, useAlternateScreen ? 1 : 0);
  }

  void restoreTerminalModes() {
    _restoreTerminalModes(_rendererPtr);
  }

  void writeOut(String data) {
    final ptr = data.toNativeUtf8();
    try {
      _writeOut(_rendererPtr, ptr, data.length);
    } finally {
      calloc.free(ptr);
    }
  }
}
