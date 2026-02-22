import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

enum ConsolePosition { top, right, bottom, left }

enum ConsoleLevel { log, info, warn, error, debug }

final class ConsoleEntry {
  const ConsoleEntry({
    required this.level,
    required this.message,
    required this.timestamp,
  });

  final ConsoleLevel level;
  final String message;
  final DateTime timestamp;
}

final class ConsoleSnapshot {
  const ConsoleSnapshot({
    required this.isOpen,
    required this.isFocused,
    required this.position,
    required this.sizePercent,
    required this.scrollOffset,
    required this.entries,
  });

  final bool isOpen;
  final bool isFocused;
  final ConsolePosition position;
  final int sizePercent;
  final int scrollOffset;
  final List<ConsoleEntry> entries;
}

final class OpenTuiConsole {
  OpenTuiConsole({
    this.capacity = 500,
    ConsolePosition position = ConsolePosition.bottom,
    int sizePercent = 30,
    bool startOpen = false,
  }) : _position = position,
       _sizePercent = _clampSize(sizePercent),
       _isOpen = startOpen,
       _isFocused = startOpen;

  final int capacity;
  final Queue<ConsoleEntry> _entries = Queue<ConsoleEntry>();
  final StreamController<ConsoleSnapshot> _changes =
      StreamController<ConsoleSnapshot>.broadcast();

  bool _isOpen;
  bool _isFocused;
  ConsolePosition _position;
  int _sizePercent;
  int _scrollOffset = 0;

  bool get isOpen => _isOpen;

  bool get isFocused => _isFocused;

  ConsolePosition get position => _position;

  int get sizePercent => _sizePercent;

  int get scrollOffset => _scrollOffset;

  List<ConsoleEntry> get entries => List<ConsoleEntry>.unmodifiable(_entries);

  Stream<ConsoleSnapshot> get changes => _changes.stream;

  StreamSubscription<ConsoleSnapshot> addListener(
    void Function(ConsoleSnapshot snapshot) listener,
  ) {
    return changes.listen(listener);
  }

  ConsoleSnapshot get snapshot {
    return ConsoleSnapshot(
      isOpen: _isOpen,
      isFocused: _isFocused,
      position: _position,
      sizePercent: _sizePercent,
      scrollOffset: _scrollOffset,
      entries: entries,
    );
  }

  void toggle() {
    if (!_isOpen) {
      _isOpen = true;
      _isFocused = true;
      _emit();
      return;
    }
    if (!_isFocused) {
      _isFocused = true;
      _emit();
      return;
    }
    _isOpen = false;
    _isFocused = false;
    _emit();
  }

  void open({bool focus = true}) {
    _isOpen = true;
    _isFocused = focus;
    _emit();
  }

  void close() {
    _isOpen = false;
    _isFocused = false;
    _scrollOffset = 0;
    _emit();
  }

  void focus() {
    if (!_isOpen) {
      _isOpen = true;
    }
    _isFocused = true;
    _emit();
  }

  void blur() {
    _isFocused = false;
    _emit();
  }

  void setPosition(ConsolePosition position) {
    _position = position;
    _emit();
  }

  void setSizePercent(int sizePercent) {
    _sizePercent = _clampSize(sizePercent);
    _emit();
  }

  void increaseSize([int delta = 5]) {
    setSizePercent(_sizePercent + delta);
  }

  void decreaseSize([int delta = 5]) {
    setSizePercent(_sizePercent - delta);
  }

  void append(ConsoleLevel level, String message, {DateTime? timestamp}) {
    if (_entries.length >= capacity) {
      _entries.removeFirst();
      _scrollOffset = _scrollOffset > 0 ? _scrollOffset - 1 : 0;
    }
    _entries.add(
      ConsoleEntry(
        level: level,
        message: message,
        timestamp: (timestamp ?? DateTime.now()).toUtc(),
      ),
    );
    if (_scrollOffset > 0) {
      final maxOffset = _entries.length > 1 ? _entries.length - 1 : 0;
      _scrollOffset = (_scrollOffset + 1).clamp(0, maxOffset).toInt();
    }
    _emit();
  }

  void log(String message) => append(ConsoleLevel.log, message);

  void info(String message) => append(ConsoleLevel.info, message);

  void warn(String message) => append(ConsoleLevel.warn, message);

  void error(String message) => append(ConsoleLevel.error, message);

  void debug(String message) => append(ConsoleLevel.debug, message);

  void clear() {
    _entries.clear();
    _scrollOffset = 0;
    _emit();
  }

  void setScrollOffset(int offset, {int? maxOffset}) {
    final maxAllowed = _resolveMaxOffset(maxOffset);
    final next = offset.clamp(0, maxAllowed).toInt();
    if (next == _scrollOffset) {
      return;
    }
    _scrollOffset = next;
    _emit();
  }

  void scrollBy(int delta, {int? maxOffset}) {
    if (delta == 0) {
      return;
    }
    setScrollOffset(_scrollOffset + delta, maxOffset: maxOffset);
  }

  void scrollToBottom() {
    if (_scrollOffset == 0) {
      return;
    }
    _scrollOffset = 0;
    _emit();
  }

  Future<void> dispose() async {
    await _changes.close();
  }

  void _emit() {
    if (_changes.isClosed) {
      return;
    }
    _changes.add(snapshot);
  }

  static int _clampSize(int value) {
    return value.clamp(10, 100).toInt();
  }

  int _resolveMaxOffset(int? maxOffset) {
    if (maxOffset != null) {
      return math.max(0, maxOffset);
    }
    return math.max(0, _entries.length - 1);
  }
}
