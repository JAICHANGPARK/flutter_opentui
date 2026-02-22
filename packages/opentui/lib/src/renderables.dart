import 'package:meta/meta.dart';

import 'buffer.dart';
import 'frame.dart';
import 'node.dart';

abstract class BaseRenderable {
  BaseRenderable({String? id}) : _id = id;

  static int _idCounter = 1;

  String? _id;
  bool _dirty = true;
  bool _visible = true;
  BaseRenderable? parent;
  final List<BaseRenderable> _children = <BaseRenderable>[];

  String get id => _id ??= 'renderable-${_idCounter++}';

  set id(String value) {
    _id = value;
    markDirty();
  }

  bool get isDirty => _dirty;

  bool get visible => _visible;

  set visible(bool value) {
    if (_visible == value) {
      return;
    }
    _visible = value;
    markDirty();
  }

  List<BaseRenderable> getChildren() {
    return List<BaseRenderable>.from(_children, growable: false);
  }

  int getChildrenCount() => _children.length;

  int add(BaseRenderable child, {int? index}) {
    child.parent = this;
    if (index == null || index < 0 || index >= _children.length) {
      _children.add(child);
      markDirty();
      return _children.length - 1;
    }
    _children.insert(index, child);
    markDirty();
    return index;
  }

  bool remove(BaseRenderable child) {
    final removed = _children.remove(child);
    if (removed) {
      child.parent = null;
      markDirty();
    }
    return removed;
  }

  void removeById(String id) {
    final index = _children.indexWhere((child) => child.id == id);
    if (index < 0) {
      return;
    }
    final child = _children.removeAt(index);
    child.parent = null;
    markDirty();
  }

  BaseRenderable? findDescendantById(String id) {
    for (final child in _children) {
      if (child.id == id) {
        return child;
      }
      final nested = child.findDescendantById(id);
      if (nested != null) {
        return nested;
      }
    }
    return null;
  }

  void clearChildren() {
    for (final child in _children) {
      child.parent = null;
    }
    _children.clear();
    markDirty();
  }

  void markClean() {
    _dirty = false;
  }

  void markDirty() {
    _dirty = true;
    parent?.markDirty();
  }

  TuiNode toNode();

  @protected
  void attachChildren(TuiNode target) {
    for (final child in _children) {
      if (!child.visible) {
        continue;
      }
      target.add(child.toNode());
    }
  }
}

/// A renderable wrapper that routes selected APIs to named descendants.
///
/// This is a Dart-friendly adaptation of the core `delegate(...)` model.
/// When a delegated API is called and the target cannot be found, operations
/// fall back to the wrapped `root`.
final class DelegatedRenderable<T extends BaseRenderable>
    extends BaseRenderable {
  DelegatedRenderable({
    required this.root,
    required Map<String, String> delegates,
    super.id,
  }) : _delegates = Map<String, String>.unmodifiable(delegates) {
    root.parent = this;
  }

  final T root;
  final Map<String, String> _delegates;

  Map<String, String> get delegates => _delegates;

  BaseRenderable? delegatedTarget(String api) {
    final targetId = _delegates[api];
    if (targetId == null) {
      return null;
    }
    if (targetId == root.id) {
      return root;
    }
    return root.findDescendantById(targetId);
  }

  /// Invokes [action] on a delegated target for [api], or [root] as fallback.
  R delegatedCall<R>(String api, R Function(BaseRenderable target) action) {
    final target = delegatedTarget(api) ?? root;
    return action(target);
  }

  BaseRenderable _targetFor(String api) {
    return delegatedTarget(api) ?? root;
  }

  @override
  List<BaseRenderable> getChildren() => root.getChildren();

  @override
  int getChildrenCount() => root.getChildrenCount();

  @override
  int add(BaseRenderable child, {int? index}) {
    return _targetFor('add').add(child, index: index);
  }

  @override
  bool remove(BaseRenderable child) {
    return _targetFor('remove').remove(child);
  }

  @override
  void removeById(String id) {
    _targetFor('removeById').removeById(id);
  }

  @override
  BaseRenderable? findDescendantById(String id) {
    if (root.id == id) {
      return root;
    }
    return root.findDescendantById(id);
  }

  @override
  void clearChildren() {
    _targetFor('clearChildren').clearChildren();
  }

  @override
  TuiNode toNode() => root.toNode();
}

