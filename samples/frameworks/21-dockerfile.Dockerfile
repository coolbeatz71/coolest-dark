# syntax=docker/dockerfile:1.7
# =============================================================
# Dockerfile framework tour
#
# Covers multi-stage builds, ARG/ENV, cache mounts, healthchecks,
# non-root users, labels and entrypoints.
# =============================================================

ARG NODE_VERSION=22
ARG ALPINE_VERSION=3.20

# ---------- stage: dependencies ----------
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS deps

WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev --no-audit --no-fund

# ---------- stage: build ----------
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS build

WORKDIR /app
ENV NODE_ENV=production

COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npm run build && npm prune --omit=dev

# ---------- stage: production ----------
FROM node:${NODE_VERSION}-alpine${ALPINE_VERSION} AS production

LABEL org.opencontainers.image.title="Coolest Dark API" \
      org.opencontainers.image.source="https://github.com/coolbeatz71/coolest-dark" \
      org.opencontainers.image.licenses="MIT"

ENV NODE_ENV=production \
    PORT=3000 \
    TZ=UTC

RUN addgroup -g 10001 -S app && adduser -u 10001 -S app -G app

WORKDIR /app

COPY --from=build --chown=app:app /app/dist ./dist
COPY --from=build --chown=app:app /app/node_modules ./node_modules
COPY --chown=app:app package.json ./

USER app
EXPOSE 3000

VOLUME ["/app/uploads"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD wget -qO- "http://127.0.0.1:${PORT}/health" || exit 1

# inline comment: exec form avoids a shell wrapper
ENTRYPOINT ["node", "--enable-source-maps"]
CMD ["dist/main.js"]
