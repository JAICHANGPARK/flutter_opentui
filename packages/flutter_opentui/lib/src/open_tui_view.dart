import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:opentui/opentui.dart';

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
        );
      },
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final special = _mapSpecialKey(event.logicalKey);
    final ctrl = HardwareKeyboard.instance.isControlPressed;
    final alt = HardwareKeyboard.instance.isAltPressed;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    if (special != null) {
      widget.controller.sendKeyEvent(
        TuiKeyEvent.special(special, ctrl: ctrl, alt: alt, shift: shift),
      );
      return KeyEventResult.handled;
    }

    final character = event.character;
    if (character != null &&
        character.isNotEmpty &&
        !_isControlCharacter(character)) {
      widget.controller.sendKeyEvent(
        TuiKeyEvent.character(character, ctrl: ctrl, alt: alt, shift: shift),
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
    return null;
  }

  bool _isControlCharacter(String input) {
    if (input.isEmpty) {
      return true;
    }
    return input.codeUnitAt(0) < 32;
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
