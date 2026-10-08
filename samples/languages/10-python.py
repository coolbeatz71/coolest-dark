"""Python language tour.

Covers dataclasses, protocols, generics, enums, decorators,
context managers, async/await, comprehensions and pattern matching.
"""

from __future__ import annotations

import asyncio
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from enum import Enum, auto
from functools import wraps
from typing import AsyncIterator, Generic, Protocol, TypeVar

T = TypeVar("T")
TId = TypeVar("TId", bound=int | str)


class Severity(Enum):
    """Severity levels for a log line."""

    DEBUG = auto()
    INFO = auto()
    WARNING = auto()
    ERROR = auto()


@dataclass(frozen=True, slots=True)
class LogEntry:
    """An immutable value type.

    Attributes:
        message: the human readable text
        severity: how serious the line is
        tags: optional labels
    """

    message: str
    severity: Severity = Severity.INFO
    tags: list[str] = field(default_factory=list)

    def __str__(self) -> str:  # inline comment
        return f"[{self.severity.name}] {self.message} ({len(self.tags)} tags)"


class Repository(Protocol, Generic[T, TId]):
    """Generic repository contract.

    Raises:
        KeyError: when no entity matches the id.
    """

    async def find_by_id(self, id: TId) -> T | None: ...


def retry(times: int = 3):
    """Decorator factory that retries a coroutine."""

    def decorator(fn):
        @wraps(fn)
        async def wrapper(*args, **kwargs):
            for attempt in range(times):
                try:
                    return await fn(*args, **kwargs)
                except (KeyError, ValueError) as exc:
                    if attempt == times - 1:
                        raise RuntimeError("giving up") from exc
        return wrapper

    return decorator


class LogRepository:
    def __init__(self) -> None:
        self._store: dict[int, LogEntry] = {}

    @retry(times=2)
    async def find_by_id(self, id: int) -> LogEntry | None:
        await asyncio.sleep(0.01)
        return self._store.get(id)

    @asynccontextmanager
    async def session(self) -> AsyncIterator["LogRepository"]:
        try:
            yield self
        finally:
            self._store.clear()

    def describe(self, outcome: tuple[int, Severity]) -> str:
        match outcome:
            case (0, _):
                return "empty"
            case (_, Severity.ERROR):
                return "failing"
            case (n, _) if n > 100:
                return "busy"
            case _:
                return "ok"

    def recent(self, take: int) -> list[str]:
        return [e.message for e in self._store.values() if e.severity is Severity.ERROR][:take]
