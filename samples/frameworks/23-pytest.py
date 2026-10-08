"""pytest framework tour.

Covers fixtures, parametrisation, markers, monkeypatching,
async tests, exception assertions and conftest-style setup.
"""

from __future__ import annotations

import asyncio
from dataclasses import dataclass
from typing import Iterator

import pytest


@dataclass(frozen=True)
class Article:
    """Minimal domain object under test."""

    id: int
    title: str
    like_count: int = 0


class ArticleService:
    """System under test."""

    def __init__(self) -> None:
        self._store: dict[int, Article] = {}

    def add(self, article: Article) -> None:
        self._store[article.id] = article  # inline comment

    def find_by_id(self, article_id: int) -> Article:
        try:
            return self._store[article_id]
        except KeyError as exc:
            raise LookupError(f"article {article_id} not found") from exc

    def describe(self, count: int, severity: str) -> str:
        if count == 0:
            return "empty"
        if severity == "error":
            return "failing"
        return "busy" if count > 100 else "ok"

    async def fetch(self, article_id: int) -> Article:
        await asyncio.sleep(0.01)
        return self.find_by_id(article_id)


@pytest.fixture(scope="function")
def service() -> Iterator[ArticleService]:
    """Provides a fresh service per test."""
    svc = ArticleService()
    svc.add(Article(id=1, title="hello"))
    yield svc
    # teardown runs after the test
    svc._store.clear()


@pytest.fixture(autouse=True)
def _no_network(monkeypatch: pytest.MonkeyPatch) -> None:
    """Fails loudly if a test tries real I/O."""
    monkeypatch.delenv("HTTP_PROXY", raising=False)


class TestFindById:
    def test_returns_known_article(self, service: ArticleService) -> None:
        assert service.find_by_id(1).title == "hello"

    def test_raises_for_missing(self, service: ArticleService) -> None:
        with pytest.raises(LookupError, match=r"article 99 not found"):
            service.find_by_id(99)


@pytest.mark.parametrize(
    ("count", "severity", "expected"),
    [
        (0, "info", "empty"),
        (5, "error", "failing"),
        (200, "info", "busy"),
        pytest.param(50, "info", "ok", id="ordinary"),
    ],
)
def test_describe(service: ArticleService, count: int, severity: str, expected: str) -> None:
    assert service.describe(count, severity) == expected


@pytest.mark.asyncio
async def test_fetch_is_awaitable(service: ArticleService) -> None:
    article = await service.fetch(1)
    assert article == Article(id=1, title="hello")


@pytest.mark.slow
@pytest.mark.skipif(not hasattr(asyncio, "TaskGroup"), reason="needs 3.11+")
def test_marked_slow() -> None:
    assert True


@pytest.mark.xfail(reason="known bug", strict=False)
def test_known_failure() -> None:
    assert 1 == 2
