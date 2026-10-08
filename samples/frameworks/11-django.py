"""Django framework tour.

Covers models, managers, querysets, admin, forms, class-based views,
signals, URL routing and the ORM.
"""

from django.contrib import admin
from django.core.exceptions import ValidationError
from django.db import models
from django.db.models import Count, F, Q
from django.urls import path
from django.views.generic import DetailView, ListView


class ArticleQuerySet(models.QuerySet):
    """Custom queryset with reusable filters."""

    def published(self):
        return self.filter(is_published=True)

    def popular(self, minimum: int = 10):
        return self.annotate(total=Count("comments")).filter(
            Q(like_count__gte=minimum) | Q(total__gte=minimum)
        )


class Article(models.Model):
    """A published article.

    Attributes:
        title: the headline shown in listings.
        slug: URL-safe identifier.
        like_count: denormalised counter.
    """

    class Severity(models.TextChoices):
        DEBUG = "debug", "Debug"
        INFO = "info", "Info"
        ERROR = "error", "Error"

    title = models.CharField(max_length=200, db_index=True)
    slug = models.SlugField(unique=True)
    body = models.TextField(blank=True)
    severity = models.CharField(max_length=16, choices=Severity.choices, default=Severity.INFO)
    like_count = models.PositiveIntegerField(default=0)
    author = models.ForeignKey("auth.User", on_delete=models.CASCADE, related_name="articles")
    created_at = models.DateTimeField(auto_now_add=True)

    objects = ArticleQuerySet.as_manager()

    class Meta:
        ordering = ["-created_at"]
        indexes = [models.Index(fields=["severity", "-created_at"])]
        constraints = [
            models.CheckConstraint(check=models.Q(like_count__gte=0), name="like_count_positive")
        ]

    def __str__(self) -> str:
        return f"{self.title} ({self.severity})"

    def clean(self) -> None:
        if not self.title.strip():  # inline comment
            raise ValidationError({"title": "Title is required."})

    def increment_likes(self) -> None:
        Article.objects.filter(pk=self.pk).update(like_count=F("like_count") + 1)


@admin.register(Article)
class ArticleAdmin(admin.ModelAdmin):
    list_display = ("title", "severity", "like_count", "created_at")
    list_filter = ("severity", "created_at")
    search_fields = ("title", "body")
    prepopulated_fields = {"slug": ("title",)}
    readonly_fields = ("created_at",)


class ArticleListView(ListView):
    model = Article
    paginate_by = 20
    context_object_name = "articles"

    def get_queryset(self):
        return Article.objects.published().select_related("author").prefetch_related("comments")


urlpatterns = [
    path("articles/", ArticleListView.as_view(), name="article-list"),
    path("articles/<slug:slug>/", DetailView.as_view(model=Article), name="article-detail"),
]
