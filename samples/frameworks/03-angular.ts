import { CommonModule } from "@angular/common";
import {
  ChangeDetectionStrategy,
  Component,
  computed,
  inject,
  input,
  output,
  signal,
} from "@angular/core";
import { HttpClient } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable, catchError, map, of, shareReplay } from "rxjs";

/**
 * Angular framework tour.
 *
 * Covers standalone components, signals, dependency injection,
 * RxJS pipelines, decorators and template syntax.
 */

export interface Article {
  id: string;
  title: string;
  likeCount: number;
}

/** Injectable data service. */
@Injectable({ providedIn: "root" })
export class ArticleService {
  private readonly http = inject(HttpClient);

  /**
   * Loads all articles.
   * @throws HttpErrorResponse when the request fails
   */
  findAll(limit = 20): Observable<Article[]> {
    return this.http
      .get<Article[]>("/api/articles", { params: { limit } })
      .pipe(
        map((articles) => articles.slice(0, limit)), // inline comment
        catchError(() => of([])),
        shareReplay({ bufferSize: 1, refCount: true }),
      );
  }
}

@Component({
  selector: "app-article-card",
  standalone: true,
  imports: [CommonModule],
  changeDetection: ChangeDetectionStrategy.OnPush,
  styles: [
    `
      :host {
        display: block;
      }
      .card--selected {
        outline: 2px solid var(--accent);
      }
    `,
  ],
  template: `
    <article
      class="card"
      [class.card--selected]="isSelected()"
      [attr.data-id]="article().id"
      (click)="select.emit(article().id)"
    >
      <h2>{{ article().title | uppercase }}</h2>

      @if (likeLabel(); as label) {
        <span class="likes">{{ label }}</span>
      } @else {
        <span class="likes likes--empty">No likes yet</span>
      }

      @for (tag of tags(); track tag) {
        <span class="tag">{{ tag }}</span>
      }
    </article>
  `,
})
export class ArticleCardComponent {
  readonly article = input.required<Article>();
  readonly tags = input<string[]>([]);
  readonly select = output<string>();

  private readonly selectedId = signal<string | null>(null);

  readonly isSelected = computed(() => this.selectedId() === this.article().id);
  readonly likeLabel = computed(() => {
    const count = this.article().likeCount;
    return count > 0 ? `${count} likes` : null;
  });
}
