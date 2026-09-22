import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Suspense, cache } from "react";

/**
 * Next.js App Router tour.
 *
 * Covers server components, metadata, dynamic params, streaming,
 * server actions, caching and route segment config.
 */

export const dynamic = "force-dynamic";
export const revalidate = 60;

interface PageProps {
  params: Promise<{ slug: string }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
}

/** Generates per-route metadata. */
export async function generateMetadata({ params }: PageProps): Promise<Metadata> {
  const { slug } = await params;
  return {
    title: `Article — ${slug}`,
    openGraph: { title: slug, type: "article" },
  };
}

/** Pre-renders known routes at build time. */
export async function generateStaticParams(): Promise<Array<{ slug: string }>> {
  const res = await fetch("https://api.example.com/articles", { next: { revalidate: 3600 } });
  const articles: Array<{ slug: string }> = await res.json();
  return articles.map(({ slug }) => ({ slug }));
}

const getArticle = cache(async (slug: string) => {
  const res = await fetch(`https://api.example.com/articles/${slug}`, {
    headers: { Accept: "application/json" },
    next: { tags: [`article:${slug}`] },
  });
  if (!res.ok) return null; // inline comment
  return res.json();
});

/** Server action — runs on the server when the form is submitted. */
async function likeArticle(formData: FormData): Promise<void> {
  "use server";
  const id = formData.get("id");
  await fetch(`https://api.example.com/articles/${id}/like`, { method: "POST" });
}

export default async function ArticlePage({ params, searchParams }: PageProps) {
  const { slug } = await params;
  const { ref } = await searchParams;

  const article = await getArticle(slug);
  if (!article) notFound();

  return (
    <main className="prose">
      <h1>{article.title}</h1>
      {ref && <p className="ref">Referred by {ref}</p>}

      <Suspense fallback={<p>Loading comments…</p>}>
        {/* @ts-expect-error async server component */}
        <Comments slug={slug} />
      </Suspense>

      <form action={likeArticle}>
        <input type="hidden" name="id" value={article.id} />
        <button type="submit">Like ({article.likeCount})</button>
      </form>
    </main>
  );
}

declare function Comments(props: { slug: string }): Promise<JSX.Element>;
