import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { ArticleService, type Article } from "./article-service";

/**
 * Vitest / Jest testing framework tour.
 *
 * Covers suites, hooks, matchers, mocks, spies, fake timers,
 * snapshots, parameterised tests and async assertions.
 */

const makeArticle = (overrides: Partial<Article> = {}): Article => ({
  id: 1,
  title: "hello",
  likeCount: 0,
  tags: [],
  ...overrides, // inline comment
});

describe("ArticleService", () => {
  let service: ArticleService;
  const fetchSpy = vi.fn();

  beforeEach(() => {
    vi.useFakeTimers();
    vi.stubGlobal("fetch", fetchSpy);
    service = new ArticleService();
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
    fetchSpy.mockReset();
  });

  describe("findById", () => {
    it("returns the article when present", async () => {
      const article = makeArticle({ id: 42, title: "answer" });
      fetchSpy.mockResolvedValueOnce({ ok: true, json: async () => article });

      await expect(service.findById(42)).resolves.toEqual(article);
      expect(fetchSpy).toHaveBeenCalledOnce();
      expect(fetchSpy).toHaveBeenCalledWith("/api/articles/42", expect.any(Object));
    });

    it("throws a typed error when missing", async () => {
      fetchSpy.mockResolvedValueOnce({ ok: false, status: 404 });

      await expect(service.findById(99)).rejects.toThrowError(/not found/i);
    });

    it.each([
      [0, "empty"],
      [50, "ok"],
      [200, "busy"],
    ])("describes %i as %s", (count, expected) => {
      expect(service.describe(count, "info")).toBe(expected);
    });
  });

  it("debounces repeated calls", async () => {
    const callback = vi.fn();
    service.onChange(callback);

    service.touch();
    service.touch();
    await vi.advanceTimersByTimeAsync(300);

    expect(callback).toHaveBeenCalledTimes(1);
  });

  it("matches the serialised shape", () => {
    expect(makeArticle({ tags: ["a", "b"] })).toMatchInlineSnapshot(`
      {
        "id": 1,
        "likeCount": 0,
        "tags": [ "a", "b" ],
        "title": "hello",
      }
    `);
  });

  it.skip("is not ready yet", () => {
    expect.assertions(0);
  });
});
