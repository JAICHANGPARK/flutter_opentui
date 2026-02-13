import '../frame.dart';

typedef FrameFilter = TuiFrame Function(TuiFrame frame);

TuiFrame applyFilters(TuiFrame frame, List<FrameFilter> filters) {
  var current = frame;
  for (final filter in filters) {
    current = filter(current);
  }
  return current;
}
