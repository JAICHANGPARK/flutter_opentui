int createTextAttributes({
  bool? bold,
  bool? italic,
  bool? underline,
  bool? dim,
  bool? inverse,
}) {
  var mask = 0;
  if (bold ?? false) {
    mask |= 1 << 0;
  }
  if (italic ?? false) {
    mask |= 1 << 1;
  }
  if (underline ?? false) {
    mask |= 1 << 2;
  }
  if (dim ?? false) {
    mask |= 1 << 3;
  }
  if (inverse ?? false) {
    mask |= 1 << 4;
  }
  return mask;
}

List<String> splitLines(String text) =>
    text.isEmpty ? const <String>[''] : text.split('\n');

int clampInt(int value, int min, int max) {
  if (value < min) {
    return min;
  }
  if (value > max) {
    return max;
  }
  return value;
}
