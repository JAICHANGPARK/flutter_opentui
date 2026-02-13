import 'dart:ffi';

import 'native_buffer.dart';
import 'native_library.dart';
import 'native_terminal.dart';

typedef _CreateRendererNative =
    Pointer<Void> Function(
      Uint32 width,
      Uint32 height,
      Uint8 testing,
      Uint8 remote,
    );
typedef _CreateRendererDart =
    Pointer<Void> Function(int width, int height, int testing, int remote);

typedef _DestroyRendererNative = Void Function(Pointer<Void> rendererPtr);
typedef _DestroyRendererDart = void Function(Pointer<Void> rendererPtr);

typedef _RenderNative = Void Function(Pointer<Void> rendererPtr, Uint8 force);
typedef _RenderDart = void Function(Pointer<Void> rendererPtr, int force);

typedef _ResizeRendererNative =
    Void Function(Pointer<Void> rendererPtr, Uint32 width, Uint32 height);
typedef _ResizeRendererDart =
    void Function(Pointer<Void> rendererPtr, int width, int height);

typedef _GetCurrentBufferNative =
    Pointer<Void> Function(Pointer<Void> rendererPtr);
typedef _GetCurrentBufferDart =
    Pointer<Void> Function(Pointer<Void> rendererPtr);

typedef _GetNextBufferNative =
    Pointer<Void> Function(Pointer<Void> rendererPtr);
typedef _GetNextBufferDart = Pointer<Void> Function(Pointer<Void> rendererPtr);

final class OpenTuiNativeRenderer {
  OpenTuiNativeRenderer._({
    required this.library,
    required Pointer<Void> handle,
  }) : _handle = handle,
       _destroy = library.dynamicLibrary
           .lookupFunction<_DestroyRendererNative, _DestroyRendererDart>(
             'destroyRenderer',
           ),
       _render = library.dynamicLibrary
           .lookupFunction<_RenderNative, _RenderDart>('render'),
       _resize = library.dynamicLibrary
           .lookupFunction<_ResizeRendererNative, _ResizeRendererDart>(
             'resizeRenderer',
           ),
       _getCurrentBuffer = library.dynamicLibrary
           .lookupFunction<_GetCurrentBufferNative, _GetCurrentBufferDart>(
             'getCurrentBuffer',
           ),
       _getNextBuffer = library.dynamicLibrary
           .lookupFunction<_GetNextBufferNative, _GetNextBufferDart>(
             'getNextBuffer',
           ),
       terminal = OpenTuiNativeTerminal.fromRenderer(
         library: library,
         rendererPtr: handle,
       );

  final OpenTuiNativeLibrary library;
  final Pointer<Void> _handle;
  final _DestroyRendererDart _destroy;
  final _RenderDart _render;
  final _ResizeRendererDart _resize;
  final _GetCurrentBufferDart _getCurrentBuffer;
  final _GetNextBufferDart _getNextBuffer;

  final OpenTuiNativeTerminal terminal;

  bool _disposed = false;

  static OpenTuiNativeRenderer create({
    required OpenTuiNativeLibrary library,
    required int width,
    required int height,
    bool testing = false,
    bool remote = false,
  }) {
    if (!library.isLoaded) {
      throw StateError('Native library is not loaded.');
    }

    final create = library.dynamicLibrary
        .lookupFunction<_CreateRendererNative, _CreateRendererDart>(
          'createRenderer',
        );
    final ptr = create(width, height, testing ? 1 : 0, remote ? 1 : 0);
    if (ptr.address == 0) {
      throw StateError('Failed to create native renderer.');
    }

    return OpenTuiNativeRenderer._(library: library, handle: ptr);
  }

  Pointer<Void> get handle => _handle;

  OpenTuiNativeBuffer get currentBuffer => OpenTuiNativeBuffer.fromHandle(
    library: library,
    handle: _getCurrentBuffer(_handle),
  );

  OpenTuiNativeBuffer get nextBuffer => OpenTuiNativeBuffer.fromHandle(
    library: library,
    handle: _getNextBuffer(_handle),
  );

  void render({bool force = false}) {
    _assertAlive();
    _render(_handle, force ? 1 : 0);
  }

  void resize({required int width, required int height}) {
    _assertAlive();
    _resize(_handle, width, height);
  }

  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _destroy(_handle);
  }

  void _assertAlive() {
    if (_disposed) {
      throw StateError('Renderer is disposed.');
    }
  }
}
