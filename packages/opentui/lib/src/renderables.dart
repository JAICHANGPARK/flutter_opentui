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

abstract class Renderable extends BaseRenderable {
  Renderable({
    super.id,
    this.width,
    this.height,
    this.left,
    this.top,
    this.zIndex = 0,
    this.flexGrow = 1.0,
  });

  int? width;
  int? height;
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
    super.left,
    super.top,
    super.flexGrow,
    this.layoutDirection = TuiLayoutDirection.column,
    this.border = false,
    this.title,
    this.padding = 0,
    this.style = TuiStyle.plain,
    this.borderStyle = const TuiStyle(foreground: TuiColor.cyan),
  });

  TuiLayoutDirection layoutDirection;
  bool border;
  String? title;
  int padding;
  TuiStyle style;
  TuiStyle borderStyle;

  @override
  TuiNode toNode() {
    final node = TuiBox(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      flexGrow: flexGrow,
      layoutDirection: layoutDirection,
      border: border,
      title: title,
      padding: padding,
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
    super.left,
    super.top,
    super.flexGrow,
    super.layoutDirection,
    super.style,
  }) : super(border: false, padding: 0, title: null);
}

class TextRenderable extends Renderable {
  TextRenderable({
    super.id,
    super.width,
    super.height,
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

class SelectRenderable extends Renderable {
  SelectRenderable({
    super.id,
    super.width,
    super.height,
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
      left: left,
      top: top,
      flexGrow: flexGrow,
      text: content,
      style: style,
      letterSpacing: letterSpacing,
    );
  }
}

final class FrameBufferRenderable extends Renderable {
  FrameBufferRenderable({
    super.id,
    super.width,
    super.height,
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
      left: left,
      top: top,
      flexGrow: flexGrow,
      buffer: buffer,
      transparent: transparent,
    );
  }
}
