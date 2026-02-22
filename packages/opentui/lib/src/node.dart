import 'events.dart';
import 'buffer.dart';
import 'frame.dart';

enum TuiLayoutDirection { row, column, absolute }

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
    this.left,
    this.top,
    this.focusable = false,
    this.flexGrow = 1.0,
  }) : assert(flexGrow >= 0);

  final String id;
  int? width;
  int? height;
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

  void onKey(TuiKeyEvent keyEvent) {}
}

final class TuiBox extends TuiNode {
  TuiBox({
    required super.id,
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

  final TuiLayoutDirection layoutDirection;
  final bool border;
  final String? title;
  final int padding;
  final TuiStyle style;
  final TuiStyle borderStyle;
}

final class TuiText extends TuiNode {
  TuiText({
    required super.id,
    required this.text,
    super.width,
    super.height,
    super.left,
    super.top,
    super.flexGrow,
    this.style = TuiStyle.plain,
  });

  String text;
  TuiStyle style;
}

final class TuiInput extends TuiNode {
  TuiInput({
    required super.id,
    this.value = '',
    this.placeholder = '',
    super.width,
    super.height,
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
    final character = keyEvent.character;
    if (character == null || keyEvent.ctrl || keyEvent.alt) {
      return;
    }
    value = value.replaceRange(cursorPosition, cursorPosition, character);
    cursorPosition += character.length;
  }
}

final class TuiSelect extends TuiNode {
  TuiSelect({
    required super.id,
    required this.options,
    this.selectedIndex = 0,
    super.width,
    super.height,
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
    super.left,
    super.top,
    super.flexGrow,
    this.transparent = false,
  });

  final OptimizedBuffer buffer;
  bool transparent;
}
