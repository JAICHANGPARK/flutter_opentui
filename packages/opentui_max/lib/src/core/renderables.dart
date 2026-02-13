import 'buffer.dart';
import 'edit_buffer.dart';
import 'editor_view.dart';
import 'frame.dart';
import 'node.dart';
import 'types.dart';
import 'package:meta/meta.dart';

abstract class BaseRenderable {
  BaseRenderable({String? id}) : _id = id;

  static int _idCounter = 1;

  String? _id;
  bool _dirty = true;
  bool _visible = true;
  BaseRenderable? parent;
  final List<BaseRenderable> _children = <BaseRenderable>[];

  String get id {
    return _id ??= 'renderable-${_idCounter++}';
  }

  set id(String value) {
    _id = value;
  }

  bool get isDirty => _dirty;

  bool get visible => _visible;

  set visible(bool value) {
    _visible = value;
    markDirty();
  }

  int add(BaseRenderable obj, {int? index}) {
    obj.parent = this;
    if (index == null || index < 0 || index >= _children.length) {
      _children.add(obj);
      markDirty();
      return _children.length - 1;
    }
    _children.insert(index, obj);
    markDirty();
    return index;
  }

  void remove(String id) {
    _children.removeWhere((child) => child.id == id);
    markDirty();
  }

  void insertBefore(BaseRenderable obj, BaseRenderable anchor) {
    final index = _children.indexWhere((child) => child.id == anchor.id);
    if (index < 0) {
      add(obj);
      return;
    }
    add(obj, index: index);
  }

  List<BaseRenderable> getChildren() => List<BaseRenderable>.from(_children);

  int getChildrenCount() => _children.length;

  BaseRenderable? getRenderable(String id) {
    for (final child in _children) {
      if (child.id == id) {
        return child;
      }
    }
    return null;
  }

  BaseRenderable? findDescendantById(String id) {
    for (final child in _children) {
      if (child.id == id) {
        return child;
      }
      final deep = child.findDescendantById(id);
      if (deep != null) {
        return deep;
      }
    }
    return null;
  }

  void requestRender() {
    markDirty();
  }

  void markClean() {
    _dirty = false;
  }

  void markDirty() {
    _dirty = true;
  }

  TuiNode toNode();

  void destroy() {
    for (final child in _children) {
      child.destroy();
    }
    _children.clear();
  }

  @protected
  void attachChildren(TuiNode target) {
    for (final child in _children) {
      final node = child.toNode();
      target.add(node);
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
  });

  int? width;
  int? height;
  int? left;
  int? top;
  int zIndex;
}

final class BoxRenderable extends Renderable {
  BoxRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
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

final class TextRenderable extends Renderable {
  TextRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
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
      text: content,
      style: style,
    );
  }
}

final class InputRenderable extends Renderable {
  InputRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    this.value = '',
    this.placeholder = '',
  });

  String value;
  String placeholder;

  @override
  TuiNode toNode() {
    return TuiInput(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      value: value,
      placeholder: placeholder,
    );
  }
}

final class SelectRenderable extends Renderable {
  SelectRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required this.options,
    this.selectedIndex = 0,
  });

  List<String> options;
  int selectedIndex;

  @override
  TuiNode toNode() {
    return TuiSelect(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      options: options,
      selectedIndex: selectedIndex,
    );
  }
}

final class ScrollBoxRenderable extends BoxRenderable {
  ScrollBoxRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    super.layoutDirection,
    super.border,
    super.title,
    super.padding,
    super.style,
    super.borderStyle,
    this.scrollOffset = 0,
  });

  int scrollOffset;

  @override
  TuiNode toNode() {
    final node = super.toNode() as TuiBox;
    final content = node.children.toList(growable: false);
    node.children
      ..clear()
      ..addAll(content.skip(scrollOffset.clamp(0, content.length)));
    return node;
  }
}

final class TabSelectRenderable extends SelectRenderable {
  TabSelectRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required super.options,
    super.selectedIndex,
  });
}

final class DiffRenderable extends TextRenderable {
  DiffRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required String previous,
    required String next,
  }) : super(content: _buildDiff(previous, next));

  static String _buildDiff(String previous, String next) {
    final oldLines = previous.split('\n');
    final newLines = next.split('\n');
    final max = oldLines.length > newLines.length
        ? oldLines.length
        : newLines.length;
    final lines = <String>[];
    for (var i = 0; i < max; i++) {
      final oldLine = i < oldLines.length ? oldLines[i] : null;
      final newLine = i < newLines.length ? newLines[i] : null;
      if (oldLine == newLine && newLine != null) {
        lines.add('  $newLine');
      } else {
        if (oldLine != null) {
          lines.add('- $oldLine');
        }
        if (newLine != null) {
          lines.add('+ $newLine');
        }
      }
    }
    return lines.join('\n');
  }
}

final class MarkdownRenderable extends TextRenderable {
  MarkdownRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required String markdown,
  }) : super(content: markdown.replaceAll(RegExp(r'[*_`#]'), ''));
}

final class CodeRenderable extends TextRenderable {
  CodeRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required String code,
  }) : super(content: code);
}

final class ASCIIFontRenderable extends TextRenderable {
  ASCIIFontRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required String text,
  }) : super(content: text.toUpperCase());
}

final class LineNumberRenderable extends TextRenderable {
  LineNumberRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required List<String> lines,
  }) : super(content: _withLineNumbers(lines));

  static String _withLineNumbers(List<String> lines) {
    final buffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      buffer.writeln('${(i + 1).toString().padLeft(4)} ${lines[i]}');
    }
    return buffer.toString();
  }
}

final class TextareaRenderable extends Renderable {
  TextareaRenderable._({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required this.editBuffer,
    required this.editorView,
  });

  factory TextareaRenderable({
    String? id,
    int? width,
    int? height,
    int? left,
    int? top,
    EditBuffer? buffer,
    EditorView? view,
  }) {
    final resolvedBuffer =
        buffer ?? EditBuffer.create(WidthMethod.unicodeScalar);
    final resolvedView = view ?? EditorView.create(resolvedBuffer, 80, 24);
    return TextareaRenderable._(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      editBuffer: resolvedBuffer,
      editorView: resolvedView,
    );
  }

  final EditBuffer editBuffer;
  final EditorView editorView;

  @override
  TuiNode toNode() {
    return TuiText(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      text: editBuffer.getText(),
    );
  }

  @override
  void destroy() {
    editorView.destroy();
    editBuffer.destroy();
    super.destroy();
  }
}

final class FrameBufferRenderable extends Renderable {
  FrameBufferRenderable({
    super.id,
    super.width,
    super.height,
    super.left,
    super.top,
    required this.buffer,
  });

  final OptimizedBuffer buffer;

  @override
  TuiNode toNode() {
    final lines = <String>[];
    for (var y = 0; y < buffer.height; y++) {
      final row = StringBuffer();
      for (var x = 0; x < buffer.width; x++) {
        row.write(buffer.frame.cellAt(x, y).char);
      }
      lines.add(row.toString());
    }

    return TuiText(
      id: id,
      width: width,
      height: height,
      left: left,
      top: top,
      text: lines.join('\n'),
    );
  }
}
