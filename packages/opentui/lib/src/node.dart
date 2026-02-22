import 'buffer.dart';
import 'events.dart';
import 'frame.dart';

enum TuiLayoutDirection { row, column, absolute }

enum TuiJustify { start, center, end, spaceBetween, spaceAround, spaceEvenly }

enum TuiAlign { start, center, end, stretch }

enum TuiWrap { noWrap, wrap }

enum TuiBorderSide { top, right, bottom, left }

enum TuiBorderPreset { single, double, rounded, heavy }

enum TuiTitleAlignment { left, center, right }

bool _isValidBorderValue(Object value) {
  if (value is bool) {
    return true;
  }
  if (value is List) {
    return value.every((entry) => _parseBorderSide(entry) != null);
  }
  return false;
}

TuiBorderSide? _parseBorderSide(Object? entry) {
  if (entry is TuiBorderSide) {
    return entry;
  }
  if (entry is String) {
    switch (entry) {
      case 'top':
        return TuiBorderSide.top;
      case 'right':
        return TuiBorderSide.right;
      case 'bottom':
        return TuiBorderSide.bottom;
      case 'left':
        return TuiBorderSide.left;
    }
  }
  return null;
}

Set<TuiBorderSide> _resolveBorderSides(Object value) {
  if (value is bool) {
    if (!value) {
      return <TuiBorderSide>{};
    }
    return <TuiBorderSide>{
      TuiBorderSide.top,
      TuiBorderSide.right,
      TuiBorderSide.bottom,
      TuiBorderSide.left,
    };
  }
  if (value is List) {
    final sides = <TuiBorderSide>{};
    for (final entry in value) {
      final side = _parseBorderSide(entry);
      if (side != null) {
        sides.add(side);
      }
    }
    return sides;
  }
  return <TuiBorderSide>{};
}

final class TuiBorderChars {
  const TuiBorderChars({
    required this.topLeft,
    required this.topRight,
    required this.bottomLeft,
    required this.bottomRight,
    required this.horizontal,
    required this.vertical,
    required this.topT,
    required this.bottomT,
    required this.leftT,
    required this.rightT,
    required this.cross,
  });

  final String topLeft;
  final String topRight;
  final String bottomLeft;
  final String bottomRight;
  final String horizontal;
  final String vertical;
  final String topT;
  final String bottomT;
  final String leftT;
  final String rightT;
  final String cross;

  static const TuiBorderChars single = TuiBorderChars(
    topLeft: '┌',
    topRight: '┐',
    bottomLeft: '└',
    bottomRight: '┘',
    horizontal: '─',
    vertical: '│',
    topT: '┬',
    bottomT: '┴',
    leftT: '├',
    rightT: '┤',
    cross: '┼',
  );

  static const TuiBorderChars double = TuiBorderChars(
    topLeft: '╔',
    topRight: '╗',
    bottomLeft: '╚',
    bottomRight: '╝',
    horizontal: '═',
    vertical: '║',
    topT: '╦',
    bottomT: '╩',
    leftT: '╠',
    rightT: '╣',
    cross: '╬',
  );

  static const TuiBorderChars rounded = TuiBorderChars(
    topLeft: '╭',
    topRight: '╮',
    bottomLeft: '╰',
    bottomRight: '╯',
    horizontal: '─',
    vertical: '│',
    topT: '┬',
    bottomT: '┴',
    leftT: '├',
    rightT: '┤',
    cross: '┼',
  );

  static const TuiBorderChars heavy = TuiBorderChars(
    topLeft: '┏',
    topRight: '┓',
    bottomLeft: '┗',
    bottomRight: '┛',
    horizontal: '━',
    vertical: '┃',
    topT: '┳',
    bottomT: '┻',
    leftT: '┣',
    rightT: '┫',
    cross: '╋',
  );

  static TuiBorderChars fromPreset(TuiBorderPreset preset) {
    switch (preset) {
      case TuiBorderPreset.single:
        return TuiBorderChars.single;
      case TuiBorderPreset.double:
        return TuiBorderChars.double;
      case TuiBorderPreset.rounded:
        return TuiBorderChars.rounded;
      case TuiBorderPreset.heavy:
        return TuiBorderChars.heavy;
    }
  }
}

final class TuiRect {
  const TuiRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final int x;
  final int y;
  final int width;
  final int height;
}

