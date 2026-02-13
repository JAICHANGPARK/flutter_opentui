import 'dart:collection';

final class ConsoleEntry {
  const ConsoleEntry({
    required this.level,
    required this.message,
    required this.timestamp,
  });

  final String level;
  final String message;
  final DateTime timestamp;
}

final class OpenTuiConsole {
  OpenTuiConsole({this.capacity = 500});

  final int capacity;
  final Queue<ConsoleEntry> _entries = Queue<ConsoleEntry>();

  List<ConsoleEntry> get entries => List<ConsoleEntry>.unmodifiable(_entries);

  void log(String message) => _append('log', message);

  void info(String message) => _append('info', message);

  void warn(String message) => _append('warn', message);

  void error(String message) => _append('error', message);

  void clear() {
    _entries.clear();
  }

  void _append(String level, String message) {
    if (_entries.length >= capacity) {
      _entries.removeFirst();
    }
    _entries.add(
      ConsoleEntry(
        level: level,
        message: message,
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }
}

final OpenTuiConsole console = OpenTuiConsole();
