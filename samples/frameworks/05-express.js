/**
 * Express framework tour.
 *
 * Covers routers, middleware, error handling, async wrappers,
 * validation, static files and graceful shutdown.
 */

import express from "express";
import helmet from "helmet";
import morgan from "morgan";

const app = express();
const router = express.Router();

/** Wraps an async handler so rejections reach the error middleware. */
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

/**
 * Simple API key guard.
 *
 * @param {import("express").Request} req
 * @param {import("express").Response} res
 * @param {import("express").NextFunction} next
 */
function requireApiKey(req, res, next) {
  const key = req.get("x-api-key"); // inline comment
  if (!key) {
    return res.status(401).json({ error: "missing api key" });
  }
  req.apiKey = key;
  next();
}

const store = new Map([[1, { id: 1, title: "hello", likeCount: 0 }]]);

router.get(
  "/articles",
  asyncHandler(async (req, res) => {
    const { limit = "20", severity } = req.query;
    const articles = [...store.values()].slice(0, Number.parseInt(limit, 10));
    res.status(200).json({ data: articles, severity: severity ?? "info" });
  }),
);

router.get(
  "/articles/:id(\\d+)",
  requireApiKey,
  asyncHandler(async (req, res) => {
    const article = store.get(Number(req.params.id));
    if (!article) {
      const err = new Error(`article ${req.params.id} not found`);
      err.status = 404;
      throw err;
    }
    res.json(article);
  }),
);

router.post("/articles", express.json({ limit: "1mb" }), (req, res) => {
  const { title, likeCount = 0 } = req.body ?? {};
  if (typeof title !== "string" || title.length === 0) {
    return res.status(422).json({ error: "title required" });
  }
  const id = store.size + 1;
  store.set(id, { id, title, likeCount });
  res.status(201).location(`/api/articles/${id}`).json({ id });
});

app.use(helmet());
app.use(morgan("combined"));
app.use(express.static("public", { maxAge: "1d" }));
app.use("/api", router);

// Centralised error middleware — must take four arguments.
app.use((err, req, res, _next) => {
  const status = err.status ?? 500;
  res.status(status).json({ error: err.message, status });
});

const server = app.listen(process.env.PORT ?? 3000, () => {
  console.log(`listening on ${server.address().port}`);
});

process.on("SIGTERM", () => server.close(() => process.exit(0)));
