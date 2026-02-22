import 'dart:async';

import 'events.dart';
import 'frame.dart';
import 'node.dart';

final class TuiEngine {
  TuiEngine({
    required this.inputSource,
    required this.outputSink,
    this.viewportWidth = 80,
    this.viewportHeight = 24,
  }) {
    _keySubscription = inputSource.keyEvents.listen(_handleKeyEvent);
    _resizeSubscription = inputSource.resizeEvents.listen(_handleResizeEvent);
  }

  final TuiInputSource inputSource;
  final TuiOutputSink outputSink;

  int viewportWidth;
  int viewportHeight;

  TuiNode? _root;
  TuiNode? _focusedNode;
  TuiFrame? _lastFrame;

  late final StreamSubscription<TuiKeyEvent> _keySubscription;
  late final StreamSubscription<TuiResizeEvent> _resizeSubscription;

  final StreamController<TuiFrame> _framesController =
      StreamController<TuiFrame>.broadcast();

  bool _isDisposed = false;

  Stream<TuiFrame> get frames => _framesController.stream;

  TuiNode? get root => _root;

  TuiNode? get focusedNode => _focusedNode;

  TuiFrame? get lastFrame => _lastFrame;

  void mount(TuiNode rootNode) {
    _assertNotDisposed();
    _root = rootNode;
    _rebuildFocusTree();
  }

  void render() {
    _assertNotDisposed();
    final rootNode = _root;
    if (rootNode == null || viewportWidth <= 0 || viewportHeight <= 0) {
      return;
    }

    _layoutNode(
      rootNode,
      TuiRect(x: 0, y: 0, width: viewportWidth, height: viewportHeight),
    );

    final frame = TuiFrame.blank(width: viewportWidth, height: viewportHeight);
    _paintNode(rootNode, frame);

    _lastFrame = frame.clone();
    final presentResult = outputSink.present(frame);
    if (presentResult is Future<void>) {
      unawaited(presentResult);
    }
    _framesController.add(frame);
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }
    _isDisposed = true;

