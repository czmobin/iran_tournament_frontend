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

WORKDIR /app

# کپی فایل‌های package
COPY package*.json ./

# نصب فقط production dependencies
RUN npm ci --only=production

# کپی فایل‌های build شده
COPY --from=builder /app/.output ./.output

# تنظیم متغیرهای محیطی
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3000
ENV NODE_ENV=production

# باز کردن پورت
EXPOSE 3000

# اجرای برنامه
CMD ["node", ".output/server/index.mjs"]
