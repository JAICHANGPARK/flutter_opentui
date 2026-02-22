import 'buffer.dart';
import 'events.dart';
import 'frame.dart';

enum TuiLayoutDirection { row, column, absolute }

enum TuiJustify { start, center, end, spaceBetween, spaceAround, spaceEvenly }

enum TuiAlign { start, center, end, stretch }

enum TuiWrap { noWrap, wrap }

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

  TuiRect? _layoutBounds;

  TuiRect? get layoutBounds => _layoutBounds;

  void setLayoutBounds(TuiRect value) {
    _layoutBounds = value;
  }

  void add(TuiNode child) {
    children.add(child);
  }

  void remove(TuiNode child) {
    children.remove(child);
  }

  int get resolvedMarginLeft => marginLeft ?? marginX ?? margin;

  int get resolvedMarginTop => marginTop ?? marginY ?? margin;

  int get resolvedMarginRight => marginRight ?? marginX ?? margin;

  int get resolvedMarginBottom => marginBottom ?? marginY ?? margin;

  void onKey(TuiKeyEvent keyEvent) {}
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

  final TuiLayoutDirection layoutDirection;
  final TuiWrap wrap;
  final TuiJustify justify;
  final TuiAlign align;
  final bool border;
  final String? title;
  final int padding;
  final int? paddingX;
  final int? paddingY;
  final int? paddingLeft;
  final int? paddingTop;
  final int? paddingRight;
  final int? paddingBottom;
  final TuiStyle style;
  final TuiStyle borderStyle;

  int get resolvedPaddingLeft => paddingLeft ?? paddingX ?? padding;

  int get resolvedPaddingTop => paddingTop ?? paddingY ?? padding;

  int get resolvedPaddingRight => paddingRight ?? paddingX ?? padding;

  int get resolvedPaddingBottom => paddingBottom ?? paddingY ?? padding;
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
  });

  String text;
  TuiStyle style;
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

  void _moveVertical(int delta) {
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
      return;
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
    if (special == TuiSpecialKey.arrowUp) {
      selectedIndex = (selectedIndex - 1).clamp(0, options.length - 1);
      return;
    }
    if (special == TuiSpecialKey.arrowDown) {
      selectedIndex = (selectedIndex + 1).clamp(0, options.length - 1);
    }
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
  });

  static const int defaultGlyphHeight = 5;

  String text;
  TuiStyle style;
  int letterSpacing;
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
}
