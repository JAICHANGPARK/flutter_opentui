import 'react_element.dart';

ReactElement box({
  Map<String, Object?> props = const <String, Object?>{},
  List<Object?> children = const <Object?>[],
}) {
  return createElement('box', props: props, children: children);
}

ReactElement text(
  String content, {
  Map<String, Object?> props = const <String, Object?>{},
}) {
  return createElement(
    'text',
    props: <String, Object?>{...props, 'text': content},
  );
}

ReactElement input({Map<String, Object?> props = const <String, Object?>{}}) {
  return createElement('input', props: props);
}

ReactElement select({
  required List<String> options,
  Map<String, Object?> props = const <String, Object?>{},
}) {
  return createElement(
    'select',
    props: <String, Object?>{...props, 'options': options},
  );
}