abstract class Renderable extends BaseRenderable {
  Renderable({
    super.id,
    this.width,
    this.height,
    this.widthPercent,
    this.heightPercent,
    this.minWidth,
    this.maxWidth,
    this.minHeight,
    this.maxHeight,
    this.margin = 0,
    this.marginX,
    this.marginY,
    this.marginLeft,
    this.marginTop,
    this.marginRight,
    this.marginBottom,
    this.left,
    this.top,
    this.zIndex = 0,
    this.flexGrow = 1.0,
  }) : assert(flexGrow >= 0),
       assert(
         widthPercent == null || (widthPercent >= 0 && widthPercent <= 100),
       ),
       assert(
         heightPercent == null || (heightPercent >= 0 && heightPercent <= 100),
       ),
       assert(minWidth == null || minWidth >= 0),
       assert(maxWidth == null || maxWidth >= 0),
       assert(minHeight == null || minHeight >= 0),
       assert(maxHeight == null || maxHeight >= 0),
       assert(maxWidth == null || minWidth == null || maxWidth >= minWidth),
       assert(maxHeight == null || minHeight == null || maxHeight >= minHeight),
       assert(margin >= 0),
       assert(marginX == null || marginX >= 0),
       assert(marginY == null || marginY >= 0),
       assert(marginLeft == null || marginLeft >= 0),
       assert(marginTop == null || marginTop >= 0),
       assert(marginRight == null || marginRight >= 0),
       assert(marginBottom == null || marginBottom >= 0);

  int? width;
  int? height;
  double? widthPercent;
  double? heightPercent;
  int? minWidth;
  int? maxWidth;
  int? minHeight;
  int? maxHeight;
  int margin;
  int? marginX;
  int? marginY;
  int? marginLeft;
  int? marginTop;
  int? marginRight;
  int? marginBottom;
  int? left;
  int? top;
  int zIndex;
  double flexGrow;
}

class BoxRenderable extends Renderable {
  BoxRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    this.layoutDirection = TuiLayoutDirection.column,
    this.wrap = TuiWrap.noWrap,
    this.justify = TuiJustify.start,
    this.align = TuiAlign.stretch,
    this.border = false,
    this.title,
    this.padding = 0,
    this.paddingX,
    this.paddingY,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.style = TuiStyle.plain,
    this.borderStyle = const TuiStyle(foreground: TuiColor.cyan),
  }) : assert(padding >= 0),
       assert(paddingX == null || paddingX >= 0),
       assert(paddingY == null || paddingY >= 0),
       assert(paddingLeft == null || paddingLeft >= 0),
       assert(paddingTop == null || paddingTop >= 0),
       assert(paddingRight == null || paddingRight >= 0),
       assert(paddingBottom == null || paddingBottom >= 0);

  TuiLayoutDirection layoutDirection;
  TuiWrap wrap;
  TuiJustify justify;
  TuiAlign align;
  bool border;
  String? title;
  int padding;
  int? paddingX;
  int? paddingY;
  int? paddingLeft;
  int? paddingTop;
  int? paddingRight;
  int? paddingBottom;
  TuiStyle style;
  TuiStyle borderStyle;

  @override
  TuiNode toNode() {
    final node = TuiBox(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      layoutDirection: layoutDirection,
      wrap: wrap,
      justify: justify,
      align: align,
      border: border,
      title: title,
      padding: padding,
      paddingX: paddingX,
      paddingY: paddingY,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      paddingRight: paddingRight,
      paddingBottom: paddingBottom,
      style: style,
      borderStyle: borderStyle,
    );
    attachChildren(node);
    return node;
  }
}

