import '../core/node.dart';
import 'react_element.dart';

final class ReactRenderResult {
  const ReactRenderResult({required this.root});

  final TuiNode root;
}

final class OpenTuiReactRenderer {
  OpenTuiReactRenderer({String idPrefix = 'react'}) : _idPrefix = idPrefix;

  final String _idPrefix;
  int _counter = 0;

  ReactRenderResult render(ReactElement element) {
    return ReactRenderResult(root: _buildNode(element));
  }

  TuiNode _buildNode(ReactElement element) {
    final id = '${_idPrefix}_${_counter++}';

    final props = element.props;
    switch (element.type) {
      case 'box':
        final layout = props['layoutDirection'];
        final direction = switch (layout) {
          'row' => TuiLayoutDirection.row,
          'absolute' => TuiLayoutDirection.absolute,
          _ => TuiLayoutDirection.column,
        };

        final node = TuiBox(
          id: _stringOr(props['id'], id),
          width: _intOrNull(props['width']),
          height: _intOrNull(props['height']),
          left: _intOrNull(props['left']),
          top: _intOrNull(props['top']),
          layoutDirection: direction,
          border: _borderOr(props['border']),
          title: props['title'] as String?,
          titleAlignment: _titleAlignmentOr(props['titleAlignment']),
          padding: _intOr(props['padding'], 0),
        );
        for (final child in element.children) {
          final childNode = _coerceChild(child);
          if (childNode != null) {
            node.add(childNode);
          }
        }
        return node;
      case 'text':
        return TuiText(
          id: _stringOr(props['id'], id),
          width: _intOrNull(props['width']),
          height: _intOrNull(props['height']),
          left: _intOrNull(props['left']),
          top: _intOrNull(props['top']),
          text: _stringOr(props['text'], ''),
        );
      case 'input':
        return TuiInput(
          id: _stringOr(props['id'], id),
          width: _intOrNull(props['width']),
          height: _intOrNull(props['height']),
          left: _intOrNull(props['left']),
          top: _intOrNull(props['top']),
          value: _stringOr(props['value'], ''),
          placeholder: _stringOr(props['placeholder'], ''),
        );
      case 'select':
        final options =
            (props['options'] as List<dynamic>? ?? const <dynamic>[])
                .map((value) => value.toString())
                .toList(growable: false);

        return TuiSelect(
          id: _stringOr(props['id'], id),
          width: _intOrNull(props['width']),
          height: _intOrNull(props['height']),
          left: _intOrNull(props['left']),
          top: _intOrNull(props['top']),
          options: options,
          selectedIndex: _intOr(props['selectedIndex'], 0),
        );
      default:
        throw ArgumentError.value(
          element.type,
          'element.type',
          'Unsupported React element type.',
        );
    }
  }

  TuiNode? _coerceChild(Object? child) {
    if (child == null) {
      return null;
    }
    if (child is ReactElement) {
      return _buildNode(child);
    }
    if (child is String) {
      return TuiText(id: '${_idPrefix}_${_counter++}', text: child);
    }
    throw ArgumentError.value(
      child,
      'child',
      'Unsupported child for React element tree.',
    );
  }

  int _intOr(Object? value, int fallback) {
    if (value is int) {
      return value;
    }
    return fallback;
  }

  int? _intOrNull(Object? value) {
    if (value is int) {
      return value;
    }
    return null;
  }

  String _stringOr(Object? value, String fallback) {
    if (value is String) {
      return value;
    }
    return fallback;
  }

  Object _borderOr(Object? value) {
    if (value is bool) {
      return value;
    }
    if (value is List) {
      final sides = <TuiBorderSide>[];
      for (final entry in value) {
        switch (entry) {
          case 'top':
            sides.add(TuiBorderSide.top);
            break;
          case 'right':
            sides.add(TuiBorderSide.right);
            break;
          case 'bottom':
            sides.add(TuiBorderSide.bottom);
            break;
          case 'left':
            sides.add(TuiBorderSide.left);
            break;
        }
      }
      return sides;
    }
    return false;
  }

  TuiTitleAlignment _titleAlignmentOr(Object? value) {
    switch (value) {
      case 'center':
        return TuiTitleAlignment.center;
      case 'right':
        return TuiTitleAlignment.right;
      default:
        return TuiTitleAlignment.left;
    }
  }
}
