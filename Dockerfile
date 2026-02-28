# ---------- Base ----------
FROM node:20-bullseye-slim AS base
WORKDIR /app

# Prisma needs openssl
RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# ---------- Dependencies ----------
FROM base AS deps

# Copy package files first (for better caching)
COPY package.json package-lock.json* ./
COPY prisma ./prisma

RUN npm install

# ---------- Builder ----------
FROM base AS builder

COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Generate Prisma client explicitly
RUN npx prisma generate

# Build Next.js
RUN npm run build

# ---------- Runner ----------
FROM node:20-bullseye-slim AS runner
WORKDIR /app

ENV NODE_ENV=production

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Copy only what is needed
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/next.config.mjs ./next.config.mjs
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/prisma ./prisma

EXPOSE 3000

# Sync schema safely on start (idempotent)
CMD ["sh", "-c", "npx prisma db push --skip-generate && npm start"]