sealed class TuiNode {
  TuiNode({
    required this.id,
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
    this.focusable = false,
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

  final String id;
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
  double flexGrow;
  bool focusable;
  bool focused = false;

  final List<TuiNode> children = <TuiNode>[];
  TuiNode? _parent;

  TuiRect? _layoutBounds;

  TuiRect? get layoutBounds => _layoutBounds;
  TuiNode? get parent => _parent;

  void setLayoutBounds(TuiRect value) {
    _layoutBounds = value;
  }

  void add(TuiNode child) {
    if (identical(child, this)) {
      throw ArgumentError('A node cannot contain itself.');
    }
    if (identical(child._parent, this)) {
      return;
    }
    child._parent?.remove(child);
    child._parent = this;
    children.add(child);
  }

  void remove(TuiNode child) {
    final removed = children.remove(child);
    if (removed && identical(child._parent, this)) {
      child._parent = null;
    }
  }

  int get resolvedMarginLeft => marginLeft ?? marginX ?? margin;

  int get resolvedMarginTop => marginTop ?? marginY ?? margin;

  int get resolvedMarginRight => marginRight ?? marginX ?? margin;

  int get resolvedMarginBottom => marginBottom ?? marginY ?? margin;

  void onKey(TuiKeyEvent keyEvent) {}

  void onMouse(TuiMouseEvent mouseEvent) {}
}

final class TuiBox extends TuiNode {
  TuiBox({
    required super.id,
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
    this.titleAlignment = TuiTitleAlignment.left,
    this.padding = 0,
    this.paddingX,
    this.paddingY,
    this.paddingLeft,
    this.paddingTop,
    this.paddingRight,
    this.paddingBottom,
    this.style = TuiStyle.plain,
    this.borderStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.borderPreset = TuiBorderPreset.single,
    this.borderChars,
  }) : borderSides = _resolveBorderSides(border),
       assert(_isValidBorderValue(border)),
       assert(padding >= 0),
       assert(paddingX == null || paddingX >= 0),
       assert(paddingY == null || paddingY >= 0),
       assert(paddingLeft == null || paddingLeft >= 0),
       assert(paddingTop == null || paddingTop >= 0),
       assert(paddingRight == null || paddingRight >= 0),
       assert(paddingBottom == null || paddingBottom >= 0);

  final TuiLayoutDirection layoutDirection;
  final TuiWrap wrap;
  final TuiJustify justify;
  final TuiAlign align;
  final Object border;
  final Set<TuiBorderSide> borderSides;
  final String? title;
  final TuiTitleAlignment titleAlignment;
  final int padding;
  final int? paddingX;
  final int? paddingY;
  final int? paddingLeft;
  final int? paddingTop;
  final int? paddingRight;
  final int? paddingBottom;
  final TuiStyle style;
  final TuiStyle borderStyle;
  final TuiBorderPreset borderPreset;
  final TuiBorderChars? borderChars;

  int get resolvedPaddingLeft => paddingLeft ?? paddingX ?? padding;

  int get resolvedPaddingTop => paddingTop ?? paddingY ?? padding;

  int get resolvedPaddingRight => paddingRight ?? paddingX ?? padding;

  int get resolvedPaddingBottom => paddingBottom ?? paddingY ?? padding;

  TuiBorderChars get resolvedBorderChars =>
      borderChars ?? TuiBorderChars.fromPreset(borderPreset);

  bool get hasBorder => borderSides.isNotEmpty;

  bool get hasBorderTop => borderSides.contains(TuiBorderSide.top);

  bool get hasBorderRight => borderSides.contains(TuiBorderSide.right);

  bool get hasBorderBottom => borderSides.contains(TuiBorderSide.bottom);

  bool get hasBorderLeft => borderSides.contains(TuiBorderSide.left);
}

class TuiText extends TuiNode {
  TuiText({
    required super.id,
    required this.text,
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
    this.style = TuiStyle.plain,
    this.selectable = true,
  });

  String text;
  TuiStyle style;
  bool selectable;
}

class TuiInput extends TuiNode {
  TuiInput({
    required super.id,
    this.value = '',
    this.placeholder = '',
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
    this.style = TuiStyle.plain,
    this.focusedStyle = const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.white,
    ),
    this.placeholderStyle = const TuiStyle(foreground: TuiColor.cyan),
  }) : super(focusable: true) {
    cursorPosition = value.length;
  }

  String value;
  String placeholder;
  TuiStyle style;
  TuiStyle focusedStyle;
  TuiStyle placeholderStyle;
  late int cursorPosition;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    if (special == TuiSpecialKey.backspace) {
      if (cursorPosition > 0 && value.isNotEmpty) {
        final previousIndex = cursorPosition - 1;
        value = value.replaceRange(previousIndex, cursorPosition, '');
        cursorPosition = previousIndex;
      }
      return;
    }
    if (special == TuiSpecialKey.delete) {
      if (cursorPosition < value.length && value.isNotEmpty) {
        value = value.replaceRange(cursorPosition, cursorPosition + 1, '');
      }
      return;
    }
    if (special == TuiSpecialKey.arrowLeft) {
      if (cursorPosition > 0) {
        cursorPosition -= 1;
      }
      return;
    }
    if (special == TuiSpecialKey.arrowRight) {
      if (cursorPosition < value.length) {
        cursorPosition += 1;
      }
      return;
    }
    if (special == TuiSpecialKey.home) {
      cursorPosition = 0;
      return;
    }
    if (special == TuiSpecialKey.end) {
      cursorPosition = value.length;
      return;
    }

    final paste = keyEvent.paste;
    if (paste != null) {
      value = value.replaceRange(cursorPosition, cursorPosition, paste.text);
      cursorPosition += paste.text.length;
      return;
    }

    final character = keyEvent.character;
    if (character == null || keyEvent.ctrl || keyEvent.alt) {
      return;
    }
    value = value.replaceRange(cursorPosition, cursorPosition, character);
    cursorPosition += character.length;
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (mouseEvent.type != TuiMouseEventType.down ||
        (mouseEvent.button != TuiMouseButton.left &&
            mouseEvent.button != TuiMouseButton.none)) {
      return;
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    final localX = (mouseEvent.x - bounds.x).clamp(0, value.length).toInt();
    cursorPosition = localX;
    mouseEvent.stopPropagation();
  }
}

final class TuiTextarea extends TuiInput {
  TuiTextarea({
    required super.id,
    super.value,
    super.placeholder,
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
    super.style,
    super.focusedStyle,
    super.placeholderStyle,
    this.scrollTop = 0,
  });

