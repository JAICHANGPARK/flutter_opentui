import 'package:opentui/opentui.dart';

/// ScrollBox-style renderable adapter for Flutter/OpenTUI integration.
///
/// It clips children by [scrollOffset] and optional [maxVisibleChildren] when
/// building a `TuiBox` node.
final class OpenTuiScrollBoxRenderable extends BoxRenderable {
  OpenTuiScrollBoxRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    super.flexGrow,
    super.layoutDirection,
    super.border,
    super.title,
    super.padding,
    super.style,
    super.borderStyle,
    this.scrollOffset = 0,
    this.maxVisibleChildren,
  }) : assert(scrollOffset >= 0),
       assert(maxVisibleChildren == null || maxVisibleChildren >= 0);

  int scrollOffset;
  int? maxVisibleChildren;

  @override
  TuiNode toNode() {
    final node = super.toNode() as TuiBox;
    final children = List<TuiNode>.from(node.children, growable: false);
    final safeOffset = scrollOffset.clamp(0, children.length);
    final visibleChildren = children.skip(safeOffset);

    node.children
      ..clear()
      ..addAll(visibleChildren);

    final visibleLimit = maxVisibleChildren;
    if (visibleLimit != null && node.children.length > visibleLimit) {
      node.children.removeRange(visibleLimit, node.children.length);
    }

    return node;
  }
}
