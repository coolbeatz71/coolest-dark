package languagetour.groovy

import groovy.transform.Immutable
import groovy.transform.CompileStatic

/**
 * Severity levels for a log line.
 */
enum Severity { DEBUG, INFO, WARNING, ERROR }

/**
 * Generic repository contract.
 *
 * @param < T >  the stored entity type
 * @param < ID > the identifier type
 * @throws IllegalStateException when the repository is closed
 */
interface Repository<T, ID> {
    T findById(ID id)
}

/** An immutable value type. */
@Immutable
class LogEntry {
    String message
    Severity severity = Severity.INFO
    List<String> tags = []

    String toString() { "[$severity] $message (${tags.size()} tags)" }
}

@CompileStatic
class LogRepository implements Repository<LogEntry, Integer> {
    private final Map<Integer, LogEntry> store = [:]

    @Override
    LogEntry findById(Integer id) {
        store[id] // inline comment
    }

    /** Closures, the spread operator and GStrings. */
    List<String> recent(int take) {
        store.values()
             .findAll { LogEntry e -> e.severity >= Severity.WARNING }
             .collect { LogEntry e -> e.message }
             .take(take)
    }

    String describe(int count, Severity severity) {
        switch (severity) {
            case Severity.ERROR: return 'failing'
            case Severity.WARNING: return count > 100 ? 'busy' : 'ok'
            default: return count == 0 ? 'empty' : 'ok'
        }
    }
}