  int scrollTop;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    if (special == TuiSpecialKey.home) {
      cursorPosition = _lineStart(cursorPosition);
      return;
    }
    if (special == TuiSpecialKey.end) {
      cursorPosition = _lineEnd(cursorPosition);
      return;
    }
    if (special == TuiSpecialKey.pageUp) {
      _moveVertical(-5);
      return;
    }
    if (special == TuiSpecialKey.pageDown) {
      _moveVertical(5);
      return;
    }
    if (special == TuiSpecialKey.arrowUp) {
      _moveVertical(-1);
      return;
    }
    if (special == TuiSpecialKey.arrowDown) {
      _moveVertical(1);
      return;
    }
    if (special == TuiSpecialKey.enter) {
      value = value.replaceRange(cursorPosition, cursorPosition, '\n');
      cursorPosition += 1;
      return;
    }
    super.onKey(keyEvent);
  }

  int _lineStart(int index) {
    final clamped = index.clamp(0, value.length).toInt();
    final breakIndex = value.lastIndexOf('\n', clamped - 1);
    return breakIndex < 0 ? 0 : breakIndex + 1;
  }

  int _lineEnd(int index) {
    final start = _lineStart(index);
    final breakIndex = value.indexOf('\n', start);
    return breakIndex < 0 ? value.length : breakIndex;
  }

  void _moveVertical(int delta) {
    if (delta == 0) {
      return;
    }

    final moves = delta.abs();
    for (var i = 0; i < moves; i++) {
      final start = _lineStart(cursorPosition);
      final column = cursorPosition - start;

      if (delta < 0) {
        if (start == 0) {
          return;
        }
        final previousBreak = value.lastIndexOf('\n', start - 2);
        final previousStart = previousBreak < 0 ? 0 : previousBreak + 1;
        final previousEnd = start - 1;
        final previousLength = previousEnd - previousStart;
        cursorPosition = previousStart + column.clamp(0, previousLength);
        continue;
      }

      final nextBreak = value.indexOf('\n', start);
      if (nextBreak < 0) {
        return;
      }
      final nextStart = nextBreak + 1;
      final nextEndBreak = value.indexOf('\n', nextStart);
      final nextEnd = nextEndBreak < 0 ? value.length : nextEndBreak;
      final nextLength = nextEnd - nextStart;
      cursorPosition = nextStart + column.clamp(0, nextLength);
    }
  }

