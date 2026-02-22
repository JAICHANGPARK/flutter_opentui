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
    if (presentResult is Future) {
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
    final children = _layoutChildren(node);
    if (children.isEmpty) {
      return;
    }

    final contentBounds = _contentBounds(node, bounds);
    if (contentBounds.width <= 0 || contentBounds.height <= 0) {
      for (final child in children) {
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
        _layoutAbsolute(children, contentBounds);
      case TuiLayoutDirection.row:
        _layoutRow(node, children, contentBounds);
      case TuiLayoutDirection.column:
        _layoutColumn(node, children, contentBounds);
    }
  }

  TuiRect _contentBounds(TuiNode node, TuiRect bounds) {
    if (node is! TuiBox) {
      return bounds;
    }

    final borderInset = node.border ? 1 : 0;
    final insetLeft = borderInset + node.resolvedPaddingLeft;
    final insetTop = borderInset + node.resolvedPaddingTop;
    final insetRight = borderInset + node.resolvedPaddingRight;
    final insetBottom = borderInset + node.resolvedPaddingBottom;

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

  List<TuiNode> _layoutChildren(TuiNode node) {
    if (node is TuiScrollBox) {
      final maxOffset = node.children.isEmpty ? 0 : node.children.length - 1;
      final offset = node.scrollOffset.clamp(0, maxOffset).toInt();
      node.scrollOffset = offset;
      return node.children.skip(offset).toList(growable: false);
    }
    return node.children;
  }

  void _layoutAbsolute(List<TuiNode> children, TuiRect bounds) {
    for (final child in children) {
      final marginLeft = child.resolvedMarginLeft;
      final marginTop = child.resolvedMarginTop;
      final leftOffset = child.left ?? 0;
      final topOffset = child.top ?? 0;
      final availableWidth = bounds.width;
      final availableHeight = bounds.height;
      final childX = bounds.x + leftOffset + marginLeft;
      final childY = bounds.y + topOffset + marginTop;
      final childWidth =
          _resolveWidth(child, availableWidth) ??
          _constrainWidth(child, availableWidth, availableWidth);
      final childHeight =
          _resolveHeight(child, availableHeight) ??
          _constrainHeight(child, _defaultNodeHeight(child), availableHeight);
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

  void _layoutRow(TuiNode container, List<TuiNode> children, TuiRect bounds) {
    _layoutFlow(
      container: container,
      children: children,
      bounds: bounds,
      rowLayout: true,
    );
  }

  void _layoutColumn(
    TuiNode container,
    List<TuiNode> children,
    TuiRect bounds,
  ) {
    _layoutFlow(
      container: container,
      children: children,
      bounds: bounds,
      rowLayout: false,
    );
  }

  void _layoutFlow({
    required TuiNode container,
    required List<TuiNode> children,
    required TuiRect bounds,
    required bool rowLayout,
  }) {
    if (children.isEmpty) {
      return;
    }

    final justify = container is TuiBox ? container.justify : TuiJustify.start;
    final align = container is TuiBox ? container.align : TuiAlign.stretch;
    final wrap = container is TuiBox && container.wrap == TuiWrap.wrap;
    final mainAvailable = rowLayout ? bounds.width : bounds.height;
    final crossAvailable = rowLayout ? bounds.height : bounds.width;

    final flowChildren = children
        .map((child) {
          final margins = _NodeMargins(
            left: child.resolvedMarginLeft,
            top: child.resolvedMarginTop,
            right: child.resolvedMarginRight,
            bottom: child.resolvedMarginBottom,
          );
          final mainMargins =
              margins.mainLeading(rowLayout) + margins.mainTrailing(rowLayout);
          final childMainAvailable = (mainAvailable - mainMargins)
              .clamp(0, mainAvailable)
              .toInt();
          final explicitMainSize = _resolveMainAxisSize(
            child,
            rowLayout,
            childMainAvailable,
          );
          final flexible =
              explicitMainSize == null && _isMainAxisFlexible(child, rowLayout);
          return _FlowChild(
            node: child,
            margins: margins,
            mainAvailable: childMainAvailable,
            explicitMainSize: explicitMainSize,
            minimumMainSize: _minimumMainAxisSize(
              child,
              rowLayout,
              childMainAvailable,
            ),
            flexible: flexible,
          );
        })
        .toList(growable: false);

    final lines = _buildFlowLines(
      children: flowChildren,
      mainAvailable: mainAvailable,
      rowLayout: rowLayout,
      wrap: wrap,
    );
    var cursorCross = rowLayout ? bounds.y.toDouble() : bounds.x.toDouble();
    final crossStart = rowLayout ? bounds.y : bounds.x;
    final crossEnd = crossStart + crossAvailable;

    for (final line in lines) {
      final lineCrossStart = cursorCross.round();
      final remainingCross = (crossEnd - lineCrossStart)
          .clamp(0, crossAvailable)
          .toInt();
      _resolveLineMainSizes(line, mainAvailable, rowLayout);
      final lineCrossExtent = wrap
          ? _resolveLineCrossExtent(
              line: line,
              rowLayout: rowLayout,
              availableCross: remainingCross,
            )
          : remainingCross;
      _placeFlowLine(
        line: line,
        parentBounds: bounds,
        rowLayout: rowLayout,
        align: align,
        justify: justify,
        lineCrossStart: lineCrossStart,
        lineCrossExtent: lineCrossExtent,
      );
      cursorCross += lineCrossExtent;
    }
  }

  List<List<_FlowChild>> _buildFlowLines({
    required List<_FlowChild> children,
    required int mainAvailable,
    required bool rowLayout,
    required bool wrap,
  }) {
    if (!wrap) {
      return <List<_FlowChild>>[children];
    }
    if (children.isEmpty) {
      return const <List<_FlowChild>>[];
    }

    final lines = <List<_FlowChild>>[];
    var current = <_FlowChild>[];
    var currentMain = 0;

    for (final child in children) {
      final baseMainSize = child.explicitMainSize ?? child.minimumMainSize;
      final outerMain =
          child.margins.mainLeading(rowLayout) +
          baseMainSize +
          child.margins.mainTrailing(rowLayout);
      final nextMain = currentMain + outerMain;
      if (current.isNotEmpty && nextMain > mainAvailable) {
        lines.add(current);
        current = <_FlowChild>[];
        currentMain = 0;
      }
      current.add(child);
      currentMain += outerMain;
    }
    if (current.isNotEmpty) {
      lines.add(current);
    }
    return lines;
  }

  void _resolveLineMainSizes(
    List<_FlowChild> line,
    int mainAvailable,
    bool rowLayout,
  ) {
    var occupiedMain = 0;
    var totalFlexGrow = 0.0;
    final flexChildren = <_FlowChild>[];

    for (final child in line) {
      occupiedMain +=
          child.margins.mainLeading(rowLayout) +
          child.margins.mainTrailing(rowLayout);
      final explicit = child.explicitMainSize;
      if (explicit != null) {
        child.mainSize = explicit;
        occupiedMain += explicit;
        continue;
      }
      child.mainSize = 0;
      if (!child.flexible) {
        continue;
      }
      final grow = child.node.flexGrow <= 0 ? 0.0 : child.node.flexGrow;
      totalFlexGrow += grow;
      flexChildren.add(child);
    }

    final freeMain = (mainAvailable - occupiedMain).clamp(0, mainAvailable);
    if (flexChildren.isNotEmpty) {
      final useEvenDistribution = totalFlexGrow <= 0;
      final distributionTotal = useEvenDistribution
          ? flexChildren.length.toDouble()
          : totalFlexGrow;
      var assigned = 0;
      for (var i = 0; i < flexChildren.length; i++) {
        final child = flexChildren[i];
        final remaining = freeMain - assigned;
        final growFactor = useEvenDistribution
            ? 1.0
            : (child.node.flexGrow <= 0 ? 0.0 : child.node.flexGrow);
        final size = i == flexChildren.length - 1
            ? remaining
            : ((freeMain * growFactor) / distributionTotal)
                  .floor()
                  .clamp(0, remaining)
                  .toInt();
        child.mainSize = _constrainMainAxisSize(
          child.node,
          rowLayout,
          size,
          child.mainAvailable,
        );
        assigned += child.mainSize;
      }
    }

    for (final child in line) {
      child.mainSize = _constrainMainAxisSize(
        child.node,
        rowLayout,
        child.mainSize,
        child.mainAvailable,
      );
    }
  }

  int _resolveLineCrossExtent({
    required List<_FlowChild> line,
    required bool rowLayout,
    required int availableCross,
  }) {
    if (availableCross <= 0 || line.isEmpty) {
      return 0;
    }
    var maxCross = 0;
    for (final child in line) {
      final crossMargins =
          child.margins.crossLeading(rowLayout) +
          child.margins.crossTrailing(rowLayout);
      final childCrossAvailable = (availableCross - crossMargins)
          .clamp(0, availableCross)
          .toInt();
      final childCross =
          _resolveCrossAxisSize(child.node, rowLayout, childCrossAvailable) ??
          _constrainCrossAxisSize(
            child.node,
            rowLayout,
            _defaultCrossAxisSize(child.node, rowLayout, childCrossAvailable),
            childCrossAvailable,
          );
      final outerCross = crossMargins + childCross;
      if (outerCross > maxCross) {
        maxCross = outerCross;
      }
    }
    return maxCross.clamp(0, availableCross).toInt();
  }

  void _placeFlowLine({
    required List<_FlowChild> line,
    required TuiRect parentBounds,
    required bool rowLayout,
    required TuiAlign align,
    required TuiJustify justify,
    required int lineCrossStart,
    required int lineCrossExtent,
  }) {
    if (line.isEmpty) {
      return;
    }

    final mainAvailable = rowLayout ? parentBounds.width : parentBounds.height;
    final mainStart = rowLayout ? parentBounds.x : parentBounds.y;
    final occupiedMain = line.fold<int>(0, (sum, child) {
      return sum +
          child.mainSize +
          child.margins.mainLeading(rowLayout) +
          child.margins.mainTrailing(rowLayout);
    });
    final remainingMain = (mainAvailable - occupiedMain)
        .clamp(0, mainAvailable)
        .toInt();
    final spacing = _resolveJustifySpacing(
      justify: justify,
      remaining: remainingMain,
      childCount: line.length,
    );

    var cursorMain = mainStart.toDouble() + spacing.leading;
    for (var i = 0; i < line.length; i++) {
      final child = line[i];
      final mainLeading = child.margins.mainLeading(rowLayout);
      final mainTrailing = child.margins.mainTrailing(rowLayout);
      final crossLeading = child.margins.crossLeading(rowLayout);
      final crossTrailing = child.margins.crossTrailing(rowLayout);
      final childCrossAvailable =
          (lineCrossExtent - crossLeading - crossTrailing)
              .clamp(0, lineCrossExtent)
              .toInt();
      final childCrossSize = _resolveFlowCrossSize(
        child: child.node,
        rowLayout: rowLayout,
        align: align,
        availableCross: childCrossAvailable,
      );
      final crossOffset = rowLayout
          ? (child.node.top ??
                _alignedOffset(align, childCrossAvailable, childCrossSize))
          : (child.node.left ??
                _alignedOffset(align, childCrossAvailable, childCrossSize));

      final x = rowLayout
          ? (cursorMain + mainLeading).round()
          : lineCrossStart + crossLeading + crossOffset;
      final y = rowLayout
          ? lineCrossStart + crossLeading + crossOffset
          : (cursorMain + mainLeading).round();
      final width = rowLayout ? child.mainSize : childCrossSize;
      final height = rowLayout ? childCrossSize : child.mainSize;
      final clamped = _clampRect(
        parent: parentBounds,
        x: x,
        y: y,
        width: width,
        height: height,
      );
      _layoutNode(child.node, clamped);

      cursorMain += mainLeading + child.mainSize + mainTrailing;
      if (i < line.length - 1) {
        cursorMain += spacing.gap;
      }
    }
  }

  int _resolveFlowCrossSize({
    required TuiNode child,
    required bool rowLayout,
    required TuiAlign align,
    required int availableCross,
  }) {
    final explicit = _resolveCrossAxisSize(child, rowLayout, availableCross);
    if (explicit != null) {
      return explicit;
    }
    if (align == TuiAlign.stretch) {
      final offset = rowLayout ? (child.top ?? 0) : (child.left ?? 0);
      final stretched = availableCross - offset;
      return _constrainCrossAxisSize(
        child,
        rowLayout,
        stretched < 0 ? 0 : stretched,
        availableCross,
      );
    }
    return _constrainCrossAxisSize(
      child,
      rowLayout,
      _defaultCrossAxisSize(child, rowLayout, availableCross),
      availableCross,
    );
  }

  int? _resolveMainAxisSize(TuiNode node, bool rowLayout, int available) {
    return rowLayout
        ? _resolveWidth(node, available)
        : _resolveHeight(node, available);
  }

  int? _resolveCrossAxisSize(TuiNode node, bool rowLayout, int available) {
    return rowLayout
        ? _resolveHeight(node, available)
        : _resolveWidth(node, available);
  }

  int _defaultCrossAxisSize(TuiNode node, bool rowLayout, int fallback) {
    return rowLayout
        ? _defaultNodeHeight(node)
        : _defaultNodeWidth(node, fallback);
  }

  int _constrainMainAxisSize(
    TuiNode node,
    bool rowLayout,
    int value,
    int available,
  ) {
    return rowLayout
        ? _constrainWidth(node, value, available)
        : _constrainHeight(node, value, available);
  }

  int _constrainCrossAxisSize(
    TuiNode node,
    bool rowLayout,
    int value,
    int available,
  ) {
    return rowLayout
        ? _constrainHeight(node, value, available)
        : _constrainWidth(node, value, available);
  }

  bool _isMainAxisFlexible(TuiNode node, bool rowLayout) {
    if (rowLayout) {
      return node.width == null && node.widthPercent == null;
    }
    return node.height == null && node.heightPercent == null;
  }

  int _minimumMainAxisSize(TuiNode node, bool rowLayout, int available) {
    final minSize = rowLayout ? node.minWidth : node.minHeight;
    if (minSize == null) {
      return 0;
    }
    return minSize.clamp(0, available).toInt();
  }

  int? _resolveWidth(TuiNode node, int availableWidth) {
    final fixed = node.width;
    if (fixed != null) {
      return _constrainWidth(node, fixed, availableWidth);
    }
    final percent = node.widthPercent;
    if (percent == null) {
      return null;
    }
    return _constrainWidth(
      node,
      _resolvePercent(percent, availableWidth),
      availableWidth,
    );
  }

  int? _resolveHeight(TuiNode node, int availableHeight) {
    final fixed = node.height;
    if (fixed != null) {
      return _constrainHeight(node, fixed, availableHeight);
    }
    final percent = node.heightPercent;
    if (percent == null) {
      return null;
    }
    return _constrainHeight(
      node,
      _resolvePercent(percent, availableHeight),
      availableHeight,
    );
  }

  int _resolvePercent(double percent, int total) {
    return ((total * percent) / 100).floor().clamp(0, total).toInt();
  }

  int _constrainWidth(TuiNode node, int value, int availableWidth) {
    return _constrainDimension(
      value: value,
      available: availableWidth,
      min: node.minWidth,
      max: node.maxWidth,
    );
  }

  int _constrainHeight(TuiNode node, int value, int availableHeight) {
    return _constrainDimension(
      value: value,
      available: availableHeight,
      min: node.minHeight,
      max: node.maxHeight,
    );
  }

  int _constrainDimension({
    required int value,
    required int available,
    int? min,
    int? max,
  }) {
    final clampedAvailable = available < 0 ? 0 : available;
    var minValue = min ?? 0;
    var maxValue = max ?? clampedAvailable;
    if (minValue < 0) {
      minValue = 0;
    }
    if (maxValue < 0) {
      maxValue = 0;
    }
    if (minValue > clampedAvailable) {
      minValue = clampedAvailable;
    }
    if (maxValue > clampedAvailable) {
      maxValue = clampedAvailable;
    }
    if (maxValue < minValue) {
      maxValue = minValue;
    }
    return value.clamp(minValue, maxValue).toInt();
  }

  ({double leading, double gap}) _resolveJustifySpacing({
    required TuiJustify justify,
    required int remaining,
    required int childCount,
  }) {
    if (childCount <= 0 || remaining <= 0) {
      return (leading: 0, gap: 0);
    }
    switch (justify) {
      case TuiJustify.start:
        return (leading: 0, gap: 0);
      case TuiJustify.center:
        return (leading: remaining / 2, gap: 0);
      case TuiJustify.end:
        return (leading: remaining.toDouble(), gap: 0);
      case TuiJustify.spaceBetween:
        if (childCount == 1) {
          return (leading: 0, gap: 0);
        }
        return (leading: 0, gap: remaining / (childCount - 1));
      case TuiJustify.spaceAround:
        final gap = remaining / childCount;
        return (leading: gap / 2, gap: gap);
      case TuiJustify.spaceEvenly:
        final gap = remaining / (childCount + 1);
        return (leading: gap, gap: gap);
    }
  }

  int _alignedOffset(TuiAlign align, int available, int childSize) {
    final clampedChild = childSize.clamp(0, available).toInt();
    switch (align) {
      case TuiAlign.start:
      case TuiAlign.stretch:
        return 0;
      case TuiAlign.center:
        return ((available - clampedChild) / 2).floor();
      case TuiAlign.end:
        return available - clampedChild;
    }
  }

  int _defaultNodeHeight(TuiNode node) {
    if (node is TuiText) {
      return node.text.split('\n').length.clamp(1, 1000000);
    }
    if (node is TuiTextarea) {
      return node.value.split('\n').length.clamp(1, 1000000);
    }
    if (node is TuiSelect) {
      return node.options.length;
    }
    if (node is TuiTabSelect) {
      return 1;
    }
    if (node is TuiAsciiFont) {
      return TuiAsciiFont.defaultGlyphHeight;
    }
    if (node is TuiFrameBufferNode) {
      return node.buffer.height;
    }
    if (node is TuiSlider) {
      return node.vertical ? 8 : 1;
    }
    if (node is TuiScrollbar) {
      return node.vertical ? 8 : 1;
    }
    return 1;
  }

  int _defaultNodeWidth(TuiNode node, int fallback) {
    if (fallback <= 0) {
      return 0;
    }
    if (node is TuiText) {
      final longestLine = node.text
          .split('\n')
          .fold<int>(0, (max, line) => line.length > max ? line.length : max);
      return longestLine.clamp(1, fallback);
    }
    if (node is TuiSelect) {
      final longest = node.options.fold<int>(
        0,
        (max, line) => line.length > max ? line.length : max,
      );
      return (longest + 2).clamp(1, fallback);
    }
    if (node is TuiTabSelect) {
      final joined = node.options.join(node.separator);
      return (joined.length + 2).clamp(1, fallback);
    }
    if (node is TuiFrameBufferNode) {
      return node.buffer.width.clamp(1, fallback);
    }
    if (node is TuiSlider) {
      return node.vertical ? 1 : 12;
    }
    if (node is TuiScrollbar) {
      return node.vertical ? 1 : 12;
    }
    return fallback;
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
      case TuiTextarea textarea:
        _paintTextarea(textarea, bounds, frame);
      case TuiInput input:
        _paintInput(input, bounds, frame);
      case TuiSelect select:
        _paintSelect(select, bounds, frame);
      case TuiTabSelect tabSelect:
        _paintTabSelect(tabSelect, bounds, frame);
      case TuiAsciiFont asciiFont:
        _paintAsciiFont(asciiFont, bounds, frame);
      case TuiFrameBufferNode frameBuffer:
        _paintFrameBuffer(frameBuffer, bounds, frame);
      case TuiSlider slider:
        _paintSlider(slider, bounds, frame);
      case TuiScrollbar scrollbar:
        _paintScrollbar(scrollbar, bounds, frame);
    }

    for (final child in _layoutChildren(node)) {
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

    if (!box.border || bounds.width < 2 || bounds.height < 2) {
      return;
    }

    final left = bounds.x;
    final right = bounds.x + bounds.width - 1;
    final top = bounds.y;
    final bottom = bounds.y + bounds.height - 1;

    for (var x = left + 1; x < right; x++) {
      frame.setCell(x, top, TuiCell(char: '-', style: box.borderStyle));
      frame.setCell(x, bottom, TuiCell(char: '-', style: box.borderStyle));
    }
    for (var y = top + 1; y < bottom; y++) {
      frame.setCell(left, y, TuiCell(char: '|', style: box.borderStyle));
      frame.setCell(right, y, TuiCell(char: '|', style: box.borderStyle));
    }

    frame.setCell(left, top, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(right, top, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(left, bottom, TuiCell(char: '+', style: box.borderStyle));
    frame.setCell(right, bottom, TuiCell(char: '+', style: box.borderStyle));

    final title = box.title;
    if (title != null && title.isNotEmpty && bounds.width > 4) {
      frame.drawText(
        left + 2,
        top,
        title,
        style: box.borderStyle,
        maxWidth: bounds.width - 4,
      );
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

  void _paintTextarea(TuiTextarea textarea, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      bounds.height,
      fill: TuiCell(char: ' ', style: textarea.style),
    );

    final hasValue = textarea.value.isNotEmpty;
    final content = hasValue ? textarea.value : textarea.placeholder;
    final baseStyle = hasValue
        ? (textarea.focused ? textarea.focusedStyle : textarea.style)
        : textarea.placeholderStyle;
    final lines = content.split('\n');
    final maxStartLine = lines.isEmpty ? 0 : lines.length - 1;
    var startLine = textarea.scrollTop.clamp(0, maxStartLine).toInt();
    if (hasValue && bounds.height > 0) {
      final cursorSource = textarea.value;
      final cursorOffset = textarea.cursorPosition
          .clamp(0, cursorSource.length)
          .toInt();
      final beforeCursor = cursorSource.substring(0, cursorOffset);
      final cursorLine = '\n'.allMatches(beforeCursor).length;
      final maxVisibleRow = bounds.height - 1;
      if (cursorLine < startLine) {
        startLine = cursorLine;
      } else if (cursorLine > startLine + maxVisibleRow) {
        startLine = cursorLine - maxVisibleRow;
      }
      startLine = startLine.clamp(0, maxStartLine).toInt();
    }
    textarea.scrollTop = startLine;
    final visibleLines = lines
        .skip(startLine)
        .take(bounds.height)
        .toList(growable: false);

    for (var row = 0; row < visibleLines.length; row++) {
      frame.drawText(
        bounds.x,
        bounds.y + row,
        visibleLines[row],
        style: baseStyle,
        maxWidth: bounds.width,
      );
    }

    if (!textarea.focused || bounds.width <= 0 || bounds.height <= 0) {
      return;
    }

    final cursorSource = hasValue ? textarea.value : textarea.placeholder;
    final cursorOffset = textarea.cursorPosition
        .clamp(0, cursorSource.length)
        .toInt();
    final beforeCursor = cursorSource.substring(0, cursorOffset);
    final absoluteLine = '\n'.allMatches(beforeCursor).length;
    final lineStart = beforeCursor.lastIndexOf('\n') + 1;
    final lineColumn = cursorOffset - lineStart;
    final visibleRow = absoluteLine - startLine;
    if (visibleRow < 0 || visibleRow >= bounds.height) {
      return;
    }
    final cursorX = bounds.x + lineColumn.clamp(0, bounds.width - 1);
    final lineText = absoluteLine < lines.length ? lines[absoluteLine] : '';
    final cursorChar = lineColumn < lineText.length
        ? lineText[lineColumn]
        : ' ';
    frame.setCell(
      cursorX,
      bounds.y + visibleRow,
      TuiCell(
        char: cursorChar,
        style: baseStyle.copyWith(inverse: !baseStyle.inverse),
      ),
    );
  }

  void _paintSlider(TuiSlider slider, TuiRect bounds, TuiFrame frame) {
    final range = (slider.max - slider.min).abs();
    final normalized = range <= 0 ? 0.0 : (slider.value - slider.min) / range;
    final clampedValue = normalized.clamp(0.0, 1.0);

    if (slider.vertical) {
      final length = bounds.height;
      if (length <= 0) {
        return;
      }
      final thumbOffset = (clampedValue * (length - 1)).round();
      for (var y = 0; y < length; y++) {
        final isThumb = y == (length - 1 - thumbOffset);
        frame.setCell(
          bounds.x,
          bounds.y + y,
          TuiCell(
            char: isThumb ? 'O' : '|',
            style: isThumb ? slider.thumbStyle : slider.trackStyle,
          ),
        );
      }
      return;
    }

    final length = bounds.width;
    if (length <= 0) {
      return;
    }
    final thumbOffset = (clampedValue * (length - 1)).round();
    for (var x = 0; x < length; x++) {
      final isThumb = x == thumbOffset;
      frame.setCell(
        bounds.x + x,
        bounds.y,
        TuiCell(
          char: isThumb ? 'O' : '-',
          style: isThumb ? slider.thumbStyle : slider.trackStyle,
        ),
      );
    }
  }

  void _paintScrollbar(TuiScrollbar scrollbar, TuiRect bounds, TuiFrame frame) {
    if (scrollbar.vertical) {
      final length = bounds.height;
      if (length <= 0) {
        return;
      }
      final thumbSize = (length * scrollbar.thumbRatio)
          .round()
          .clamp(1, length)
          .toInt();
      final thumbStart =
          ((length - thumbSize) * scrollbar.value.clamp(0.0, 1.0)).round();
      for (var y = 0; y < length; y++) {
        final isThumb = y >= thumbStart && y < thumbStart + thumbSize;
        frame.setCell(
          bounds.x,
          bounds.y + y,
          TuiCell(
            char: isThumb ? '#' : '|',
            style: isThumb ? scrollbar.thumbStyle : scrollbar.trackStyle,
          ),
        );
      }
      return;
    }

    final length = bounds.width;
    if (length <= 0) {
      return;
    }
    final thumbSize = (length * scrollbar.thumbRatio)
        .round()
        .clamp(1, length)
        .toInt();
    final thumbStart = ((length - thumbSize) * scrollbar.value.clamp(0.0, 1.0))
        .round();
    for (var x = 0; x < length; x++) {
      final isThumb = x >= thumbStart && x < thumbStart + thumbSize;
      frame.setCell(
        bounds.x + x,
        bounds.y,
        TuiCell(
          char: isThumb ? '#' : '-',
          style: isThumb ? scrollbar.thumbStyle : scrollbar.trackStyle,
        ),
      );
    }
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

  void _paintTabSelect(TuiTabSelect tabSelect, TuiRect bounds, TuiFrame frame) {
    frame.fillRect(
      bounds.x,
      bounds.y,
      bounds.width,
      1,
      fill: TuiCell(char: ' ', style: tabSelect.style),
    );

    var cursorX = bounds.x;
    final endX = bounds.x + bounds.width;
    for (var i = 0; i < tabSelect.options.length; i++) {
      if (cursorX >= endX) {
        break;
      }
      if (i > 0 && tabSelect.separator.isNotEmpty) {
        final separatorSpace = endX - cursorX;
        if (separatorSpace <= 0) {
          break;
        }
        frame.drawText(
          cursorX,
          bounds.y,
          tabSelect.separator,
          style: tabSelect.style,
          maxWidth: separatorSpace,
        );
        cursorX += tabSelect.separator.length;
      }

      if (cursorX >= endX) {
        break;
      }
      final label = ' ${tabSelect.options[i]} ';
      final style = i == tabSelect.selectedIndex
          ? tabSelect.selectedStyle
          : tabSelect.style;
      final labelSpace = endX - cursorX;
      if (labelSpace <= 0) {
        break;
      }
      frame.drawText(
        cursorX,
        bounds.y,
        label,
        style: style,
        maxWidth: labelSpace,
      );
      cursorX += label.length;
    }
  }

  void _paintAsciiFont(TuiAsciiFont asciiFont, TuiRect bounds, TuiFrame frame) {
    final lines = _asciiFontLines(asciiFont);
    final visibleRows = lines.length < bounds.height
        ? lines.length
        : bounds.height;

    for (var i = 0; i < visibleRows; i++) {
      frame.drawText(
        bounds.x,
        bounds.y + i,
        lines[i],
        style: asciiFont.style,
        maxWidth: bounds.width,
      );
    }
  }

  void _paintFrameBuffer(
    TuiFrameBufferNode frameBuffer,
    TuiRect bounds,
    TuiFrame frame,
  ) {
    final visibleWidth = bounds.width < frameBuffer.buffer.width
        ? bounds.width
        : frameBuffer.buffer.width;
    final visibleHeight = bounds.height < frameBuffer.buffer.height
        ? bounds.height
        : frameBuffer.buffer.height;

    for (var y = 0; y < visibleHeight; y++) {
      for (var x = 0; x < visibleWidth; x++) {
        final cell = frameBuffer.buffer.cellAt(x, y);
        if (frameBuffer.transparent && cell.char == ' ') {
          continue;
        }
        frame.setCell(bounds.x + x, bounds.y + y, cell);
      }
    }
  }

  List<String> _asciiFontLines(TuiAsciiFont asciiFont) {
    final runes = asciiFont.text.runes.toList(growable: false);
    final glyphHeight = TuiAsciiFont.defaultGlyphHeight;
    final lineBuffers = List<StringBuffer>.generate(
      glyphHeight,
      (_) => StringBuffer(),
      growable: false,
    );

    for (var index = 0; index < runes.length; index++) {
      final char = String.fromCharCode(runes[index]).toUpperCase();
      final glyph = _asciiGlyphs[char] ?? _fallbackGlyph(char);

      for (var row = 0; row < glyphHeight; row++) {
        if (index > 0 && asciiFont.letterSpacing > 0) {
          lineBuffers[row].write(''.padLeft(asciiFont.letterSpacing));
        }
        lineBuffers[row].write(glyph[row]);
      }
    }

    return lineBuffers.map((line) => line.toString()).toList(growable: false);
  }

  List<String> _fallbackGlyph(String char) {
    if (char.trim().isEmpty) {
      return const <String>['   ', '   ', '   ', '   ', '   '];
    }
    final rune = char.runes.isEmpty
        ? '?'
        : String.fromCharCode(char.runes.first);
    return <String>[
      ' $rune ',
      '$rune $rune',
      '$rune$rune$rune',
      '$rune $rune',
      '$rune $rune',
    ];
  }

  static const Map<String, List<String>> _asciiGlyphs = <String, List<String>>{
    'A': <String>[' /\\ ', '/__\\', '|  |', '|  |', '    '],
    'B': <String>['|~~\\', '|__/ ', '|~~\\', '|__/ ', '    '],
    'C': <String>[' /~~', '|   ', '|   ', ' \\__', '    '],
    'D': <String>['|~~\\', '|  |', '|  |', '|__/', '    '],
    'E': <String>['|~~~', '|__ ', '|   ', '|___', '    '],
    'F': <String>['|~~~', '|__ ', '|   ', '|   ', '    '],
    'G': <String>[' /~~', '| __', '|  |', ' \\_|', '    '],
    'H': <String>['|  |', '|__|', '|  |', '|  |', '    '],
    'I': <String>['-|-', ' | ', ' | ', '-|-', '   '],
    'J': <String>['  |', '  |', '| |', ' \\|', '   '],
    'K': <String>['| /', '|/ ', '|\\ ', '| \\', '   '],
    'L': <String>['|   ', '|   ', '|   ', '|___', '    '],
    'M': <String>['|\\/|', '|  |', '|  |', '|  |', '    '],
    'N': <String>['|\\ |', '| \\|', '|  |', '|  |', '    '],
    'O': <String>[' /\\ ', '|  |', '|  |', ' \\/ ', '    '],
    'P': <String>['|~~\\', '|__/', '|   ', '|   ', '    '],
    'Q': <String>[' /\\ ', '|  |', '| \\\\', ' \\/\\', '    '],
    'R': <String>['|~~\\', '|__/', '| \\ ', '|  \\', '    '],
    'S': <String>[' /~~', '(__ ', ' __)', '~~/ ', '    '],
    'T': <String>['~~~', ' | ', ' | ', ' | ', '   '],
    'U': <String>['|  |', '|  |', '|  |', ' \\/ ', '    '],
    'V': <String>['|  |', '|  |', ' \\/ ', '  V ', '    '],
    'W': <String>['|  |', '|  |', '|/\\|', '|  |', '    '],
    'X': <String>['\\ /', ' X ', '/ \\', '   ', '   '],
    'Y': <String>['\\ /', ' Y ', ' | ', ' | ', '   '],
    'Z': <String>['~~~/', '  / ', ' /  ', '/___', '    '],
    '0': <String>[' /\\ ', '/  \\', '|  |', ' \\_/ ', '    '],
    '1': <String>[' /|', '  |', '  |', '__|', '   '],
    '2': <String>['__/ ', '  / ', ' /  ', '/__ ', '    '],
    '3': <String>['__\\ ', ' _/ ', '  \\ ', '__/ ', '    '],
    '4': <String>['|  |', '|__|', '   |', '   |', '    '],
    '5': <String>['|__ ', '|__ ', '   |', '__/ ', '    '],
    '6': <String>[' /~ ', '|__ ', '|  |', ' \\_/ ', '    '],
    '7': <String>['___/', '  / ', ' /  ', '/   ', '    '],
    '8': <String>[' /\\ ', ' > <', '|  |', ' \\/ ', '    '],
    '9': <String>[' /\\ ', '|  |', ' \\_|', '  / ', '    '],
    ' ': <String>['   ', '   ', '   ', '   ', '   '],
  };

  void _assertNotDisposed() {
    if (_isDisposed) {
      throw StateError('TuiEngine is disposed.');
    }
  }
}

final class _NodeMargins {
  const _NodeMargins({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final int left;
  final int top;
  final int right;
  final int bottom;

  int mainLeading(bool rowLayout) => rowLayout ? left : top;

  int mainTrailing(bool rowLayout) => rowLayout ? right : bottom;

  int crossLeading(bool rowLayout) => rowLayout ? top : left;

  int crossTrailing(bool rowLayout) => rowLayout ? bottom : right;
}

final class _FlowChild {
  _FlowChild({
    required this.node,
    required this.margins,
    required this.mainAvailable,
    required this.explicitMainSize,
    required this.minimumMainSize,
    required this.flexible,
  });

  final TuiNode node;
  final _NodeMargins margins;
  final int mainAvailable;
  final int? explicitMainSize;
  final int minimumMainSize;
  final bool flexible;
  int mainSize = 0;
}
