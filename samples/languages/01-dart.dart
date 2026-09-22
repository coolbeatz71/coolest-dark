/// # Dart language tour
///
/// Covers: imports, doc comments, enums, mixins, generics, named args,
/// null safety, async/await, records, pattern matching, extensions.
///
/// * [Severity]  - the enum used for levels
/// * Throws [StateError] when the handler is reused.
library dart_tour;

import 'dart:async';
import 'dart:math' as math;

/// Severity levels for a log line.
enum Severity { debug, info, warning, error }

/// A mixin contributing timestamp behaviour.
mixin Timestamped {
  DateTime get createdAt => DateTime.now();
}

/// Generic repository contract.
abstract class Repository<T extends Object, ID> {
  Future<T?> findById(ID id);
  Stream<T> watchAll({int limit = 20});
}

/// Immutable value type with named + optional parameters.
class LogEntry with Timestamped {
  const LogEntry({
    required this.message,
    this.severity = Severity.info,
    this.tags = const <String>[],
  });

  final String message;
  final Severity severity;
  final List<String> tags;

  // Operator overloading and string interpolation.
  @override
  String toString() => '[${severity.name}] $message (${tags.length} tags)';
}

/// Extension method on a built-in type.
extension on String {
  String get shout => '${toUpperCase()}!';
}

class LogRepository implements Repository<LogEntry, int> {
  final Map<int, LogEntry> _store = <int, LogEntry>{};

  @override
  Future<LogEntry?> findById(int id) async {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return _store[id]; // null-aware return
  }

  @override
  Stream<LogEntry> watchAll({int limit = 20}) async* {
    for (final entry in _store.values.take(limit)) {
      yield entry;
    }
  }

  /// Pattern matching over a record.
  String describe((int, Severity) pair) => switch (pair) {
        (0, _) => 'empty',
        (_, Severity.error) => 'failing'.shout,
        (final n, _) when n > 100 => 'busy',
        _ => 'ok',
      };
}

Future<void> main() async {
  final repo = LogRepository();
  const entry = LogEntry(message: 'hello', severity: Severity.warning);

  try {
    final found = await repo.findById(1) ?? entry;
    print('${found.message} ${math.max(1, 2)}');
  } on StateError catch (e, stack) {
    print('failed: $e\n$stack');
  } finally {
    print(repo.describe((0, Severity.debug)));
  }
}
