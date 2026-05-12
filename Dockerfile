FROM oven/bun:1 AS build
WORKDIR /app
COPY package.json bun.lockb ./
# Skip postinstall (nuxt prepare runs at runtime would fail without full tree, and
# better-sqlite3 native build also rejected — Bun ships its own SQLite).
RUN bun install --frozen-lockfile --ignore-scripts
COPY . .
ENV NODE_ENV=production
RUN bun run build

FROM oven/bun:1
WORKDIR /app
COPY --from=build /app/.output ./.output
COPY --from=build /app/server/database/migrations ./server/database/migrations 2>/dev/null || true
COPY --from=build /app/drizzle.config.ts ./
ENV NODE_ENV=production \
    NITRO_PORT=3000 \
    NITRO_HOST=0.0.0.0 \
    DATABASE_URL=/data/money.sqlite
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s \
  CMD bun -e "fetch('http://127.0.0.1:3000/').then(r=>process.exit(r.ok?0:1)).catch(()=>process.exit(1))"
CMD ["bun", "run", ".output/server/index.mjs"]
