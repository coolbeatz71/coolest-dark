/**
 * AssemblyScript framework tour (compiles to WebAssembly).
 *
 * Covers the strict type system, integer/float primitives, decorators,
 * memory management, static arrays, typed arrays and host bindings.
 */

// Host imports — provided by the JavaScript embedder.
@external("env", "log")
declare function log(ptr: usize, len: i32): void;

@external("env", "now")
declare function now(): f64;

/** Severity levels for a log line. */
export enum Severity {
  Debug = 1,
  Info = 2,
  Warning = 3,
  Error = 4,
}

/** Compile-time constant, inlined at every call site. */
// @ts-ignore: decorator
@inline
const MAX_ENTRIES: i32 = 1024;

/** An immutable value type laid out in linear memory. */
export class LogEntry {
  constructor(
    public message: string,
    public severity: Severity = Severity.Info,
    public likeCount: u32 = 0,
  ) {}

  @operator("==")
  static equals(a: LogEntry, b: LogEntry): bool {
    return a.message == b.message && a.severity == b.severity;
  }

  toString(): string {
    return `[${this.severity}] ${this.message} (${this.likeCount})`;
  }
}

/** A fixed-capacity repository backed by a StaticArray. */
export class LogRepository {
  private entries: StaticArray<LogEntry | null> = new StaticArray<LogEntry | null>(MAX_ENTRIES);
  private count: i32 = 0;

  /**
   * Appends an entry.
   * @returns the new count, or -1 when full
   */
  add(entry: LogEntry): i32 {
    if (this.count >= MAX_ENTRIES) return -1; // inline comment
    this.entries[this.count] = entry;
    return ++this.count;
  }

  findById(id: i32): LogEntry | null {
    if (id < 0 || id >= this.count) return null;
    return this.entries[id];
  }

  /** Counts severe entries with an explicit integer loop. */
  countSevere(): i32 {
    let total: i32 = 0;
    for (let i: i32 = 0; i < this.count; i++) {
      const entry = this.entries[i];
      if (entry !== null && entry.severity >= Severity.Warning) {
        total++;
      }
    }
    return total;
  }
}

/** Exported to the host as a plain WebAssembly function. */
export function describe(count: i32, severity: Severity): i32 {
  if (count == 0) return 8; // "empty"

  switch (severity) {
    case Severity.Error:
      return 14; // "failing"
    default:
      return count > 100 ? 3 : 0;
  }
}

/** Typed array maths — compiles to tight SIMD-friendly loops. */
export function sumLikes(values: Int32Array): i64 {
  let total: i64 = 0;
  for (let i: i32 = 0, len = values.length; i < len; i++) {
    total += <i64>unchecked(values[i]);
  }
  return total;
}

export function allocate(size: i32): usize {
  return heap.alloc(size);
}

export function release(ptr: usize): void {
  heap.free(ptr);
}
