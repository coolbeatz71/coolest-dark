"""FastAPI framework tour.

Covers routers, dependency injection, Pydantic models, async handlers,
background tasks, middleware, exception handlers and OpenAPI metadata.
"""

from __future__ import annotations

from contextlib import asynccontextmanager
from typing import Annotated, AsyncIterator

from fastapi import BackgroundTasks, Depends, FastAPI, HTTPException, Query, status
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field, field_validator


class ArticleIn(BaseModel):
    """Request payload for creating an article."""

    title: str = Field(..., min_length=1, max_length=200, description="The headline")
    like_count: int = Field(default=0, ge=0)
    tags: list[str] = Field(default_factory=list)

    @field_validator("title")
    @classmethod
    def strip_title(cls, value: str) -> str:
        return value.strip()  # inline comment


class ArticleOut(ArticleIn):
    """Response payload, adding the server-assigned id."""

    id: int

    model_config = {"json_schema_extra": {"examples": [{"id": 1, "title": "Hello"}]}}


class ArticleStore:
    def __init__(self) -> None:
        self._store: dict[int, ArticleOut] = {}

    async def find_by_id(self, article_id: int) -> ArticleOut | None:
        return self._store.get(article_id)

    async def create(self, payload: ArticleIn) -> ArticleOut:
        article_id = len(self._store) + 1
        article = ArticleOut(id=article_id, **payload.model_dump())
        self._store[article_id] = article
        return article


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncIterator[None]:
    """Startup and shutdown hooks."""
    app.state.store = ArticleStore()
    yield
    app.state.store = None


app = FastAPI(title="Coolest Dark API", version="0.1.0", lifespan=lifespan)


def get_store() -> ArticleStore:
    """Dependency provider."""
    return app.state.store


StoreDep = Annotated[ArticleStore, Depends(get_store)]


@app.get("/articles/{article_id}", response_model=ArticleOut, tags=["articles"])
async def read_article(article_id: int, store: StoreDep) -> ArticleOut:
    """Fetch one article.

    Args:
        article_id: the identifier to look up.

    Raises:
        HTTPException: 404 when nothing matches.
    """
    article = await store.find_by_id(article_id)
    if article is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="not found")
    return article


@app.post("/articles", response_model=ArticleOut, status_code=status.HTTP_201_CREATED)
async def create_article(
    payload: ArticleIn,
    store: StoreDep,
    background: BackgroundTasks,
    notify: Annotated[bool, Query(description="Send a notification")] = False,
) -> ArticleOut:
    article = await store.create(payload)
    if notify:
        background.add_task(print, f"created {article.id}")
    return article


@app.exception_handler(ValueError)
async def value_error_handler(request, exc: ValueError) -> JSONResponse:
    return JSONResponse(status_code=422, content={"detail": str(exc)})
