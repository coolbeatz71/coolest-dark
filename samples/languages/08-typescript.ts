/**
 * TypeScript language tour.
 *
 * Covers generics, unions, mapped & conditional types, decorators,
 * async/await, destructuring and narrowing.
 */

/** Severity levels for a log line. */
export enum Severity {
  Debug = "debug",
  Info = "info",
  Warning = "warning",
  Error = "error",
}

/** A discriminated union. */
export type Outcome<T> =
  | { kind: "success"; value: T }
  | { kind: "failure"; error: Error }
  | { kind: "empty" };

/** Mapped and conditional types. */
export type Readonly2<T> = { readonly [K in keyof T]: T[K] };
export type Unwrap<T> = T extends Promise<infer U> ? U : T;

/**
 * Generic repository contract.
 * @typeParam T - the stored entity type
 * @typeParam TId - the identifier type
 * @throws {RangeError} when the limit is negative
 */
export interface Repository<T extends object, TId extends string | number> {
  findById(id: TId): Promise<T | null>;
  watchAll(options?: { limit?: number }): AsyncIterable<T>;
}

export interface LogEntry {
  readonly message: string;
  severity: Severity;
  tags?: string[];
}

export class LogRepository implements Repository<LogEntry, number> {
  readonly #store = new Map<number, LogEntry>();

  async findById(id: number): Promise<LogEntry | null> {
    await new Promise((r) => setTimeout(r, 10)); // inline comment
    return this.#store.get(id) ?? null;
  }

  async *watchAll({ limit = 20 }: { limit?: number } = {}): AsyncIterable<LogEntry> {
    let i = 0;
    for (const entry of this.#store.values()) {
      if (i++ >= limit) return;
      yield entry;
    }
  }

  /** Exhaustive narrowing over a union. */
  describe(outcome: Outcome<LogEntry>): string {
    switch (outcome.kind) {
      case "success":
        return `${outcome.value.message} (${outcome.value.tags?.length ?? 0} tags)`;
      case "failure":
        return `failing: ${outcome.error.message}`;
      case "empty":
        return "empty";
    }
  }

  recent(take: number): string[] {
    return [...this.#store.values()]
      .filter((e) => e.severity === Severity.Error)
      .map(({ message }) => message)
      .slice(0, take);
  }
}
