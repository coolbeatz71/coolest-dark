import Foundation

/// Severity levels for a log line.
enum Severity: Int, CaseIterable, Comparable {
    case debug, info, warning, error
    static func < (lhs: Severity, rhs: Severity) -> Bool { lhs.rawValue < rhs.rawValue }
}

/// Generic repository contract.
///
/// - Parameters:
///   - id: the identifier to look up
/// - Returns: the entity, or `nil`
/// - Throws: ``RepositoryError`` when the repository is closed
protocol Repository {
    associatedtype Entity
    associatedtype ID: Hashable

    func findById(_ id: ID) async throws -> Entity?
}

/// An immutable value type.
struct LogEntry: Equatable, Sendable, CustomStringConvertible {
    let message: String
    var severity: Severity = .info
    var tags: [String] = []

    var description: String { "[\(severity)] \(message) (\(tags.count) tags)" }
}

enum RepositoryError: Error { case closed, notFound(id: Int) }

final class LogRepository: Repository {
    private var store: [Int: LogEntry] = [:]

    func findById(_ id: Int) async throws -> LogEntry? {
        try await Task.sleep(nanoseconds: 10_000_000) // inline comment
        guard let entry = store[id] else { throw RepositoryError.notFound(id: id) }
        return entry
    }

    /// Pattern matching with associated values.
    func describe(_ result: Result<LogEntry, RepositoryError>) -> String {
        switch result {
        case .success(let entry) where entry.severity == .error:
            return "failing"
        case .success(let entry):
            return entry.message
        case .failure(.notFound(let id)):
            return "missing \(id)"
        case .failure:
            return "closed"
        }
    }

    func recent(take: Int) -> [String] {
        store.values
            .filter { $0.severity >= .warning }
            .map(\.message)
            .prefix(take)
            .map { $0 }
    }
}
