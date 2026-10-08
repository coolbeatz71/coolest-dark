package languagetour.java;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.CompletableFuture;
import java.util.stream.Collectors;

/**
 * Severity levels for a log line.
 */
enum Severity { DEBUG, INFO, WARNING, ERROR }

/**
 * Generic repository contract.
 *
 * @param <T>  the stored entity type
 * @param <ID> the identifier type
 * @see LogRepository
 */
interface Repository<T, ID> {
    /**
     * Finds one entity by id.
     *
     * @param id the identifier to look up
     * @return a future of the entity, possibly empty
     * @throws IllegalStateException when the repository is closed
     */
    CompletableFuture<Optional<T>> findById(ID id);
}

/** An immutable record. */
record LogEntry(String message, Severity severity, List<String> tags) {
    LogEntry {
        if (message == null) throw new IllegalArgumentException("message required");
    }

    @Override
    public String toString() {
        return "[%s] %s (%d tags)".formatted(severity, message, tags.size());
    }
}

public final class LogRepository implements Repository<LogEntry, Integer> {
    private final Map<Integer, LogEntry> store = new java.util.HashMap<>();

    @Override
    public CompletableFuture<Optional<LogEntry>> findById(Integer id) {
        // inline comment
        return CompletableFuture.supplyAsync(() -> Optional.ofNullable(store.get(id)));
    }

    /** Switch expression with pattern matching. */
    String describe(int count, Severity severity) {
        return switch (severity) {
            case ERROR -> "failing";
            case WARNING, INFO -> count > 100 ? "busy" : "ok";
            default -> "empty";
        };
    }

    List<String> recentMessages(int take) {
        return store.values().stream()
                .filter(e -> e.severity().ordinal() >= Severity.WARNING.ordinal())
                .map(LogEntry::message)
                .limit(take)
                .collect(Collectors.toList());
    }
}