  int _offsetForRowColumn(int row, int column) {
    if (row <= 0) {
      return column.clamp(0, _lineEnd(0)).toInt();
    }
    var currentRow = 0;
    var start = 0;
    while (currentRow < row && start <= value.length) {
      final breakIndex = value.indexOf('\n', start);
      if (breakIndex < 0) {
        return (start + column).clamp(start, value.length).toInt();
      }
      start = breakIndex + 1;
      currentRow++;
    }
    final lineEndBreak = value.indexOf('\n', start);
    final lineEnd = lineEndBreak < 0 ? value.length : lineEndBreak;
    return (start + column).clamp(start, lineEnd).toInt();
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (mouseEvent.type != TuiMouseEventType.down ||
        (mouseEvent.button != TuiMouseButton.left &&
            mouseEvent.button != TuiMouseButton.none)) {
      return super.onMouse(mouseEvent);
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    final localX = (mouseEvent.x - bounds.x).clamp(0, bounds.width - 1).toInt();
    final localY = (mouseEvent.y - bounds.y)
        .clamp(0, bounds.height - 1)
        .toInt();
    cursorPosition = _offsetForRowColumn(scrollTop + localY, localX);
    mouseEvent.stopPropagation();
  }
}

final class TuiSelect extends TuiNode {
  TuiSelect({
    required super.id,
    required this.options,
    this.selectedIndex = 0,
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
    this.style = TuiStyle.plain,
    this.selectedStyle = const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.green,
      bold: true,
    ),
  }) : super(focusable: true);

  final List<String> options;
  int selectedIndex;
  TuiStyle style;
  TuiStyle selectedStyle;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    if (options.isEmpty) {
      return;
    }
    if (special == TuiSpecialKey.home || special == TuiSpecialKey.pageUp) {
      selectedIndex = 0;
      return;
    }
    if (special == TuiSpecialKey.end || special == TuiSpecialKey.pageDown) {
      selectedIndex = options.length - 1;
      return;
    }
    if (special == TuiSpecialKey.arrowUp) {
      selectedIndex = (selectedIndex - 1).clamp(0, options.length - 1);
      return;
    }
    if (special == TuiSpecialKey.arrowDown) {
      selectedIndex = (selectedIndex + 1).clamp(0, options.length - 1);
    }
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (options.isEmpty) {
      return;
    }
    if (mouseEvent.type == TuiMouseEventType.scroll &&
        mouseEvent.scroll != null) {
      final direction = mouseEvent.scroll!.direction;
      if (direction == TuiScrollDirection.up) {
        selectedIndex = (selectedIndex - 1).clamp(0, options.length - 1);
        mouseEvent.stopPropagation();
        return;
      }
      if (direction == TuiScrollDirection.down) {
        selectedIndex = (selectedIndex + 1).clamp(0, options.length - 1);
        mouseEvent.stopPropagation();
        return;
      }
    }
    if (mouseEvent.type != TuiMouseEventType.down ||
        (mouseEvent.button != TuiMouseButton.left &&
            mouseEvent.button != TuiMouseButton.none)) {
      return;
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    final localY = (mouseEvent.y - bounds.y)
        .clamp(0, bounds.height - 1)
        .toInt();
    selectedIndex = localY.clamp(0, options.length - 1);
    mouseEvent.stopPropagation();
  }
}

final class TuiTabSelect extends TuiNode {
  TuiTabSelect({
    required super.id,
    required this.options,
    this.selectedIndex = 0,
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
    this.style = TuiStyle.plain,
    this.selectedStyle = const TuiStyle(
      foreground: TuiColor.black,
      background: TuiColor.green,
      bold: true,
    ),
    this.separator = ' | ',
  }) : super(focusable: true);

