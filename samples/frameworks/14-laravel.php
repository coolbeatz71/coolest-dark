<?php

declare(strict_types=1);

namespace App\Http\Controllers;

use App\Models\Article;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Str;

/**
 * Laravel framework tour.
 *
 * Covers Eloquent models, relationships, scopes, accessors,
 * form requests, resource controllers, middleware and caching.
 */
final class StoreArticleRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('create', Article::class) ?? false;
    }

    /**
     * Validation rules.
     *
     * @return array<string, array<int, string>>
     */
    public function rules(): array
    {
        return [
            'title' => ['required', 'string', 'min:1', 'max:200'],
            'severity' => ['required', 'in:debug,info,warning,error'],
            'like_count' => ['sometimes', 'integer', 'min:0'],
            'tags' => ['array'],
            'tags.*' => ['string', 'distinct'],
        ];
    }

    /** @return array<string, string> */
    public function messages(): array
    {
        return ['title.required' => 'A headline is required.'];
    }
}

final class ArticleController extends Controller
{
    public function __construct()
    {
        $this->middleware(['auth:sanctum', 'throttle:60,1'])->except(['index', 'show']);
    }

    /** Lists published articles. */
    public function index(Request $request): JsonResponse
    {
        $limit = (int) $request->query('limit', '20');

        $articles = Cache::remember("articles:{$limit}", now()->addMinutes(5), static fn () =>
            Article::query()
                ->published()
                ->with(['author:id,name', 'tags:id,name'])
                ->withCount('comments')
                ->orderByDesc('created_at')
                ->limit($limit)
                ->get()
        );

        return response()->json(['data' => $articles], 200);
    }

    public function store(StoreArticleRequest $request): JsonResponse
    {
        $article = Article::create([
            ...$request->validated(),
            'slug' => Str::slug($request->string('title')->toString()), // inline comment
        ]);

        $article->tags()->sync($request->input('tags', []));

        return response()->json($article->fresh(), 201);
    }

    public function show(Article $article): JsonResponse
    {
        abort_if($article->trashed(), 404, 'Article not found.');

        return response()->json($article->loadMissing('author'));
    }
}
