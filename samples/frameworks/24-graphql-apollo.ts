import { ApolloServer } from "@apollo/server";
import { startStandaloneServer } from "@apollo/server/standalone";
import DataLoader from "dataloader";
import gql from "graphql-tag";

/**
 * Apollo GraphQL framework tour.
 *
 * Covers schema definition, resolvers, context, data loaders,
 * custom scalars, directives, errors and subscriptions.
 */

export const typeDefs = gql`
  scalar DateTime

  directive @auth(requires: Role = USER) on FIELD_DEFINITION | OBJECT

  enum Role {
    USER
    EDITOR
    ADMIN
  }

  enum Severity {
    DEBUG
    INFO
    WARNING
    ERROR
  }

  interface Node {
    id: ID!
  }

  type Author implements Node {
    id: ID!
    displayName: String!
    articles(first: Int = 10, after: String): ArticleConnection!
  }

  type Article implements Node {
    id: ID!
    title: String!
    slug: String!
    severity: Severity!
    likeCount: Int!
    tags: [String!]!
    author: Author
    createdAt: DateTime!
  }

  type PageInfo {
    hasNextPage: Boolean!
    endCursor: String
  }

  type ArticleEdge {
    cursor: String!
    node: Article!
  }

  type ArticleConnection {
    edges: [ArticleEdge!]!
    pageInfo: PageInfo!
    totalCount: Int!
  }

  input CreateArticleInput {
    title: String!
    severity: Severity = INFO
    tags: [String!] = []
  }

  union SearchResult = Article | Author

  type Query {
    article(id: ID!): Article
    articles(first: Int = 20, severity: Severity): ArticleConnection!
    search(term: String!): [SearchResult!]!
  }

  type Mutation {
    createArticle(input: CreateArticleInput!): Article! @auth(requires: EDITOR)
    likeArticle(id: ID!): Article!
  }

  type Subscription {
    articleLiked(id: ID!): Article!
  }
`;

interface Context {
  loaders: { author: DataLoader<string, { id: string; displayName: string }> };
  user?: { id: string; role: "USER" | "EDITOR" | "ADMIN" };
}

export const resolvers = {
  Query: {
    article: async (_parent: unknown, { id }: { id: string }, ctx: Context) =>
      ctx.loaders.author.load(id), // inline comment
    articles: async (_p: unknown, { first = 20 }: { first?: number }) => ({
      edges: [],
      pageInfo: { hasNextPage: false, endCursor: null },
      totalCount: 0,
    }),
  },

  Mutation: {
    createArticle: async (_p: unknown, { input }: { input: Record<string, unknown> }, ctx: Context) => {
      if (ctx.user?.role === "USER") throw new Error("FORBIDDEN");
      return { id: "1", ...input };
    },
  },

  SearchResult: {
    __resolveType: (obj: Record<string, unknown>) => ("title" in obj ? "Article" : "Author"),
  },
};

const server = new ApolloServer<Context>({ typeDefs, resolvers });
const { url } = await startStandaloneServer(server, { listen: { port: 4000 } });
console.log(`ready at ${url}`);