  final List<String> options;
  int selectedIndex;
  TuiStyle style;
  TuiStyle selectedStyle;
  String separator;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    if (options.isEmpty) {
      return;
    }
    if (special == TuiSpecialKey.home || special == TuiSpecialKey.pageUp) {
      selectedIndex = 0;
      return;
    }
    if (special == TuiSpecialKey.end || special == TuiSpecialKey.pageDown) {
      selectedIndex = options.length - 1;
      return;
    }
    if (special == TuiSpecialKey.arrowLeft ||
        special == TuiSpecialKey.arrowUp) {
      selectedIndex = (selectedIndex - 1).clamp(0, options.length - 1);
      return;
    }
    if (special == TuiSpecialKey.arrowRight ||
        special == TuiSpecialKey.arrowDown) {
      selectedIndex = (selectedIndex + 1).clamp(0, options.length - 1);
    }
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (options.isEmpty) {
      return;
    }
    if (mouseEvent.type == TuiMouseEventType.scroll &&
        mouseEvent.scroll != null) {
      final direction = mouseEvent.scroll!.direction;
      if (direction == TuiScrollDirection.left ||
          direction == TuiScrollDirection.up) {
        selectedIndex = (selectedIndex - 1).clamp(0, options.length - 1);
        mouseEvent.stopPropagation();
        return;
      }
      if (direction == TuiScrollDirection.right ||
          direction == TuiScrollDirection.down) {
        selectedIndex = (selectedIndex + 1).clamp(0, options.length - 1);
        mouseEvent.stopPropagation();
        return;
      }
    }
    if (mouseEvent.type != TuiMouseEventType.down ||
        (mouseEvent.button != TuiMouseButton.left &&
            mouseEvent.button != TuiMouseButton.none)) {
      return;
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    final localX = (mouseEvent.x - bounds.x).clamp(0, bounds.width - 1).toInt();
    var cursor = 0;
    for (var i = 0; i < options.length; i++) {
      final label = ' ${options[i]} ';
      final end = cursor + label.length;
      if (localX >= cursor && localX < end) {
        selectedIndex = i;
        mouseEvent.stopPropagation();
        return;
      }
      cursor = end;
      if (i < options.length - 1) {
        cursor += separator.length;
      }
    }
  }
}

final class TuiAsciiFont extends TuiNode {
  TuiAsciiFont({
    required super.id,
    required this.text,
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
    this.style = TuiStyle.plain,
    this.letterSpacing = 1,
    this.selectable = true,
  });

  static const int defaultGlyphHeight = 5;

  String text;
  TuiStyle style;
  int letterSpacing;
  bool selectable;
}

final class TuiFrameBufferNode extends TuiNode {
  TuiFrameBufferNode({
    required super.id,
    required this.buffer,
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
    this.transparent = false,
  });

  final OptimizedBuffer buffer;
  bool transparent;
}

final class TuiMarkdown extends TuiText {
  TuiMarkdown({
    required super.id,
    required this.markdown,
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
    super.style,
  }) : super(text: _stripMarkdown(markdown));

  String markdown;

  static String _stripMarkdown(String input) {
    var normalized = input.replaceAll('\r\n', '\n');
    normalized = normalized
        .split('\n')
        .map(
          (line) => line
              .replaceFirst(RegExp(r'^\s{0,3}#{1,6}\s*'), '')
              .replaceFirst(RegExp(r'^\s*>\s?'), '')
              .replaceFirst(RegExp(r'^\s*[-*+]\s+'), ''),
        )
        .join('\n');
    normalized = normalized
        .replaceAllMapped(RegExp(r'\[(.*?)\]\((.*?)\)'), (m) => m.group(1)!)
        .replaceAll(RegExp(r'([*_~`]{1,3})'), '');
    return normalized;
  }
}

final class TuiCode extends TuiText {
  TuiCode({
    required super.id,
    required this.code,
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
    super.style,
  }) : super(text: code);

  String code;
}

final class TuiDiff extends TuiText {
  TuiDiff({
    required super.id,
    required this.previous,
    required this.next,
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
    super.style,
  }) : super(text: _buildDiff(previous, next));

  String previous;
  String next;