class GroupRenderable extends BoxRenderable {
  GroupRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    super.layoutDirection,
    super.wrap,
    super.justify,
    super.align,
    super.style,
  }) : super(border: false, padding: 0, title: null);
}

class TextRenderable extends Renderable {
  TextRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.content,
    this.style = TuiStyle.plain,
  });

  String content;
  TuiStyle style;

  @override
  TuiNode toNode() {
    return TuiText(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      text: content,
      style: style,
    );
  }
}

class InputRenderable extends Renderable {
  InputRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    this.value = '',
    this.placeholder = '',
    this.style = TuiStyle.plain,
    this.focusedStyle = const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.white,
    ),
    this.placeholderStyle = const TuiStyle(foreground: TuiColor.cyan),
  });

  String value;
  String placeholder;
  TuiStyle style;
  TuiStyle focusedStyle;
  TuiStyle placeholderStyle;

  @override
  TuiNode toNode() {
    return TuiInput(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      value: value,
      placeholder: placeholder,
      style: style,
      focusedStyle: focusedStyle,
      placeholderStyle: placeholderStyle,
    );
  }
}

class TextareaRenderable extends InputRenderable {
  TextareaRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    super.value,
    super.placeholder,
    super.style,
    super.focusedStyle,
    super.placeholderStyle,
    this.scrollTop = 0,
  });

  int scrollTop;

  @override
  TuiNode toNode() {
    return TuiTextarea(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      value: value,
      placeholder: placeholder,
      style: style,
      focusedStyle: focusedStyle,
      placeholderStyle: placeholderStyle,
      scrollTop: scrollTop,
    );
  }
}

class SelectRenderable extends Renderable {
  SelectRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.options,
    this.selectedIndex = 0,
    this.style = TuiStyle.plain,
    this.selectedStyle = const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.green,
      bold: true,
    ),
  });

  List<String> options;
  int selectedIndex;
  TuiStyle style;
  TuiStyle selectedStyle;

  @override
  TuiNode toNode() {
    return TuiSelect(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      options: options,
      selectedIndex: selectedIndex,
      style: style,
      selectedStyle: selectedStyle,
    );
  }
}

final class TabSelectRenderable extends SelectRenderable {
  TabSelectRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required super.options,
    super.selectedIndex,
    super.style,
    super.selectedStyle,
    this.separator = ' | ',
  });

  String separator;

  @override
  TuiNode toNode() {
    return TuiTabSelect(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      options: options,
      selectedIndex: selectedIndex,
      style: style,
      selectedStyle: selectedStyle,
      separator: separator,
    );
  }
}

final class ASCIIFontRenderable extends TextRenderable {
  ASCIIFontRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required super.content,
    super.style,
    this.letterSpacing = 1,
  });

  int letterSpacing;

  @override
  TuiNode toNode() {
    return TuiAsciiFont(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      text: content,
      style: style,
      letterSpacing: letterSpacing,
    );
  }
}

class MarkdownRenderable extends Renderable {
  MarkdownRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.markdown,
    this.style = TuiStyle.plain,
  });

  String markdown;
  TuiStyle style;

  @override
  TuiNode toNode() {
    return TuiMarkdown(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      markdown: markdown,
      style: style,
    );
  }
}

class CodeRenderable extends Renderable {
  CodeRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.code,
    this.style = TuiStyle.plain,
  });

  String code;
  TuiStyle style;

  @override
  TuiNode toNode() {
    return TuiCode(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      code: code,
      style: style,
    );
  }
}

class DiffRenderable extends Renderable {
  DiffRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.previous,
    required this.next,
    this.style = TuiStyle.plain,
  });

  String previous;
  String next;
  TuiStyle style;

  @override
  TuiNode toNode() {
    return TuiDiff(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      previous: previous,
      next: next,
      style: style,
    );
  }
}

class LineNumberRenderable extends Renderable {
  LineNumberRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.lines,
    this.style = TuiStyle.plain,
  });

  List<String> lines;
  TuiStyle style;

  @override
  TuiNode toNode() {
    return TuiLineNumber(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      lines: lines,
      style: style,
    );
  }
}

