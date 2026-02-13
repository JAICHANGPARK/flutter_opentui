import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'native_library.dart';

typedef _GetBufferWidthNative = Uint32 Function(Pointer<Void> bufferPtr);
typedef _GetBufferWidthDart = int Function(Pointer<Void> bufferPtr);

typedef _GetBufferHeightNative = Uint32 Function(Pointer<Void> bufferPtr);
typedef _GetBufferHeightDart = int Function(Pointer<Void> bufferPtr);

typedef _BufferClearNative =
    Void Function(Pointer<Void> bufferPtr, Pointer<Float> bg);
typedef _BufferClearDart =
    void Function(Pointer<Void> bufferPtr, Pointer<Float> bg);

typedef _BufferFillRectNative =
    Void Function(
      Pointer<Void> bufferPtr,
      Uint32 x,
      Uint32 y,
      Uint32 width,
      Uint32 height,
      Pointer<Float> bg,
    );
typedef _BufferFillRectDart =
    void Function(
      Pointer<Void> bufferPtr,
      int x,
      int y,
      int width,
      int height,
      Pointer<Float> bg,
    );

typedef _BufferSetCellNative =
    Void Function(
      Pointer<Void> bufferPtr,
      Uint32 x,
      Uint32 y,
      Uint32 charCode,
      Pointer<Float> fg,
      Pointer<Float> bg,
      Uint32 attributes,
    );
typedef _BufferSetCellDart =
    void Function(
      Pointer<Void> bufferPtr,
      int x,
      int y,
      int charCode,
      Pointer<Float> fg,
      Pointer<Float> bg,
      int attributes,
    );

typedef _BufferDrawTextNative =
    Void Function(
      Pointer<Void> bufferPtr,
      Pointer<Utf8> textPtr,
      Uint32 textLen,
      Uint32 x,
      Uint32 y,
      Pointer<Float> fg,
      Pointer<Float> bg,
      Uint32 attributes,
    );
typedef _BufferDrawTextDart =
    void Function(
      Pointer<Void> bufferPtr,
      Pointer<Utf8> textPtr,
      int textLen,
      int x,
      int y,
      Pointer<Float> fg,
      Pointer<Float> bg,
      int attributes,
    );

final class OpenTuiNativeBuffer {
  OpenTuiNativeBuffer.fromHandle({required this.library, required this.handle})
    : _getWidth = library.dynamicLibrary
          .lookupFunction<_GetBufferWidthNative, _GetBufferWidthDart>(
            'getBufferWidth',
          ),
      _getHeight = library.dynamicLibrary
          .lookupFunction<_GetBufferHeightNative, _GetBufferHeightDart>(
            'getBufferHeight',
          ),
      _clear = library.dynamicLibrary
          .lookupFunction<_BufferClearNative, _BufferClearDart>('bufferClear'),
      _fillRect = library.dynamicLibrary
          .lookupFunction<_BufferFillRectNative, _BufferFillRectDart>(
            'bufferFillRect',
          ),
      _setCell = library.dynamicLibrary
          .lookupFunction<_BufferSetCellNative, _BufferSetCellDart>(
            'bufferSetCell',
          ),
      _drawText = library.dynamicLibrary
          .lookupFunction<_BufferDrawTextNative, _BufferDrawTextDart>(
            'bufferDrawText',
          );

  final OpenTuiNativeLibrary library;
  final Pointer<Void> handle;

  final _GetBufferWidthDart _getWidth;
  final _GetBufferHeightDart _getHeight;
  final _BufferClearDart _clear;
  final _BufferFillRectDart _fillRect;
  final _BufferSetCellDart _setCell;
  final _BufferDrawTextDart _drawText;

  int get width => _getWidth(handle);

  int get height => _getHeight(handle);

  void clear({List<double> bg = const <double>[0, 0, 0, 1]}) {
    final bgPtr = _toRgbaPointer(bg);
    try {
      _clear(handle, bgPtr);
    } finally {
      calloc.free(bgPtr);
    }
  }

  void fillRect({
    required int x,
    required int y,
    required int width,
    required int height,
    List<double> bg = const <double>[0, 0, 0, 1],
  }) {
    final bgPtr = _toRgbaPointer(bg);
    try {
      _fillRect(handle, x, y, width, height, bgPtr);
    } finally {
      calloc.free(bgPtr);
    }
  }

  void setCell({
    required int x,
    required int y,
    required int charCode,
    List<double> fg = const <double>[1, 1, 1, 1],
    List<double> bg = const <double>[0, 0, 0, 1],
    int attributes = 0,
  }) {
    final fgPtr = _toRgbaPointer(fg);
    final bgPtr = _toRgbaPointer(bg);
    try {
      _setCell(handle, x, y, charCode, fgPtr, bgPtr, attributes);
    } finally {
      calloc.free(fgPtr);
      calloc.free(bgPtr);
    }
  }

  void drawText({
    required String text,
    required int x,
    required int y,
    List<double> fg = const <double>[1, 1, 1, 1],
    List<double>? bg,
    int attributes = 0,
  }) {
    final textPtr = text.toNativeUtf8();
    final fgPtr = _toRgbaPointer(fg);
    final bgPtr = bg == null ? nullptr.cast<Float>() : _toRgbaPointer(bg);
    try {
      _drawText(handle, textPtr, text.length, x, y, fgPtr, bgPtr, attributes);
    } finally {
      calloc.free(textPtr);
      calloc.free(fgPtr);
      if (bg != null) {
        calloc.free(bgPtr);
      }
    }
  }

  Pointer<Float> _toRgbaPointer(List<double> rgba) {
    if (rgba.length != 4) {
      throw ArgumentError.value(rgba, 'rgba', 'RGBA must contain 4 floats.');
    }
    final ptr = calloc<Float>(4);
    for (var i = 0; i < 4; i++) {
      ptr[i] = rgba[i].toDouble();
    }
    return ptr;
  }
}
