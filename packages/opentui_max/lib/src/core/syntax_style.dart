import 'frame.dart';
import 'utils.dart';

typedef ColorInput = Object;

final class StyleDefinition {
  const StyleDefinition({
    this.fg,
    this.bg,
    this.bold,
    this.italic,
    this.underline,
    this.dim,
  });

  final TuiColor? fg;
  final TuiColor? bg;
  final bool? bold;
  final bool? italic;
  final bool? underline;
  final bool? dim;
}

final class MergedStyle {
  const MergedStyle({
    required this.fg,
    required this.bg,
    required this.attributes,
  });

  final TuiColor? fg;
  final TuiColor? bg;
  final int attributes;
}

final class ThemeTokenStyle {
  const ThemeTokenStyle({required this.scope, required this.style});

  final List<String> scope;
  final ThemeStyle style;
}

final class ThemeStyle {
  const ThemeStyle({
    this.foreground,
    this.background,
    this.bold,
    this.italic,
    this.underline,
    this.dim,
  });

  final ColorInput? foreground;
  final ColorInput? background;
  final bool? bold;
  final bool? italic;
  final bool? underline;
  final bool? dim;
}

Map<String, StyleDefinition> convertThemeToStyles(List<ThemeTokenStyle> theme) {
  final flat = <String, StyleDefinition>{};
  for (final tokenStyle in theme) {
    final def = StyleDefinition(
      fg: parseColor(tokenStyle.style.foreground),
      bg: parseColor(tokenStyle.style.background),
      bold: tokenStyle.style.bold,
      italic: tokenStyle.style.italic,
      underline: tokenStyle.style.underline,
      dim: tokenStyle.style.dim,
    );

    for (final scope in tokenStyle.scope) {
      flat[scope] = def;
    }
  }
  return flat;
}

final class SyntaxStyle {
  final Map<String, int> _nameCache = <String, int>{};
  final Map<String, StyleDefinition> _styleDefs = <String, StyleDefinition>{};
  final Map<String, MergedStyle> _mergedCache = <String, MergedStyle>{};
  bool _destroyed = false;
  int _nextId = 1;

  static SyntaxStyle create() => SyntaxStyle();

  static SyntaxStyle fromTheme(List<ThemeTokenStyle> theme) {
    return fromStyles(convertThemeToStyles(theme));
  }

  static SyntaxStyle fromStyles(Map<String, StyleDefinition> styles) {
    final style = SyntaxStyle.create();
    for (final entry in styles.entries) {
      style.registerStyle(entry.key, entry.value);
    }
    return style;
  }

  void _guard() {
    if (_destroyed) {
      throw StateError('SyntaxStyle is destroyed');
    }
  }

  int registerStyle(String name, StyleDefinition style) {
    _guard();
    final existing = _nameCache[name];
    if (existing != null) {
      _styleDefs[name] = style;
      _mergedCache.clear();
      return existing;
    }

    final id = _nextId++;
    _nameCache[name] = id;
    _styleDefs[name] = style;
    _mergedCache.clear();
    return id;
  }

  int? resolveStyleId(String name) {
    _guard();
    return _nameCache[name];
  }

  int? getStyleId(String name) {
    _guard();
    final direct = _nameCache[name];
    if (direct != null) {
      return direct;
    }
    if (name.contains('.')) {
      return _nameCache[name.split('.').first];
    }
    return null;
  }

  int getStyleCount() {
    _guard();
    return _nameCache.length;
  }

  void clearNameCache() {
    _guard();
    _nameCache.clear();
  }

  StyleDefinition? getStyle(String name) {
    _guard();
    final direct = _styleDefs[name];
    if (direct != null) {
      return direct;
    }
    if (name.contains('.')) {
      return _styleDefs[name.split('.').first];
    }
    return null;
  }

  MergedStyle mergeStyles(List<String> styleNames) {
    _guard();
    final cacheKey = styleNames.join(':');
    final cached = _mergedCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    StyleDefinition merged = const StyleDefinition();
    for (final name in styleNames) {
      final style = getStyle(name);
      if (style == null) {
        continue;
      }
      merged = StyleDefinition(
        fg: style.fg ?? merged.fg,
        bg: style.bg ?? merged.bg,
        bold: style.bold ?? merged.bold,
        italic: style.italic ?? merged.italic,
        underline: style.underline ?? merged.underline,
        dim: style.dim ?? merged.dim,
      );
    }

    final result = MergedStyle(
      fg: merged.fg,
      bg: merged.bg,
      attributes: createTextAttributes(
        bold: merged.bold,
        italic: merged.italic,
        underline: merged.underline,
        dim: merged.dim,
      ),
    );

    _mergedCache[cacheKey] = result;
    return result;
  }

  void clearCache() {
    _guard();
    _mergedCache.clear();
  }

  int getCacheSize() {
    _guard();
    return _mergedCache.length;
  }

  Map<String, StyleDefinition> getAllStyles() {
    _guard();
    return Map<String, StyleDefinition>.from(_styleDefs);
  }

  List<String> getRegisteredNames() {
    _guard();
    return _styleDefs.keys.toList(growable: false);
  }

  void destroy() {
    if (_destroyed) {
      return;
    }
    _destroyed = true;
    _nameCache.clear();
    _styleDefs.clear();
    _mergedCache.clear();
  }
}

TuiColor? parseColor(ColorInput? color) {
  if (color == null) {
    return null;
  }
  if (color is TuiColor) {
    return color;
  }
  if (color is int) {
    final r = (color >> 16) & 0xff;
    final g = (color >> 8) & 0xff;
    final b = color & 0xff;
    return TuiColor(r, g, b);
  }
  if (color is String) {
    final value = color.trim();
    if (value.startsWith('#') && value.length == 7) {
      final r = int.tryParse(value.substring(1, 3), radix: 16);
      final g = int.tryParse(value.substring(3, 5), radix: 16);
      final b = int.tryParse(value.substring(5, 7), radix: 16);
      if (r != null && g != null && b != null) {
        return TuiColor(r, g, b);
      }
    }
  }
  return null;
}
