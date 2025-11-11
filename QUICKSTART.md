# ⚡ Quick Start Guide

راهنمای سریع برای راه‌اندازی پروژه

---

## 🎯 دیپلوی خودکار با CI/CD

**کد خودکار build می‌شه، اجرا دستی**

```bash
# 1. روی سرور: نصب Node.js و PM2
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pm2

# 2. کلون پروژه در /home/archive
cd /home/archive
git clone <repo-url>
cd iran_tournament_frontend

# 3. تنظیم environment
cp .env.example .env
# API_BASE_URL=http://localhost:8020/api (پیش‌فرض)

# 4. تنظیم GitHub Secrets (فقط یکبار)
# SERVER_HOST, SERVER_USERNAME, SSH_PRIVATE_KEY, PROJECT_PATH

# 5. هر Push به main = کد build میشه! ✨
# بعد دستی اجرا کن: pm2 restart iran-tournament-frontend
```

---

## 🚀 دیپلوی دستی

### استفاده از اسکریپت:

```bash
cd /home/archive/iran_tournament_frontend

# Build کد
./deploy-production.sh

# اجرا (دستی)
pm2 start ecosystem.config.cjs
# یا اگه قبلاً اجرا شده:
pm2 restart iran-tournament-frontend
```

### قدم به قدم:

```bash
# نصب و build
npm install
npm run build

# تنظیم .env
cp .env.example .env

# اجرا
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup
```

---

## 🔧 تنظیمات

### فایل `.env`:
```env
API_BASE_URL=http://localhost:8020/api
PORT=3000
NODE_ENV=production
```

---

## 📊 مدیریت با PM2

```bash
# شروع
pm2 start ecosystem.config.cjs

# وضعیت
pm2 status

# لاگ
pm2 logs iran-tournament-frontend

# ری‌استارت
pm2 restart iran-tournament-frontend

# توقف
pm2 stop iran-tournament-frontend

# حذف
pm2 delete iran-tournament-frontend

# مانیتورینگ
pm2 monit
```

---

## 🔄 بروزرسانی

```bash
# کد جدید push شد؟ (با CI/CD خودکار build میشه)
cd /home/archive/iran_tournament_frontend
git pull

# ری‌استارت
pm2 restart iran-tournament-frontend

# یا build دستی
./deploy-production.sh
pm2 restart iran-tournament-frontend
```

---

## ❓ مشکلات رایج

### Application شروع نمی‌شود:
```bash
pm2 status
pm2 logs iran-tournament-frontend --lines 50
```

### پورت گرفته:
```bash
sudo lsof -i :3000
pm2 restart iran-tournament-frontend
```

### اتصال به بکند:
```bash
curl http://localhost:8020/api
cat .env | grep API_BASE_URL
```

---

## 🎉 نتیجه

- 🌐 Frontend: `http://localhost:3000`
- 🔌 Backend: `http://localhost:8020/api`
- 📊 لاگ‌ها: `pm2 logs iran-tournament-frontend`
- 🔄 بروزرسانی: `git pull` → `pm2 restart`

---

## 💡 نکات

1. **CI/CD فقط build می‌کنه** - اجرا دستی
2. **Backend روی پورت 8020** باید اجرا باشه
3. **PM2 auto-restart** داره
4. **لاگ‌ها:** `logs/pm2-*.log`
5. **Backup ها:** `backups/`
