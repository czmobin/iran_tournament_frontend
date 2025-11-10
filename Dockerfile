# مرحله اول: Build
FROM node:20-alpine AS builder

WORKDIR /app

# کپی فایل‌های package
COPY package*.json ./

# نصب dependencies
RUN npm ci

# کپی بقیه فایل‌ها
COPY . .

# ساخت پروژه
RUN npm run build

# مرحله دوم: Production
FROM node:20-alpine

# نصب ابزارهای لازم برای healthcheck و debugging
RUN apk add --no-cache wget curl

WORKDIR /app

# کپی فایل‌های package
COPY package*.json ./

# نصب فقط production dependencies
RUN npm ci --only=production && npm cache clean --force

# کپی فایل‌های build شده
COPY --from=builder /app/.output ./.output

# ایجاد user غیر root برای امنیت
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001 && \
    chown -R nodejs:nodejs /app

# تنظیم متغیرهای محیطی
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000
ENV NODE_ENV=production

# باز کردن پورت
EXPOSE 3000

# تغییر به user غیر root
USER nodejs

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:3000 || exit 1

# اجرای برنامه
CMD ["node", ".output/server/index.mjs"]
