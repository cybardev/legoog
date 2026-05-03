FROM oven/bun:1.1.21-alpine AS base
WORKDIR /app

FROM base AS install
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile --production

FROM base AS build
COPY package.json bun.lock* ./
RUN bun install --frozen-lockfile
COPY . .
RUN bun run build

FROM base AS release
RUN apk add --no-cache git ca-certificates curl

COPY --from=install /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/src ./src

ENV PORT=4444
EXPOSE 4444

CMD ["bun", "run", "src/server/index.ts"]
