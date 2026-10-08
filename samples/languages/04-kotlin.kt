package languagetour.kotlin

import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.flow

/**
 * Severity levels for a log line.
 */
enum class Severity { DEBUG, INFO, WARNING, ERROR }

/**
 * Generic repository contract.
 *
 * @param T the stored entity type
 * @param ID the identifier type
 * @throws IllegalStateException when the repository is closed
 */
interface Repository<T : Any, ID> {
    suspend fun findById(id: ID): T?
    fun watchAll(limit: Int = 20): Flow<T>
}

/** An immutable data class with default arguments. */
data class LogEntry(
    val message: String,
    val severity: Severity = Severity.INFO,
    val tags: List<String> = emptyList(),
) {
    override fun toString(): String = "[$severity] $message (${tags.size} tags)"
}

/** Sealed hierarchy for exhaustive matching. */
sealed interface Outcome {
    data class Success(val entry: LogEntry) : Outcome
    data class Failure(val cause: Throwable) : Outcome
    object Empty : Outcome
}

/** Extension property on a built-in type. */
val String.shout: String get() = "${uppercase()}!"

class LogRepository : Repository<LogEntry, Int> {
    private val store = mutableMapOf<Int, LogEntry>()

    override suspend fun findById(id: Int): LogEntry? {
        delay(10) // inline comment
        return store[id]
    }

    override fun watchAll(limit: Int): Flow<LogEntry> = flow {
        store.values.take(limit).forEach { emit(it) }
    }

    fun describe(outcome: Outcome): String = when (outcome) {
        is Outcome.Success -> outcome.entry.message
        is Outcome.Failure -> "failing".shout
        Outcome.Empty -> "empty"
    }

    fun recent(take: Int): List<String> = store.values
        .filter { it.severity >= Severity.WARNING }
        .map { it.message }
        .take(take)
}
