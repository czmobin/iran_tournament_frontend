# ⚡ Quick Start Guide

راهنمای سریع برای راه‌اندازی پروژه در کمتر از 5 دقیقه!

---

## 🎯 روش‌های دیپلوی

### گزینه 1️⃣: دیپلوی خودکار با CI/CD ⭐ (توصیه می‌شود)

**مزایا:** دیپلوی خودکار با Screen، مدیریت هوشمند، rollback safety

```bash
# 1. روی سرور: نصب Node.js و screen
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs screen

# 2. کلون پروژه
git clone <repo-url> && cd iran_tournament_frontend

# 3. تنظیم environment (API روی همین سرور - پورت 8020)
cp .env.example .env
# API_BASE_URL=http://localhost:8020/api

# 4. تنظیم GitHub Secrets (فقط یکبار)
# SERVER_HOST, SERVER_USERNAME, SSH_PRIVATE_KEY, PROJECT_PATH

# 5. هر Push به main = دیپلوی خودکار! ✨
```

📖 راهنمای کامل: [CI-CD-SETUP.md](./CI-CD-SETUP.md)

---

### گزینه 2️⃣: دیپلوی دستی با Screen

**مزایا:** ساده، مستقیم، قابل مدیریت

```bash
# کلون و تنظیم
git clone <repo-url> && cd iran_tournament_frontend
cp .env.example .env
# ویرایش .env (پورت بکند: 8020)

# نصب و build
npm install
npm run build

# اجرا با screen
./screen-manager.sh start

# ✅ Done! -> http://localhost:3000
# API: http://localhost:8020/api
```

---

### گزینه 3️⃣: دیپلوی با PM2

**مزایا:** مانیتورینگ، auto-restart، cluster mode

```bash
# نصب PM2
npm install -g pm2

# آماده‌سازی
git clone <repo-url> && cd iran_tournament_frontend
cp .env.example .env && npm install && npm run build

# اجرا
pm2 start ecosystem.config.cjs
pm2 save && pm2 startup

# ✅ Done! -> http://localhost:3000
```

---

## 🔧 تنظیمات اولیه (همه روش‌ها)

### فایل `.env`:
```env
# بکند روی همین سرور - پورت 8020
API_BASE_URL=http://localhost:8020/api
PORT=3000
NODE_ENV=production
```

---

## 🚀 دستورات سریع

### بروزرسانی:

```bash
# با CI/CD
git pull origin main  # خودکار دیپلوی می‌شود!

# با Screen (دستی)
git pull
npm install && npm run build
./screen-manager.sh restart

# با PM2
git pull && npm install && npm run build && pm2 restart iran-tournament-frontend
```

### مدیریت Screen:

```bash
# وضعیت
./screen-manager.sh status

# شروع
./screen-manager.sh start

# توقف
./screen-manager.sh stop

# ری‌استارت
./screen-manager.sh restart

# مشاهده لاگ
./screen-manager.sh logs

# اتصال به session
./screen-manager.sh attach
# (جدا شدن: Ctrl+A سپس D)
```

### مشاهده لاگ با PM2:

```bash
pm2 logs iran-tournament-frontend
pm2 monit
```

---

## 📚 مستندات کامل

| فایل | محتوا |
|------|-------|
| [README.md](./README.md) | معرفی پروژه و ویژگی‌ها |
| [DEPLOY.md](./DEPLOY.md) | راهنمای کامل دیپلوی (3 روش) |
| [CI-CD-SETUP.md](./CI-CD-SETUP.md) | راه‌اندازی CI/CD خودکار |
| **QUICKSTART.md** | همین راهنمای سریع! |

---

## ❓ مشکل دارید؟

### Application شروع نمی‌شود:
```bash
# با Screen
./screen-manager.sh logs
# یا
screen -r iran-tournament-frontend

# با PM2
pm2 logs iran-tournament-frontend --lines 50
```

### پورت 3000 گرفته است:
```bash
# پیدا کردن پروسه
sudo lsof -i :3000
# کشتن پروسه
sudo kill -9 <PID>

# یا با screen-manager
./screen-manager.sh restart
```

### اتصال به بکند برقرار نیست:
```bash
# بررسی بکند روی پورت 8020
curl http://localhost:8020/api

# بررسی فایل .env
cat .env | grep API_BASE_URL
```

### Screen session پیدا نمی‌شود:
```bash
# لیست همه session ها
screen -list

# شروع دوباره
./screen-manager.sh start
```

---

## 🎉 انجام شد!

- 🌐 Frontend: `http://localhost:3000`
- 🔌 Backend API: `http://localhost:8020/api`
- 📊 لاگ‌ها: `./screen-manager.sh logs`
- 🔄 بروزرسانی: `git pull` (با CI/CD خودکار!)
- 📱 Screen Session: `screen -r iran-tournament-frontend`

---

## 🔍 نکات مهم:

1. **Backend باید روی پورت 8020 در حال اجرا باشد**
2. **Screen session در background اجرا می‌شود**
3. **لاگ‌ها در `logs/app.log` ذخیره می‌شوند**
4. **Backup ها در `backups/` قرار می‌گیرند**
5. **برای detach از screen: Ctrl+A ثم D**

---

<div align="center">

**Need help?** Check the full guides:
[DEPLOY.md](./DEPLOY.md) | [CI-CD-SETUP.md](./CI-CD-SETUP.md)

**🎮 Connected to Backend on Port 8020**

</div>