  static String _buildDiff(String previous, String next) {
    final oldLines = previous.split('\n');
    final newLines = next.split('\n');
    final maxLines = oldLines.length > newLines.length
        ? oldLines.length
        : newLines.length;
    final lines = <String>[];

    for (var i = 0; i < maxLines; i++) {
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

final class TuiLineNumber extends TuiText {
  TuiLineNumber({
    required super.id,
    required this.lines,
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
    super.style,
  }) : super(text: _build(lines));

  List<String> lines;

  static String _build(List<String> lines) {
    final width = lines.length.toString().length;
    final buffer = StringBuffer();
    for (var i = 0; i < lines.length; i++) {
      buffer.writeln('${(i + 1).toString().padLeft(width)} ${lines[i]}');
    }
    return buffer.toString();
  }
}

final class TuiScrollBox extends TuiBox {
  TuiScrollBox({
    required super.id,
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
    super.titleAlignment,
    super.padding,
    super.paddingX,
    super.paddingY,
    super.paddingLeft,
    super.paddingTop,
    super.paddingRight,
    super.paddingBottom,
    super.style,
    super.borderStyle,
    super.borderPreset,
    super.borderChars,
    this.scrollOffset = 0,
    this.scrollStep = 1,
    this.fastScrollStep = 5,
  }) : assert(scrollOffset >= 0),
       assert(scrollStep > 0),
       assert(fastScrollStep > 0) {
    focusable = true;
  }

  int scrollOffset;
  int scrollStep;
  int fastScrollStep;

  void scrollBy(int delta) {
    if (delta == 0) {
      return;
    }
    final maxOffset = children.isEmpty ? 0 : children.length - 1;
    scrollOffset = (scrollOffset + delta).clamp(0, maxOffset).toInt();
  }

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    final step = keyEvent.shift ? fastScrollStep : scrollStep;
    final maxOffset = children.isEmpty ? 0 : children.length - 1;
    if (special == TuiSpecialKey.home) {
      scrollOffset = 0;
      return;
    }
    if (special == TuiSpecialKey.end) {
      scrollOffset = maxOffset;
      return;
    }
    if (special == TuiSpecialKey.pageUp) {
      scrollBy(-fastScrollStep);
      return;
    }
    if (special == TuiSpecialKey.pageDown) {
      scrollBy(fastScrollStep);
      return;
    }
    if (special == TuiSpecialKey.arrowUp ||
        special == TuiSpecialKey.arrowLeft) {
      scrollBy(-step);
      return;
    }
    if (special == TuiSpecialKey.arrowDown ||
        special == TuiSpecialKey.arrowRight) {
      scrollBy(step);
    }
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (mouseEvent.type != TuiMouseEventType.scroll ||
        mouseEvent.scroll == null) {
      return;
    }
    final scroll = mouseEvent.scroll!;
    final delta = scroll.delta.clamp(1, 100).toInt();
    switch (scroll.direction) {
      case TuiScrollDirection.up:
      case TuiScrollDirection.left:
        scrollBy(-delta * scrollStep);
      case TuiScrollDirection.down:
      case TuiScrollDirection.right:
        scrollBy(delta * scrollStep);
    }
    mouseEvent.stopPropagation();
  }
}

final class TuiScrollbar extends TuiNode {
  TuiScrollbar({
    required super.id,
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
    double value = 0,
    double thumbRatio = 0.2,
    this.step = 0.05,
    this.fastStep = 0.2,
    this.vertical = true,
    this.trackStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.thumbStyle = const TuiStyle(foreground: TuiColor.white, bold: true),
  }) : assert(thumbRatio > 0 && thumbRatio <= 1),
       assert(step > 0),
       assert(fastStep > 0),
       value = value.clamp(0.0, 1.0).toDouble(),
       thumbRatio = thumbRatio.clamp(0.0, 1.0).toDouble(),
       super(focusable: true);

  double value;
  double thumbRatio;
  double step;
  double fastStep;
  bool vertical;
  TuiStyle trackStyle;
  TuiStyle thumbStyle;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    final delta = keyEvent.shift ? fastStep : step;
    if (special == TuiSpecialKey.home) {
      value = 0.0;
      return;
    }
    if (special == TuiSpecialKey.end) {
      value = 1.0;
      return;
    }
    if (special == TuiSpecialKey.pageUp) {
      value = (value - fastStep).clamp(0.0, 1.0);
      return;
    }
    if (special == TuiSpecialKey.pageDown) {
      value = (value + fastStep).clamp(0.0, 1.0);
      return;
    }
    if (special == TuiSpecialKey.arrowUp ||
        special == TuiSpecialKey.arrowLeft) {
      value = (value - delta).clamp(0.0, 1.0);
      return;
    }
    if (special == TuiSpecialKey.arrowDown ||
        special == TuiSpecialKey.arrowRight) {
      value = (value + delta).clamp(0.0, 1.0);
    }
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (mouseEvent.type == TuiMouseEventType.scroll &&
        mouseEvent.scroll != null) {
      final scroll = mouseEvent.scroll!;
      final delta = step * scroll.delta.clamp(1, 100);
      if (scroll.direction == TuiScrollDirection.up ||
          scroll.direction == TuiScrollDirection.left) {
        value = (value - delta).clamp(0.0, 1.0);
      } else {
        value = (value + delta).clamp(0.0, 1.0);
      }
      mouseEvent.stopPropagation();
      return;
    }

    if (mouseEvent.type != TuiMouseEventType.down) {
      return;
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    if (vertical) {
      if (bounds.height <= 1) {
        value = 0.0;
      } else {
        final localY = (mouseEvent.y - bounds.y).clamp(0, bounds.height - 1);
        value = (localY / (bounds.height - 1)).clamp(0.0, 1.0);
      }
    } else {
      if (bounds.width <= 1) {
        value = 0.0;
      } else {
        final localX = (mouseEvent.x - bounds.x).clamp(0, bounds.width - 1);
        value = (localX / (bounds.width - 1)).clamp(0.0, 1.0);
      }
    }
    mouseEvent.stopPropagation();
  }
}

typedef TuiScrollBar = TuiScrollbar;

final class TuiSlider extends TuiNode {
  TuiSlider({
    required super.id,
    this.min = 0,
    this.max = 100,
    double value = 0,
    this.step = 1,
    this.vertical = false,
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
    this.trackStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.thumbStyle = const TuiStyle(foreground: TuiColor.white, bold: true),
  }) : assert(max >= min),
       assert(step > 0),
       value = value.clamp(min, max),
       super(focusable: true);

  final double min;
  final double max;
  double value;
  final double step;
  final bool vertical;
  TuiStyle trackStyle;
  TuiStyle thumbStyle;

  @override
  void onKey(TuiKeyEvent keyEvent) {
    final special = keyEvent.special;
    final pageStep = step * 5;
    if (special == TuiSpecialKey.home) {
      value = min;
      return;
    }
    if (special == TuiSpecialKey.end) {
      value = max;
      return;
    }
    if (special == TuiSpecialKey.pageUp) {
      value = (value + pageStep).clamp(min, max);
      return;
    }
    if (special == TuiSpecialKey.pageDown) {
      value = (value - pageStep).clamp(min, max);
      return;
    }
    if (special == TuiSpecialKey.arrowLeft ||
        special == TuiSpecialKey.arrowDown) {
      value = (value - step).clamp(min, max);
      return;
    }
    if (special == TuiSpecialKey.arrowRight ||
        special == TuiSpecialKey.arrowUp) {
      value = (value + step).clamp(min, max);
    }
  }

  @override
  void onMouse(TuiMouseEvent mouseEvent) {
    if (mouseEvent.type == TuiMouseEventType.scroll &&
        mouseEvent.scroll != null) {
      final scroll = mouseEvent.scroll!;
      final delta = step * scroll.delta.clamp(1, 100);
      if (scroll.direction == TuiScrollDirection.up ||
          scroll.direction == TuiScrollDirection.right) {
        value = (value + delta).clamp(min, max);
      } else {
        value = (value - delta).clamp(min, max);
      }
      mouseEvent.stopPropagation();
      return;
    }

    if (mouseEvent.type != TuiMouseEventType.down) {
      return;
    }
    final bounds = layoutBounds;
    if (bounds == null) {
      return;
    }
    if (vertical) {
      if (bounds.height <= 1) {
        value = min;
      } else {
        final localY = (mouseEvent.y - bounds.y).clamp(0, bounds.height - 1);
        final ratio = (bounds.height - 1 - localY) / (bounds.height - 1);
        value = (min + (max - min) * ratio).clamp(min, max);
      }
    } else {
      if (bounds.width <= 1) {
        value = min;
      } else {
        final localX = (mouseEvent.x - bounds.x).clamp(0, bounds.width - 1);
        final ratio = localX / (bounds.width - 1);
        value = (min + (max - min) * ratio).clamp(min, max);
      }
    }
    mouseEvent.stopPropagation();
  }
}
