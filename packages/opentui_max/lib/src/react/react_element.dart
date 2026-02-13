typedef ReactProps = Map<String, Object?>;

final class ReactElement {
  const ReactElement({
    required this.type,
    this.props = const <String, Object?>{},
    this.children = const <Object?>[],
  });

  final String type;
  final ReactProps props;
  final List<Object?> children;
}

ReactElement createElement(
  String type, {
  ReactProps props = const <String, Object?>{},
  List<Object?> children = const <Object?>[],
}) {
  return ReactElement(type: type, props: props, children: children);
}
