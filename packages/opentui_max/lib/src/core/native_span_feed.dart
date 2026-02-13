import 'frame.dart';

final class NativeSpan {
  const NativeSpan({required this.text, this.style = TuiStyle.plain});

  final String text;
  final TuiStyle style;
}

final class NativeSpanFeed {
  final List<NativeSpan> _pending = <NativeSpan>[];

  void write(String text, {TuiStyle style = TuiStyle.plain}) {
    _pending.add(NativeSpan(text: text, style: style));
  }

  List<NativeSpan> drain() {
    final copy = List<NativeSpan>.from(_pending);
    _pending.clear();
    return copy;
  }

  bool get isEmpty => _pending.isEmpty;
}
