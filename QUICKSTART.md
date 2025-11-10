# ⚡ Quick Start Guide

راهنمای سریع برای راه‌اندازی پروژه در کمتر از 5 دقیقه!

---

## 🎯 انتخاب روش دیپلوی

### گزینه 1️⃣: دیپلوی خودکار با CI/CD ⭐ (توصیه می‌شود)

**مزایا:** دیپلوی خودکار، مدیریت هوشمند فضا، rollback safety

```bash
# 1. روی سرور: نصب Docker
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# 2. کلون پروژه
git clone <repo-url> && cd iran_tournament_frontend

# 3. تنظیم environment
cp .env.example .env && nano .env

# 4. تنظیم GitHub Secrets (فقط یکبار)
# SERVER_HOST, SERVER_USERNAME, SSH_PRIVATE_KEY, PROJECT_PATH

# 5. هر Push به main = دیپلوی خودکار! ✨
```

📖 راهنمای کامل: [CI-CD-SETUP.md](./CI-CD-SETUP.md)

---

### گزینه 2️⃣: دیپلوی دستی با Docker

**مزایا:** ساده، سریع، ایزوله

```bash
# نصب Docker (اگر نیست)
curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh

# کلون و تنظیم
git clone <repo-url> && cd iran_tournament_frontend
cp .env.example .env && nano .env

# دیپلوی
docker-compose up -d

# ✅ Done! -> http://localhost:3000
```

---

### گزینه 3️⃣: دیپلوی با PM2

**مزایا:** کنترل بیشتر، مانیتورینگ آسان

```bash
# نصب PM2
npm install -g pm2

# آماده‌سازی
git clone <repo-url> && cd iran_tournament_frontend
cp .env.example .env && nano .env
npm install && npm run build

# اجرا
pm2 start ecosystem.config.cjs
pm2 save && pm2 startup

# ✅ Done! -> http://localhost:3000
```

---

## 🔧 تنظیمات اولیه (همه روش‌ها)

### فایل `.env`:
```env
API_BASE_URL=http://localhost:8000/api
NODE_ENV=production
```

---

## 🚀 دستورات سریع

### بروزرسانی:

```bash
# با CI/CD
git pull origin main  # خودکار دیپلوی می‌شود!

# با Docker
git pull && docker-compose up -d --build

# با PM2
git pull && npm install && npm run build && pm2 restart iran-tournament-frontend
```

### مشاهده لاگ:

```bash
# Docker
docker logs -f iran-tournament-frontend

# PM2
pm2 logs iran-tournament-frontend
```

### پاکسازی فضای Docker:

```bash
./docker-cleanup.sh
```

---

## 📚 مستندات کامل

| فایل | محتوا |
|------|-------|
| [README.md](./README.md) | معرفی پروژه و ویژگی‌ها |
| [DEPLOY.md](./DEPLOY.md) | راهنمای کامل دیپلوی (4 روش) |
| [CI-CD-SETUP.md](./CI-CD-SETUP.md) | راه‌اندازی CI/CD خودکار |
| **QUICKSTART.md** | همین راهنمای سریع! |

---

## ❓ مشکل دارید؟

### Application شروع نمی‌شود:
```bash
# بررسی لاگ
docker logs iran-tournament-frontend --tail 50
# یا
pm2 logs iran-tournament-frontend --lines 50
```

### پورت 3000 گرفته است:
```bash
# پیدا کردن پروسه
sudo lsof -i :3000
# کشتن پروسه
sudo kill -9 <PID>
```

### فضای دیسک پر است:
```bash
# پاکسازی Docker
./docker-cleanup.sh
# یا
docker system prune -a --volumes -f
```

---

## 🎉 انجام شد!

- 🌐 Application: `http://localhost:3000` یا `http://YOUR_DOMAIN`
- 📊 لاگ‌ها: `docker logs -f iran-tournament-frontend`
- 🔄 بروزرسانی: `git pull` (با CI/CD خودکار!)
- 🧹 Cleanup: `./docker-cleanup.sh`

---

<div align="center">

**Need help?** Check the full guides:
[DEPLOY.md](./DEPLOY.md) | [CI-CD-SETUP.md](./CI-CD-SETUP.md)

</div>
