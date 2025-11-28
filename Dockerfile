# -------------------------
# 1. Build Stage
# -------------------------
FROM node:24-alpine AS builder

# Set working directory
WORKDIR /app

# Install dependencies separately for caching
COPY package.json package-lock.json* ./
RUN npm install

# Copy the rest of the project
COPY . .

# Fumadocs runs automatically via postinstall,
# but we run it explicitly for safety in Docker
RUN npx fumadocs-mdx

# Build Next.js
RUN npm run build

# -------------------------
# 2. Production Runtime Stage
# -------------------------
FROM node:24-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV NEXT_TELEMETRY_DISABLED=1

# Copy only necessary build files
COPY --from=builder /app/package.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public* ./public

EXPOSE 3000

CMD ["npm", "start"]