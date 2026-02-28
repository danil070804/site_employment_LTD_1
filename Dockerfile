# ---------- Base ----------
FROM node:20-bullseye-slim AS base
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---------- Dependencies ----------
FROM base AS deps
COPY package.json package-lock.json* ./
COPY prisma ./prisma
RUN npm install

# ---------- Builder ----------
FROM base AS builder
COPY --from=deps /app/node_modules ./node_modules
COPY . .

RUN npx prisma generate
RUN npm run build

# ---------- Production ----------
FROM node:20-bullseye-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# КОПИРУЕМ ВСЁ node_modules
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/next.config.mjs ./next.config.mjs

EXPOSE 3000

CMD ["sh", "-c", "npx prisma db push --skip-generate && node node_modules/next/dist/bin/next start -p $PORT -H 0.0.0.0"]