class ScrollBoxRenderable extends BoxRenderable {
  ScrollBoxRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    super.layoutDirection,
    super.wrap,
    super.justify,
    super.align,
    super.border,
    super.title,
    super.padding,
    super.paddingX,
    super.paddingY,
    super.paddingLeft,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.style,
    super.borderStyle,
    this.scrollOffset = 0,
    this.scrollStep = 1,
    this.fastScrollStep = 5,
  });

  int scrollOffset;
  int scrollStep;
  int fastScrollStep;

  @override
  TuiNode toNode() {
    final node = TuiScrollBox(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      layoutDirection: layoutDirection,
      wrap: wrap,
      justify: justify,
      align: align,
      border: border,
      title: title,
      padding: padding,
      paddingX: paddingX,
      paddingY: paddingY,
      paddingLeft: paddingLeft,
      paddingTop: paddingTop,
      paddingRight: paddingRight,
      paddingBottom: paddingBottom,
      style: style,
      borderStyle: borderStyle,
      scrollOffset: scrollOffset,
      scrollStep: scrollStep,
      fastScrollStep: fastScrollStep,
    );
    attachChildren(node);
    return node;
  }
}

class ScrollbarRenderable extends Renderable {
  ScrollbarRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    this.value = 0,
    this.thumbRatio = 0.2,
    this.step = 0.05,
    this.fastStep = 0.2,
    this.vertical = true,
    this.trackStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.thumbStyle = const TuiStyle(foreground: TuiColor.white, bold: true),
  });

  double value;
  double thumbRatio;
  double step;
  double fastStep;
  bool vertical;
  TuiStyle trackStyle;
  TuiStyle thumbStyle;

  @override
  TuiNode toNode() {
    return TuiScrollbar(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      value: value,
      thumbRatio: thumbRatio,
      step: step,
      fastStep: fastStep,
      vertical: vertical,
      trackStyle: trackStyle,
      thumbStyle: thumbStyle,
    );
  }
}

class SliderRenderable extends Renderable {
  SliderRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    this.min = 0,
    this.max = 100,
    this.value = 0,
    this.step = 1,
    this.vertical = false,
    this.trackStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.thumbStyle = const TuiStyle(foreground: TuiColor.white, bold: true),
  });

  double min;
  double max;
  double value;
  double step;
  bool vertical;
  TuiStyle trackStyle;
  TuiStyle thumbStyle;

  @override
  TuiNode toNode() {
    return TuiSlider(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      min: min,
      max: max,
      value: value,
      step: step,
      vertical: vertical,
      trackStyle: trackStyle,
      thumbStyle: thumbStyle,
    );
  }
}

typedef ScrollBarRenderable = ScrollbarRenderable;

final class FrameBufferRenderable extends Renderable {
  FrameBufferRenderable({
    super.id,
    super.width,
    super.height,
    super.widthPercent,
    super.heightPercent,
    super.minWidth,
    super.maxWidth,
    super.minHeight,
    super.maxHeight,
    super.margin,
    super.marginX,
    super.marginY,
    super.marginLeft,
    super.marginTop,
    super.marginRight,
    super.marginBottom,
    super.left,
    super.top,
    super.flexGrow,
    required this.buffer,
    this.transparent = false,
  });

  OptimizedBuffer buffer;
  bool transparent;

  @override
  TuiNode toNode() {
    return TuiFrameBufferNode(
      id: id,
      width: width,
      height: height,
      widthPercent: widthPercent,
      heightPercent: heightPercent,
      minWidth: minWidth,
      maxWidth: maxWidth,
      minHeight: minHeight,
      maxHeight: maxHeight,
      margin: margin,
      marginX: marginX,
      marginY: marginY,
      marginLeft: marginLeft,
      marginTop: marginTop,
      marginRight: marginRight,
      marginBottom: marginBottom,
      left: left,
      top: top,
      flexGrow: flexGrow,
      buffer: buffer,
      transparent: transparent,
    );
  }
}
