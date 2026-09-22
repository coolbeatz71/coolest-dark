using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace LanguageTour.CSharp;

/// <summary>
/// Severity levels for a log line.
/// </summary>
public enum Severity { Debug, Info, Warning, Error }

/// <summary>
/// Generic repository contract.
/// </summary>
/// <typeparam name="T">The stored entity type.</typeparam>
/// <typeparam name="TId">The identifier type.</typeparam>
public interface IRepository<T, TId> where T : class
{
    /// <summary>Finds one entity.</summary>
    /// <param name="id">The identifier to look up.</param>
    /// <returns>The entity, or <see langword="null"/>.</returns>
    /// <exception cref="InvalidOperationException">Thrown when disposed.</exception>
    Task<T?> FindByIdAsync(TId id, CancellationToken cancellationToken = default);
}

/// <summary>An immutable record with positional parameters.</summary>
public record LogEntry(string Message, Severity Severity = Severity.Info)
{
    public IReadOnlyList<string> Tags { get; init; } = Array.Empty<string>();
    public override string ToString() => $"[{Severity}] {Message} ({Tags.Count} tags)";
}

public sealed class LogRepository : IRepository<LogEntry, int>, IDisposable
{
    private readonly Dictionary<int, LogEntry> _store = new();
    private bool _disposed;

    public async Task<LogEntry?> FindByIdAsync(int id, CancellationToken cancellationToken = default)
    {
        await Task.Delay(10, cancellationToken); // inline comment
        return _store.TryGetValue(id, out var entry) ? entry : null;
    }

    /// <summary>Pattern matching with switch expressions.</summary>
    public string Describe(int count, Severity severity) => (count, severity) switch
    {
        (0, _) => "empty",
        (_, Severity.Error) => "failing",
        ( > 100, _) => "busy",
        _ => "ok",
    };

    public IEnumerable<LogEntry> Recent(int take) =>
        _store.Values.Where(e => e.Severity >= Severity.Warning)
                     .OrderByDescending(e => e.Message)
                     .Take(take);

    public void Dispose() => _disposed = true;
}
