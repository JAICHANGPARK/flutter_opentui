import 'events.dart';
import 'frame.dart';

enum TuiLayoutDirection { row, column, absolute }

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
    this.left,
    this.top,
    this.focusable = false,
  });

  final String id;
  int? width;
  int? height;
  int? left;
  int? top;
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
    this.layoutDirection = TuiLayoutDirection.column,
    this.border = false,
    this.title,
    this.titleAlignment = TuiTitleAlignment.left,
    this.padding = 0,
    this.style = TuiStyle.plain,
    this.borderStyle = const TuiStyle(foreground: TuiColor.cyan),
    this.borderPreset = TuiBorderPreset.single,
    this.borderChars,
  }) : borderSides = _resolveBorderSides(border),
       assert(_isValidBorderValue(border));

  final TuiLayoutDirection layoutDirection;
  final Object border;
  final Set<TuiBorderSide> borderSides;
  final String? title;
  final TuiTitleAlignment titleAlignment;
  final int padding;
  final TuiStyle style;
  final TuiStyle borderStyle;
  final TuiBorderPreset borderPreset;
  final TuiBorderChars? borderChars;

  TuiBorderChars get resolvedBorderChars =>
      borderChars ?? TuiBorderChars.fromPreset(borderPreset);

  bool get hasBorder => borderSides.isNotEmpty;

  bool get hasBorderTop => borderSides.contains(TuiBorderSide.top);

  bool get hasBorderRight => borderSides.contains(TuiBorderSide.right);

  bool get hasBorderBottom => borderSides.contains(TuiBorderSide.bottom);

  bool get hasBorderLeft => borderSides.contains(TuiBorderSide.left);
}

final class TuiText extends TuiNode {
  TuiText({
    required super.id,
    required this.text,
    super.width,
    super.height,
    super.left,
    super.top,
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
}
