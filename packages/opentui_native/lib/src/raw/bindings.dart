import 'dart:ffi';

import 'package:meta/meta.dart';

import 'symbols.dart';

enum OpenTuiFfiType {
  voidType,
  pointer,
  boolType,
  i32,
  i64,
  u8,
  u16,
  u32,
  u64,
  usize,
  f32,
  f64,
  unknown,
}

@immutable
final class OpenTuiRawSignature {
  const OpenTuiRawSignature({required this.args, required this.returns});

  final List<OpenTuiFfiType> args;
  final OpenTuiFfiType returns;
}

@experimental
final class OpenTuiRawBindings {
  OpenTuiRawBindings(this.dynamicLibrary);

  final DynamicLibrary dynamicLibrary;

  Pointer<NativeType>? lookupRawPointer(String symbol) {
    try {
      return dynamicLibrary.lookup<NativeType>(symbol);
    } on Object {
      return null;
    }
  }

  bool hasSymbol(String symbol) => lookupRawPointer(symbol) != null;

  Set<String> loadedSymbols() {
    return OpenTuiNativeSymbols.allSet.where(hasSymbol).toSet();
  }
}

final class OpenTuiRawSymbolTable {
  const OpenTuiRawSymbolTable._();

  static const Map<String, OpenTuiRawSignature>
  signatures = <String, OpenTuiRawSignature>{
    'addToCurrentHitGridClipped': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'addToHitGrid': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'attachNativeSpanFeed': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.i32,
    ),
    'attributesGetLinkId': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.u32,
    ),
    'attributesWithLink': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.u32, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.u32,
    ),
    'bufferClearOpacity': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferClearScissorRects': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferClear': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawBox': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawChar': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawEditorView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawGrayscaleBufferSupersampled': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawGrayscaleBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawPackedBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawSuperSampleBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.u8,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawTextBufferView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferDrawText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferFillRect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferGetAttributesPtr': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'bufferGetBgPtr': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'bufferGetCharPtr': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'bufferGetCurrentOpacity': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.f32,
    ),
    'bufferGetFgPtr': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'bufferGetId': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'bufferGetRealCharSize': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'bufferGetRespectAlpha': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.boolType,
    ),
    'bufferPopOpacity': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferPopScissorRect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferPushOpacity': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.f32],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferPushScissorRect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferResize': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferSetCellWithAlphaBlending': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferSetCell': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferSetRespectAlpha': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'bufferWriteResolvedChars': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'checkHit': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'clearClipboardOSC52': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.boolType,
    ),
    'clearCurrentHitGrid': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'clearGlobalLinkPool': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'clearTerminal': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'copyToClipboardOSC52': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u8,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'createEditBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.pointer,
    ),
    'createEditorView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.pointer,
    ),
    'createNativeSpanFeed': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'createOptimizedBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.boolType,
        OpenTuiFfiType.u8,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.pointer,
    ),
    'createRenderer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.boolType,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.pointer,
    ),
    'createSyntaxStyle': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.pointer,
    ),
    'createTextBufferView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'createTextBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.pointer,
    ),
    'destroyEditBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyEditorView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyFrameBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'destroyNativeSpanFeed': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyOptimizedBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyRenderer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroySyntaxStyle': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyTextBufferView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'destroyTextBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'disableKittyKeyboard': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'disableMouse': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'drawFrameBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'dumpBuffers': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.i64],
      returns: OpenTuiFfiType.voidType,
    ),
    'dumpHitGrid': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'dumpStdoutBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.i64],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferCanRedo': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.boolType,
    ),
    'editBufferCanUndo': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.boolType,
    ),
    'editBufferClearHistory': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferClear': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferDebugLogRope': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferDeleteCharBackward': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferDeleteChar': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferDeleteLine': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferDeleteRange': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferGetCursorPosition': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferGetCursor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'editBufferGetEOL': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferGetId': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u16,
    ),
    'editBufferGetLineStartOffset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.u32,
    ),
    'editBufferGetNextWordBoundary': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferGetPrevWordBoundary': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferGetTextBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'editBufferGetTextRangeByCoords': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editBufferGetTextRange': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editBufferGetText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editBufferGotoLine': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferInsertChar': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferInsertText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferMoveCursorDown': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferMoveCursorLeft': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferMoveCursorRight': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferMoveCursorUp': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferNewLine': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferOffsetToPosition': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'editBufferPositionToOffset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'editBufferRedo': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editBufferReplaceTextFromMem': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferReplaceText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferSetCursorByOffset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferSetCursorToLineCol': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferSetCursor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferSetTextFromMem': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferSetText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editBufferUndo': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editorViewClearViewport': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'editorViewDeleteSelectedText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetCursor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetEOL': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetLineInfoDirect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetLogicalLineInfoDirect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetNextWordBoundary': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetPrevWordBoundary': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetSelectedTextBytes': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editorViewGetSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u64,
    ),
    'editorViewGetTextBufferView': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'editorViewGetText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'editorViewGetTotalVirtualLineCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'editorViewGetViewport': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetVirtualLineCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'editorViewGetVisualCursor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetVisualEOL': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewGetVisualSOL': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewMoveDownVisual': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewMoveUpVisual': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewResetLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewResetSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetCursorByOffset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.boolType,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'editorViewSetPlaceholderStyledText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetScrollMargin': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.f32],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetTabIndicatorColor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetTabIndicator': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetViewportSize': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetViewport': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewSetWrapMode': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'editorViewUpdateLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.boolType,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'editorViewUpdateSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'enableKittyKeyboard': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'enableMouse': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'encodeUnicode': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u8,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'freeUnicode': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.usize],
      returns: OpenTuiFfiType.voidType,
    ),
    'getArenaAllocatedBytes': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.usize,
    ),
    'getBufferHeight': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'getBufferWidth': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'getCurrentBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'getCursorState': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'getHitGridDirty': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.boolType,
    ),
    'getKittyKeyboardFlags': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u8,
    ),
    'getLastOutputForTest': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'getNextBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.pointer,
    ),
    'getTerminalCapabilities': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'hitGridClearScissorRects': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'hitGridPopScissorRect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'hitGridPushScissorRect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'linkAlloc': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.u32,
    ),
    'linkGetUrl': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'processCapabilityResponse': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'queryPixelResolution': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'render': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'resizeRenderer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'restoreTerminalModes': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'resumeRenderer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'setBackgroundColor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'setCursorColor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'setCursorPosition': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'setCursorStyle': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'setDebugOverlay': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.boolType,
        OpenTuiFfiType.u8,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'setEventCallback': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'setHyperlinksCapability': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[],
      returns: OpenTuiFfiType.unknown,
    ),
    'setKittyKeyboardFlags': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'setLogCallback': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'setRenderOffset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'setTerminalTitle': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'setUseThread': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'setupTerminal': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'streamClose': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.i32,
    ),
    'streamCommitReserved': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.i32,
    ),
    'streamCommit': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.i32,
    ),
    'streamDrainSpans': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'streamGetStats': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.i32,
    ),
    'streamReserve': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.i32,
    ),
    'streamSetCallback': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'streamSetOptions': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.i32,
    ),
    'streamWrite': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u64,
      ],
      returns: OpenTuiFfiType.i32,
    ),
    'suspendRenderer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'syntaxStyleGetStyleCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.usize,
    ),
    'syntaxStyleRegister': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u8,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'syntaxStyleResolveByName': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferAddHighlightByCharRange': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferAddHighlight': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferAppendFromMemId': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferAppend': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferClearAllHighlights': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferClearLineHighlights': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferClearMemRegistry': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferClear': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferFreeLineHighlights': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.usize],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferGetByteSize': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferGetHighlightCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferGetLength': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferGetLineCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferGetLineHighlightsPtr': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.pointer,
    ),
    'textBufferGetPlainText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'textBufferGetTabWidth': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u8,
    ),
    'textBufferGetTextRangeByCoords': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'textBufferGetTextRange': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'textBufferLoadFile': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'textBufferRegisterMemBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.u16,
    ),
    'textBufferRemoveHighlightsByRef': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u16],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferReplaceMemBuffer': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u8,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
        OpenTuiFfiType.boolType,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'textBufferResetDefaults': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferReset': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetDefaultAttributes': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetDefaultBg': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetDefaultFg': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetStyledText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetSyntaxStyle': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetTabWidth': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferSetTextFromMem': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewGetLineInfoDirect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewGetLogicalLineInfoDirect': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewGetPlainText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'textBufferViewGetSelectedText': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.usize,
      ],
      returns: OpenTuiFfiType.usize,
    ),
    'textBufferViewGetSelectionInfo': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u64,
    ),
    'textBufferViewGetVirtualLineCount': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.u32,
    ),
    'textBufferViewMeasureForDimensions': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'textBufferViewResetLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewResetSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'textBufferViewSetSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetTabIndicatorColor': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.pointer],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetTabIndicator': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetTruncate': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.boolType],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetViewportSize': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetViewport': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetWrapMode': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u8],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewSetWrapWidth': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[OpenTuiFfiType.pointer, OpenTuiFfiType.u32],
      returns: OpenTuiFfiType.voidType,
    ),
    'textBufferViewUpdateLocalSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.i32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.boolType,
    ),
    'textBufferViewUpdateSelection': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'updateMemoryStats': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.u32,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'updateStats': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.f64,
        OpenTuiFfiType.u32,
        OpenTuiFfiType.f64,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
    'writeOut': OpenTuiRawSignature(
      args: <OpenTuiFfiType>[
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.pointer,
        OpenTuiFfiType.u64,
      ],
      returns: OpenTuiFfiType.voidType,
    ),
  };
}
