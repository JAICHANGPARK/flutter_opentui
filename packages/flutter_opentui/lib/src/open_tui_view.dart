import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opentui/opentui.dart';

import 'flutter_input_source.dart';
import 'opentui_controller.dart';

final class OpenTuiView extends StatefulWidget {
  const OpenTuiView({
    required this.controller,
    required this.root,
    super.key,
    this.cellWidth = 9,
    this.cellHeight = 18,
    this.autofocus = true,
    this.backgroundColor = Colors.black,
    this.textStyle = const TextStyle(
      color: Colors.white,
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.0,
    ),
  });

  final OpenTuiController controller;
  final TuiNode root;
  final double cellWidth;
  final double cellHeight;
  final bool autofocus;
  final Color backgroundColor;
  final TextStyle textStyle;

  @override
  State<OpenTuiView> createState() => _OpenTuiViewState();
}

final class _OpenTuiViewState extends State<OpenTuiView> {
  late FocusNode _focusNode;

  bool _ownsEngine = false;
  int _lastColumns = -1;
  int _lastRows = -1;
  TuiMouseButton _activeMouseButton = TuiMouseButton.none;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'OpenTuiView');
    widget.controller.addListener(_onControllerChanged);
    _initEngine();
  }

  @override
  void didUpdateWidget(covariant OpenTuiView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);

      if (_ownsEngine) {
        oldWidget.controller.detach(disposeEngine: true);
      }
      _initEngine();
      return;
    }

    if (oldWidget.root != widget.root) {
      final engine = widget.controller.engine;
      if (engine != null) {
        engine.mount(widget.root);
        engine.render();
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (_ownsEngine) {
      widget.controller.detach(disposeEngine: true);
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final size = constraints.biggest;
        final width = size.width.isFinite
            ? size.width
            : MediaQuery.sizeOf(context).width;
        final height = size.height.isFinite
            ? size.height
            : MediaQuery.sizeOf(context).height;

        final columns = math.max(1, (width / widget.cellWidth).floor());
        final rows = math.max(1, (height / widget.cellHeight).floor());

        if (columns != _lastColumns || rows != _lastRows) {
          _lastColumns = columns;
          _lastRows = rows;
          widget.controller.sendResize(width: columns, height: rows);
        }

        return Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onKeyEvent: _onKeyEvent,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
            onPointerSignal: (PointerSignalEvent event) {
              if (event is PointerScrollEvent) {
                _onPointerScroll(event);
              }
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _focusNode.requestFocus,
              child: ColoredBox(
                color: widget.backgroundColor,
                child: CustomPaint(
                  size: Size(width, height),
                  painter: _TuiFramePainter(
                    frame: widget.controller.latestFrame,
                    cellWidth: widget.cellWidth,
                    cellHeight: widget.cellHeight,
                    textStyle: widget.textStyle,
                    backgroundColor: widget.backgroundColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final alt = HardwareKeyboard.instance.isAltPressed;
    final meta = HardwareKeyboard.instance.isMetaPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;
    final metadata = FlutterKeyMetadata(
      character: event.character,
      logicalKeyLabel: event.logicalKey.keyLabel,
      logicalKeyId: event.logicalKey.keyId,
      physicalKeyId: event.physicalKey.usbHidUsage,
      physicalKeyDebugName: event.physicalKey.debugName,
      isRepeat: event is KeyRepeatEvent,
    );
    final special = _mapSpecialKey(event.logicalKey);

    if (special != null) {
      widget.controller.sendSpecialKey(
        special,
        ctrl: ctrl,
        alt: alt,
        shift: shift,
        meta: meta,
        option: alt,
        metadata: metadata,
      );
      return KeyEventResult.handled;
    }

    if (ctrl && !alt && event.logicalKey == LogicalKeyboardKey.keyC) {
      widget.controller.sendSpecialKey(
        TuiSpecialKey.ctrlC,
        ctrl: true,
        alt: alt,
        shift: shift,
        meta: meta,
        option: alt,
        metadata: metadata,
      );
      return KeyEventResult.handled;
    }

    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        !_isControlCharacter(character)) {
      if (character.runes.length > 1) {
        widget.controller.sendPaste(
          character,
          ctrl: ctrl,
          alt: alt,
          shift: shift,
          meta: meta,
          option: alt,
          metadata: metadata,
        );
        return KeyEventResult.handled;
      }

      widget.controller.sendCharacter(
        character,
        ctrl: ctrl,
        alt: alt,
        shift: shift,
        meta: meta,
        option: alt,
        metadata: metadata,
      );
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initEngine() {
    final existing = widget.controller.engine;
    if (existing != null) {
      _ownsEngine = false;
      existing.mount(widget.root);
      existing.render();
      return;
    }

    final engine = TuiEngine(
      inputSource: widget.controller.inputSource,
      outputSink: widget.controller.outputSink,
      viewportWidth: 1,
      viewportHeight: 1,
    );
    widget.controller.attachEngine(engine);
    engine.mount(widget.root);
    engine.render();
    _ownsEngine = true;
  }

  TuiSpecialKey? _mapSpecialKey(LogicalKeyboardKey key) {
    if (key == LogicalKeyboardKey.tab) {
      return TuiSpecialKey.tab;
    }
    if (key == LogicalKeyboardKey.enter) {
      return TuiSpecialKey.enter;
    }
    if (key == LogicalKeyboardKey.backspace) {
      return TuiSpecialKey.backspace;
    }
    if (key == LogicalKeyboardKey.delete) {
      return TuiSpecialKey.delete;
    }
    if (key == LogicalKeyboardKey.escape) {
      return TuiSpecialKey.escape;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      return TuiSpecialKey.arrowUp;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      return TuiSpecialKey.arrowDown;
    }
    if (key == LogicalKeyboardKey.arrowLeft) {
      return TuiSpecialKey.arrowLeft;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      return TuiSpecialKey.arrowRight;
    }
    if (key == LogicalKeyboardKey.home) {
      return TuiSpecialKey.home;
    }
    if (key == LogicalKeyboardKey.end) {
      return TuiSpecialKey.end;
    }
    if (key == LogicalKeyboardKey.pageUp) {
      return TuiSpecialKey.pageUp;
    }
    if (key == LogicalKeyboardKey.pageDown) {
      return TuiSpecialKey.pageDown;
    }
    return null;
  }

  bool _isControlCharacter(String input) {
    if (input.isEmpty) {
      return true;
    }
    return input.codeUnitAt(0) < 32;
  }

  void _onPointerDown(PointerDownEvent event) {
    _focusNode.requestFocus();
    final cell = _toCell(event.localPosition);
    final modifiers = _modifierState();
    final button = _buttonFromButtons(event.buttons);
    _activeMouseButton = button;
    widget.controller.sendMouse(
      type: TuiMouseEventType.down,
      x: cell.$1,
      y: cell.$2,
      button: button,
      shift: modifiers.shift,
      alt: modifiers.alt,
      ctrl: modifiers.ctrl,
      meta: modifiers.meta,
      option: modifiers.alt,
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    final cell = _toCell(event.localPosition);
    final modifiers = _modifierState();
    final dragging = event.buttons != 0;
    widget.controller.sendMouse(
      type: dragging ? TuiMouseEventType.drag : TuiMouseEventType.move,
      x: cell.$1,
      y: cell.$2,
      button: dragging ? _activeMouseButton : TuiMouseButton.none,
      shift: modifiers.shift,
      alt: modifiers.alt,
      ctrl: modifiers.ctrl,
      meta: modifiers.meta,
      option: modifiers.alt,
    );
  }

  void _onPointerUp(PointerUpEvent event) {
    final cell = _toCell(event.localPosition);
    final modifiers = _modifierState();
    widget.controller.sendMouse(
      type: TuiMouseEventType.up,
      x: cell.$1,
      y: cell.$2,
      button: _activeMouseButton,
      shift: modifiers.shift,
      alt: modifiers.alt,
      ctrl: modifiers.ctrl,
      meta: modifiers.meta,
      option: modifiers.alt,
    );
    _activeMouseButton = TuiMouseButton.none;
  }

  void _onPointerScroll(PointerScrollEvent event) {
    final cell = _toCell(event.localPosition);
    final modifiers = _modifierState();
    final delta = event.scrollDelta;
    final horizontal = delta.dx.abs() > delta.dy.abs();
    final direction = horizontal
        ? (delta.dx < 0
              ? TuiScrollDirection.left
              : TuiScrollDirection.right)
        : (delta.dy < 0 ? TuiScrollDirection.up : TuiScrollDirection.down);
    final units = horizontal
        ? (delta.dx.abs() / widget.cellWidth).ceil()
        : (delta.dy.abs() / widget.cellHeight).ceil();
    widget.controller.sendMouse(
      type: TuiMouseEventType.scroll,
      x: cell.$1,
      y: cell.$2,
      button: TuiMouseButton.none,
      shift: modifiers.shift,
      alt: modifiers.alt,
      ctrl: modifiers.ctrl,
      meta: modifiers.meta,
      option: modifiers.alt,
      scroll: TuiScrollInfo(direction: direction, delta: math.max(1, units)),
    );
  }

  TuiMouseButton _buttonFromButtons(int buttons) {
    if ((buttons & kPrimaryMouseButton) != 0) {
      return TuiMouseButton.left;
    }
    if ((buttons & kMiddleMouseButton) != 0) {
      return TuiMouseButton.middle;
    }
    if ((buttons & kSecondaryMouseButton) != 0) {
      return TuiMouseButton.right;
    }
    return TuiMouseButton.none;
  }

  (int, int) _toCell(Offset localPosition) {
    final maxX = math.max(0, _lastColumns - 1);
    final maxY = math.max(0, _lastRows - 1);
    final x = (localPosition.dx / widget.cellWidth)
        .floor()
        .clamp(0, maxX)
        .toInt();
    final y = (localPosition.dy / widget.cellHeight)
        .floor()
        .clamp(0, maxY)
        .toInt();
    return (x, y);
  }

  ({bool shift, bool alt, bool ctrl, bool meta}) _modifierState() {
    final keyboard = HardwareKeyboard.instance;
    return (
      shift: keyboard.isShiftPressed,
      alt: keyboard.isAltPressed,
      ctrl: keyboard.isControlPressed,
      meta: keyboard.isMetaPressed,
    );
  }
}

final class _TuiFramePainter extends CustomPainter {
  _TuiFramePainter({
    required this.frame,
    required this.cellWidth,
    required this.cellHeight,
    required this.textStyle,
    required this.backgroundColor,
  });

  final TuiFrame? frame;
  final double cellWidth;
  final double cellHeight;
  final TextStyle textStyle;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;
    canvas.drawRect(fullRect, Paint()..color = backgroundColor);

    final activeFrame = frame;
    if (activeFrame == null) {
      return;
    }

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    final maxRows = math.min(
      activeFrame.height,
      (size.height / cellHeight).ceil(),
    );
    final maxColumns = math.min(
      activeFrame.width,
      (size.width / cellWidth).ceil(),
    );

    for (var y = 0; y < maxRows; y++) {
      for (var x = 0; x < maxColumns; x++) {
        final cell = activeFrame.cellAt(x, y);
        final cellRect = Rect.fromLTWH(
          x * cellWidth,
          y * cellHeight,
          cellWidth,
          cellHeight,
        );

        final fg = _toColor(cell.style.foreground);
        final bg = _toColor(cell.style.background);

        final effectiveForeground = cell.style.inverse
            ? (bg ?? Colors.white)
            : (fg ?? Colors.white);
        final effectiveBackground = cell.style.inverse
            ? (fg ?? Colors.white)
            : bg;

        if (effectiveBackground != null) {
          canvas.drawRect(cellRect, Paint()..color = effectiveBackground);
        }

        textPainter.text = TextSpan(
          text: cell.char,
          style: textStyle.copyWith(
            color: effectiveForeground,
            fontWeight: cell.style.bold
                ? FontWeight.bold
                : textStyle.fontWeight,
          ),
        );
        textPainter.layout(minWidth: cellWidth, maxWidth: cellWidth);
        textPainter.paint(canvas, Offset(cellRect.left, cellRect.top));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TuiFramePainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.cellWidth != cellWidth ||
        oldDelegate.cellHeight != cellHeight ||
        oldDelegate.textStyle != textStyle ||
        oldDelegate.backgroundColor != backgroundColor;
  }

  Color? _toColor(TuiColor? color) {
    if (color == null) {
      return null;
    }
    return Color.fromRGBO(color.r, color.g, color.b, 1);
  }
}
