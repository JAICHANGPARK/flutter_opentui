import 'package:meta/meta.dart';

@immutable
final class TuiSelectionPoint {
  const TuiSelectionPoint({required this.x, required this.y});

  final int x;
  final int y;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TuiSelectionPoint && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

@immutable
final class TuiSelectionRange {
  const TuiSelectionRange({required this.anchor, required this.focus});

  final TuiSelectionPoint anchor;
  final TuiSelectionPoint focus;

  TuiSelectionPoint get start {
    if (anchor.y < focus.y) {
      return anchor;
    }
    if (anchor.y > focus.y) {
      return focus;
    }
    return anchor.x <= focus.x ? anchor : focus;
  }

  TuiSelectionPoint get end {
    if (anchor.y > focus.y) {
      return anchor;
    }
    if (anchor.y < focus.y) {
      return focus;
    }
    return anchor.x >= focus.x ? anchor : focus;
  }

  bool get isCollapsed => anchor == focus;

  bool containsCell(int x, int y) {
    final normalizedStart = start;
    final normalizedEnd = end;
    if (y < normalizedStart.y || y > normalizedEnd.y) {
      return false;
    }

    if (normalizedStart.y == normalizedEnd.y) {
      return x >= normalizedStart.x && x <= normalizedEnd.x;
    }
    if (y == normalizedStart.y) {
      return x >= normalizedStart.x;
    }
    if (y == normalizedEnd.y) {
      return x <= normalizedEnd.x;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is TuiSelectionRange &&
        other.anchor == anchor &&
        other.focus == focus;
  }

  @override
  int get hashCode => Object.hash(anchor, focus);
}