    await _keySubscription.cancel();
    await _resizeSubscription.cancel();
    await _framesController.close();
  }

  void _handleKeyEvent(TuiKeyEvent event) {
    if (_isDisposed) {
      return;
    }

    if (event.special == TuiSpecialKey.tab) {
      _cycleFocus(forward: !event.shift);
      render();
      return;
    }

    final focused = _focusedNode;
    if (focused != null) {
      focused.onKey(event);
      render();
    }
  }

  void _handleResizeEvent(TuiResizeEvent event) {
    if (_isDisposed) {
      return;
    }
    viewportWidth = event.width;
    viewportHeight = event.height;
    render();
  }

  void _rebuildFocusTree() {
    final rootNode = _root;
    if (rootNode == null) {
      _focusedNode = null;
      return;
    }

    final focusables = <TuiNode>[];
    _collectFocusables(rootNode, focusables);
    if (focusables.isEmpty) {
      _focusedNode = null;
      return;
    }

    for (final node in focusables) {
      node.focused = false;
    }

    _focusedNode = focusables.first;
    _focusedNode!.focused = true;
  }

  void _collectFocusables(TuiNode node, List<TuiNode> output) {
    if (node.focusable) {
      output.add(node);
    }
    for (final child in node.children) {
      _collectFocusables(child, output);
    }
  }

  void _cycleFocus({required bool forward}) {
    final rootNode = _root;
    if (rootNode == null) {
      return;
    }

    final focusables = <TuiNode>[];
    _collectFocusables(rootNode, focusables);
    if (focusables.isEmpty) {
      _focusedNode = null;
      return;
    }

    final previous = _focusedNode;
    final currentIndex = previous == null ? -1 : focusables.indexOf(previous);
    final nextIndex = currentIndex < 0
        ? 0
        : forward
        ? (currentIndex + 1) % focusables.length
        : (currentIndex - 1 + focusables.length) % focusables.length;

    if (previous != null) {
      previous.focused = false;
    }
    _focusedNode = focusables[nextIndex];
    _focusedNode!.focused = true;
  }

  void _layoutNode(TuiNode node, TuiRect bounds) {
    node.setLayoutBounds(bounds);
    if (node.children.isEmpty) {
      return;
    }

    final contentBounds = _contentBounds(node, bounds);
    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      for (final child in node.children) {
        child.setLayoutBounds(
          TuiRect(x: contentBounds.x, y: contentBounds.y, width: 0, height: 0),
        );
      }
      return;
    }

    final layoutDirection = node is TuiBox
        ? node.layoutDirection
        : TuiLayoutDirection.column;

    switch (layoutDirection) {
      case TuiLayoutDirection.absolute:
        _layoutAbsolute(node.children, contentBounds);
      case TuiLayoutDirection.row:
        _layoutRow(node.children, contentBounds);
      case TuiLayoutDirection.column:
        _layoutColumn(node.children, contentBounds);
    }
  }

  TuiRect _contentBounds(TuiNode node, TuiRect bounds) {
    if (node is! TuiBox) {
      return bounds;
    }

    final padding = node.padding;
    final insetLeft = (node.hasBorderLeft ? 1 : 0) + padding;
    final insetTop = (node.hasBorderTop ? 1 : 0) + padding;
    final insetRight = (node.hasBorderRight ? 1 : 0) + padding;
    final insetBottom = (node.hasBorderBottom ? 1 : 0) + padding;

    final x = bounds.x + insetLeft;
    final y = bounds.y + insetTop;
    final width = bounds.width - insetLeft - insetRight;
    final height = bounds.height - insetTop - insetBottom;

    return TuiRect(
      x: x,
      y: y,
      width: width < 0 ? 0 : width,
      height: height < 0 ? 0 : height,
    );
  }

  void _layoutAbsolute(List<TuiNode> children, TuiRect bounds) {
    for (final child in children) {
      final childX = bounds.x + (child.left ?? 0);
      final childY = bounds.y + (child.top ?? 0);
      final childWidth = child.width ?? bounds.width;
      final childHeight = child.height ?? _defaultNodeHeight(child);
      final clamped = _clampRect(
        parent: bounds,
        x: childX,
        y: childY,
        width: childWidth,
        height: childHeight,
      );
      _layoutNode(child, clamped);
    }
  }

  void _layoutRow(List<TuiNode> children, TuiRect bounds) {
    if (children.isEmpty) {
      return;
    }

    final fixedWidth = children
        .where((node) => node.width != null)
        .fold<int>(0, (sum, node) => sum + node.width!);
    final flexCount = children.where((node) => node.width == null).length;
    final freeWidth = (bounds.width - fixedWidth)
        .clamp(0, bounds.width)
        .toInt();
    final flexWidth = flexCount == 0 ? 0 : freeWidth ~/ flexCount;

    var cursorX = bounds.x;
    var flexAssigned = 0;

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;

      final width =
          child.width ??
          (isLast
              ? freeWidth - flexAssigned
              : flexWidth
                    .clamp(0, bounds.width - (cursorX - bounds.x))
                    .toInt());
      if (child.width == null) {
        flexAssigned += width;
      }

      final childY = bounds.y + (child.top ?? 0);
      final childHeight = child.height ?? (bounds.height - (child.top ?? 0));
      final clamped = _clampRect(
        parent: bounds,
        x: cursorX,
        y: childY,
        width: width,
        height: childHeight,
      );
      _layoutNode(child, clamped);
      cursorX += width;
    }
  }

  void _layoutColumn(List<TuiNode> children, TuiRect bounds) {
    if (children.isEmpty) {
      return;
    }

    final fixedHeight = children
        .where((node) => node.height != null)
        .fold<int>(0, (sum, node) => sum + node.height!);
    final flexCount = children.where((node) => node.height == null).length;
    final freeHeight = (bounds.height - fixedHeight)
        .clamp(0, bounds.height)
        .toInt();
    final flexHeight = flexCount == 0 ? 0 : freeHeight ~/ flexCount;

    var cursorY = bounds.y;
    var flexAssigned = 0;

    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final isLast = i == children.length - 1;

      final height =
          child.height ??
          (isLast
              ? freeHeight - flexAssigned
              : flexHeight
                    .clamp(0, bounds.height - (cursorY - bounds.y))
                    .toInt());
      if (child.height == null) {
        flexAssigned += height;
      }

      final childX = bounds.x + (child.left ?? 0);
      final childWidth = child.width ?? (bounds.width - (child.left ?? 0));
      final clamped = _clampRect(
        parent: bounds,
        x: childX,
        y: cursorY,
        width: childWidth,
        height: height,
      );
      _layoutNode(child, clamped);
      cursorY += height;
    }
  }

  int _defaultNodeHeight(TuiNode node) {
    if (node is TuiSelect) {
      return node.options.length;
    }
    return 1;
  }

  TuiRect _clampRect({
    required TuiRect parent,
    required int x,
    required int y,
    required int width,
    required int height,
  }) {
    final startX = x.clamp(parent.x, parent.x + parent.width).toInt();
    final startY = y.clamp(parent.y, parent.y + parent.height).toInt();
    final endX = (x + width).clamp(parent.x, parent.x + parent.width).toInt();
    final endY = (y + height).clamp(parent.y, parent.y + parent.height).toInt();

    return TuiRect(
      x: startX,
      y: startY,
      width: endX - startX,
      height: endY - startY,
    );
  }

  void _paintNode(TuiNode node, TuiFrame frame) {
    final bounds = node.layoutBounds;
    if (bounds == null || bounds.width <= 0 || bounds.height <= 0) {
      return;
    }

    switch (node) {
      case TuiBox box:
        _paintBox(box, bounds, frame);
      case TuiText text:
        _paintText(text, bounds, frame);
      case TuiInput input:
        _paintInput(input, bounds, frame);
      case TuiSelect select:
        _paintSelect(select, bounds, frame);
    }

    for (final child in node.children) {
      _paintNode(child, frame);
    }
  }

  void _paintBox(TuiBox box, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      bounds.height,
      fill: TuiCell(char: ' ', style: box.style),
    );

    if (!box.hasBorder || bounds.width <= 0 || bounds.height <= 0) {
      return;
    }

    final left = bounds.x;
    final right = bounds.x + bounds.width - 1;
    final top = bounds.y;
    final bottom = bounds.y + bounds.height - 1;
    final chars = box.resolvedBorderChars;
    final drawTop = box.hasBorderTop;
    final drawRight = box.hasBorderRight;
    final drawBottom = box.hasBorderBottom;
    final drawLeft = box.hasBorderLeft;

    if (drawTop) {
      for (var x = left; x <= right; x++) {
        frame.setCell(
          x,
          top,
          TuiCell(char: chars.horizontal, style: box.borderStyle),
        );
      }
    }
    if (drawBottom) {
      for (var x = left; x <= right; x++) {
        frame.setCell(
          x,
          bottom,
          TuiCell(char: chars.horizontal, style: box.borderStyle),
        );
      }
    }
    if (drawLeft) {
      for (var y = top; y <= bottom; y++) {
        frame.setCell(
          left,
          y,
          TuiCell(char: chars.vertical, style: box.borderStyle),
        );
      }
    }
    if (drawRight) {
      for (var y = top; y <= bottom; y++) {
        frame.setCell(
          right,
          y,
          TuiCell(char: chars.vertical, style: box.borderStyle),
        );
      }
    }

    void paintCorner({
      required int x,
      required int y,
      required bool hasHorizontal,
      required bool hasVertical,
      required String corner,
    }) {
      if (!hasHorizontal && !hasVertical) {
        return;
      }
      final char = hasHorizontal && hasVertical
          ? corner
          : hasHorizontal
          ? chars.horizontal
          : chars.vertical;
      frame.setCell(x, y, TuiCell(char: char, style: box.borderStyle));
    }

    paintCorner(
      x: left,
      y: top,
      hasHorizontal: drawTop,
      hasVertical: drawLeft,
      corner: chars.topLeft,
    );
    paintCorner(
      x: right,
      y: top,
      hasHorizontal: drawTop,
      hasVertical: drawRight,
      corner: chars.topRight,
    );
    paintCorner(
      x: left,
      y: bottom,
      hasHorizontal: drawBottom,
      hasVertical: drawLeft,
      corner: chars.bottomLeft,
    );
    paintCorner(
      x: right,
      y: bottom,
      hasHorizontal: drawBottom,
      hasVertical: drawRight,
      corner: chars.bottomRight,
    );

    final title = box.title;
    if (drawTop && title != null && title.isNotEmpty) {
      final titleLeft = left + (drawLeft ? 2 : 1);
      final titleRight = right - (drawRight ? 2 : 1);
      final maxTitleWidth = titleRight - titleLeft + 1;
      if (maxTitleWidth > 0) {
        final renderWidth = title.length.clamp(0, maxTitleWidth).toInt();
        var titleX = titleLeft;
        if (box.titleAlignment == TuiTitleAlignment.center) {
          titleX = titleLeft + ((maxTitleWidth - renderWidth) ~/ 2);
        } else if (box.titleAlignment == TuiTitleAlignment.right) {
          titleX = titleRight - renderWidth + 1;
        }
        frame.drawText(
          titleX,
          top,
          title,
          style: box.borderStyle,
          maxWidth: maxTitleWidth,
        );
      }
    }
  }

  void _paintText(TuiText text, TuiRect bounds, TuiFrame frame) {
    final lines = text.text.split('\n');
    for (var i = 0; i < lines.length && i < bounds.height; i++) {
      frame.drawText(
        bounds.x,
        bounds.y + i,
        lines[i],
        style: text.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _paintInput(TuiInput input, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      1,
      fill: TuiCell(char: ' ', style: input.style),
    );

    final hasValue = input.value.isNotEmpty;
    final content = hasValue ? input.value : input.placeholder;
    final baseStyle = hasValue
        ? (input.focused ? input.focusedStyle : input.style)
        : input.placeholderStyle;

    frame.drawText(
      bounds.x,
      bounds.y,
      content,
      style: baseStyle,
      maxWidth: bounds.width,
    );

    if (!input.focused || bounds.width <= 0) {
      return;
    }

    final cursorOffset = input.cursorPosition
        .clamp(0, bounds.width - 1)
        .toInt();
    final cursorX = bounds.x + cursorOffset;
    final currentChar = cursorOffset < content.length
        ? content[cursorOffset]
        : ' ';

    frame.setCell(
      cursorX,
      bounds.y,
      TuiCell(
        char: currentChar,
        style: baseStyle.copyWith(inverse: !baseStyle.inverse),
      ),
    );
  }

  void _paintSelect(TuiSelect select, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      bounds.height,
      fill: TuiCell(char: ' ', style: select.style),
    );

    final visibleRows = bounds.height.clamp(0, select.options.length).toInt();
    for (var i = 0; i < visibleRows; i++) {
      final isSelected = i == select.selectedIndex;
      final marker = isSelected ? (select.focused ? '>' : '*') : ' ';
      final line = '$marker ${select.options[i]}';
      frame.drawText(
        bounds.x,
        bounds.y + i,
        line,
        style: isSelected ? select.selectedStyle : select.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('TuiEngine is disposed.');
    }
  }
}
