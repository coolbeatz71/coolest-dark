using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;

namespace FrameworkTour.AspNetCore;

/// <summary>
/// ASP.NET Core framework tour.
/// </summary>
/// <remarks>
/// Covers minimal APIs, controllers, dependency injection, EF Core,
/// model validation, middleware and configuration binding.
/// </remarks>
public static class Program
{
    public static async Task Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        builder.Services.AddDbContext<AppDbContext>(options =>
            options.UseSqlite(builder.Configuration.GetConnectionString("Default")));
        builder.Services.AddScoped<IArticleService, ArticleService>();
        builder.Services.AddEndpointsApiExplorer();

        var app = builder.Build();

        app.UseHttpsRedirection();
        app.Use(async (context, next) =>
        {
            context.Response.Headers.Append("X-Theme", "coolest-dark"); // inline comment
            await next(context);
        });

        // Minimal API endpoint with route constraints.
        app.MapGet("/api/articles/{id:int:min(1)}", async (int id, IArticleService service) =>
        {
            var article = await service.FindByIdAsync(id);
            return article is null ? Results.NotFound() : Results.Ok(article);
        })
        .WithName("GetArticle")
        .Produces<Article>(StatusCodes.Status200OK);

        await app.RunAsync();
    }
}

/// <summary>A validated request payload.</summary>
public sealed record CreateArticleRequest
{
    [Required, StringLength(200, MinimumLength = 1)]
    public required string Title { get; init; }

    [Range(0, int.MaxValue)]
    public int LikeCount { get; init; }
}

public sealed class Article
{
    public int Id { get; set; }
    public required string Title { get; set; }
    public int LikeCount { get; set; }
}

public interface IArticleService
{
    /// <summary>Finds one article.</summary>
    /// <param name="id">The identifier to look up.</param>
    /// <returns>The article, or <see langword="null"/>.</returns>
    Task<Article?> FindByIdAsync(int id, CancellationToken cancellationToken = default);
}

public sealed class ArticleService(AppDbContext db) : IArticleService
{
    public Task<Article?> FindByIdAsync(int id, CancellationToken cancellationToken = default) =>
        db.Articles.AsNoTracking().FirstOrDefaultAsync(a => a.Id == id, cancellationToken);
}

public sealed class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    public DbSet<Article> Articles => Set<Article>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Article>(entity =>
        {
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Title).HasMaxLength(200).IsRequired();
            entity.HasIndex(e => e.LikeCount).IsDescending();
        });
    }
}

[ApiController]
[Route("api/[controller]")]
public sealed class ArticlesController(IArticleService service) : ControllerBase
{
    [HttpGet("{id:int}")]
    [ProducesResponseType(StatusCodes.Status404NotFound)]
    public async Task<ActionResult<Article>> Get(int id, CancellationToken cancellationToken)
    {
        var article = await service.FindByIdAsync(id, cancellationToken);
        return article is null ? NotFound() : Ok(article);
    }
}
