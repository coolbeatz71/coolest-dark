<?php

declare(strict_types=1);

namespace LanguageTour\Php;

use InvalidArgumentException;
use JsonSerializable;

/**
 * Severity levels for a log line.
 */
enum Severity: string
{
    case Debug = 'debug';
    case Info = 'info';
    case Warning = 'warning';
    case Error = 'error';

    public function isSevere(): bool
    {
        return match ($this) {
            self::Error, self::Warning => true,
            default => false,
        };
    }
}

/**
 * Generic repository contract.
 *
 * @template T of object
 * @template TId of int|string
 */
interface Repository
{
    /**
     * Finds one entity by id.
     *
     * @param  TId $id the identifier to look up
     * @return T|null the entity, or null
     * @throws InvalidArgumentException when the id is negative
     */
    public function findById(int|string $id): ?object;
}

/** An immutable value type. */
final readonly class LogEntry implements JsonSerializable
{
    /** @param list<string> $tags */
    public function __construct(
        public string $message,
        public Severity $severity = Severity::Info,
        public array $tags = [],
    ) {
    }

    public function __toString(): string
    {
        return sprintf('[%s] %s (%d tags)', $this->severity->value, $this->message, count($this->tags));
    }

    public function jsonSerialize(): array
    {
        return ['message' => $this->message, 'severity' => $this->severity];
    }
}

final class LogRepository implements Repository
{
    /** @var array<int, LogEntry> */
    private array $store = [];

    public function findById(int|string $id): ?LogEntry
    {
        if (is_int($id) && $id < 0) {
            throw new InvalidArgumentException("negative id: {$id}");
        }

        return $this->store[$id] ?? null; // inline comment
    }

    /** @return list<string> */
    public function recent(int $take): array
    {
        $severe = array_filter($this->store, static fn (LogEntry $e): bool => $e->severity->isSevere());

        return array_slice(array_map(static fn (LogEntry $e): string => $e->message, $severe), 0, $take);
    }
}
