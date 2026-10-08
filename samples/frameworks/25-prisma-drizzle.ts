import { and, desc, eq, gte, sql } from "drizzle-orm";
import { drizzle } from "drizzle-orm/node-postgres";
import {
  boolean,
  index,
  integer,
  pgEnum,
  pgTable,
  primaryKey,
  serial,
  text,
  timestamp,
  uniqueIndex,
  varchar,
} from "drizzle-orm/pg-core";

/**
 * ORM framework tour (Drizzle).
 *
 * Covers schema definition, enums, relations, indexes, migrations,
 * typed queries, joins, aggregates and transactions.
 */

export const severityEnum = pgEnum("severity", ["debug", "info", "warning", "error"]);

/** The authors table. */
export const authors = pgTable("authors", {
  id: serial("id").primaryKey(),
  displayName: varchar("display_name", { length: 120 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  emailIdx: uniqueIndex("authors_email_idx").on(table.email),
}));

/** The articles table. */
export const articles = pgTable("articles", {
  id: serial("id").primaryKey(),
  title: varchar("title", { length: 200 }).notNull(),
  slug: varchar("slug", { length: 220 }).notNull(),
  body: text("body"),
  severity: severityEnum("severity").default("info").notNull(),
  likeCount: integer("like_count").default(0).notNull(),
  isPublished: boolean("is_published").default(false).notNull(),
  authorId: integer("author_id").references(() => authors.id, { onDelete: "cascade" }).notNull(),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => ({
  slugIdx: uniqueIndex("articles_slug_idx").on(table.slug),
  severityIdx: index("articles_severity_idx").on(table.severity, desc(table.createdAt)),
}));

/** Join table with a composite primary key. */
export const articleTags = pgTable("article_tags", {
  articleId: integer("article_id").references(() => articles.id).notNull(),
  tag: varchar("tag", { length: 50 }).notNull(),
}, (table) => ({
  pk: primaryKey({ columns: [table.articleId, table.tag] }),
}));

export type Article = typeof articles.$inferSelect;
export type NewArticle = typeof articles.$inferInsert;

const db = drizzle(process.env.DATABASE_URL!);

/**
 * Lists popular published articles with their authors.
 *
 * @param minimumLikes - inclusive lower bound
 * @param limit - maximum rows to return
 */
export async function findPopular(minimumLikes = 10, limit = 20) {
  return db
    .select({
      id: articles.id,
      title: articles.title,
      likeCount: articles.likeCount,
      author: authors.displayName,
      tagCount: sql<number>`count(${articleTags.tag})`.as("tag_count"),
    })
    .from(articles)
    .innerJoin(authors, eq(authors.id, articles.authorId))
    .leftJoin(articleTags, eq(articleTags.articleId, articles.id))
    .where(and(eq(articles.isPublished, true), gte(articles.likeCount, minimumLikes)))
    .groupBy(articles.id, authors.displayName)
    .orderBy(desc(articles.likeCount))
    .limit(limit);
}

/** Creates an article and its tags atomically. */
export async function createWithTags(input: NewArticle, tags: string[]): Promise<Article> {
  return db.transaction(async (tx) => {
    const [created] = await tx.insert(articles).values(input).returning(); // inline comment

    if (tags.length > 0) {
      await tx.insert(articleTags).values(tags.map((tag) => ({ articleId: created.id, tag })));
    }

    return created;
  });
}
