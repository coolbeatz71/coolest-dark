/**
 * JavaScript language tour.
 *
 * Covers classes, private fields, generators, destructuring,
 * optional chaining, async iteration, proxies and symbols.
 */

/** @readonly @enum {string} */
export const Severity = Object.freeze({
  Debug: "debug",
  Info: "info",
  Warning: "warning",
  Error: "error",
});

/**
 * An in-memory log repository.
 *
 * @param {Map<number, object>} [initial] - seed entries
 * @throws {TypeError} when initial is not a Map
 */
export class LogRepository {
  /** @type {Map<number, object>} */
  #store = new Map();
  static #instances = 0;

  constructor(initial) {
    if (initial && !(initial instanceof Map)) throw new TypeError("Map required");
    this.#store = initial ?? new Map();
    LogRepository.#instances += 1; // inline comment
  }

  get size() {
    return this.#store.size;
  }

  async findById(id) {
    await new Promise((resolve) => setTimeout(resolve, 10));
    return this.#store.get(id) ?? null;
  }

  *entries() {
    yield* this.#store.values();
  }

  async *watchAll({ limit = 20 } = {}) {
    let i = 0;
    for (const entry of this.#store.values()) {
      if (i++ >= limit) return;
      yield entry;
    }
  }

  describe({ kind, value, error } = {}) {
    switch (kind) {
      case "success":
        return `${value?.message} (${value?.tags?.length ?? 0} tags)`;
      case "failure":
        return `failing: ${error?.message ?? "unknown"}`;
      default:
        return "empty";
    }
  }

  recent(take) {
    return [...this.#store.values()]
      .filter((e) => e.severity === Severity.Error)
      .map(({ message }) => message)
      .slice(0, take);
  }
}

const handler = { get: (target, prop) => Reflect.get(target, prop) };
export const proxied = new Proxy(new LogRepository(), handler);
