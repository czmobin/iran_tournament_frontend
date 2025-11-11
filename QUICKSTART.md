# ⚡ Quick Start Guide

راهنمای سریع برای راه‌اندازی پروژه در کمتر از 5 دقیقه!

---

## 🎯 دیپلوی خودکار با CI/CD ⭐ (توصیه می‌شود)

**مزایا:** دیپلوی خودکار با PM2، مدیریت هوشمند، rollback safety

```bash
# 1. روی سرور: نصب Node.js
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# 2. نصب PM2
npm install -g pm2

# 3. کلون پروژه در /home/archive
cd /home/archive
git clone <repo-url>
cd iran_tournament_frontend

# 4. تنظیم environment (API روی همین سرور - پورت 8020)
cp .env.example .env
# API_BASE_URL=http://localhost:8020/api (پیش‌فرض)

# 5. تنظیم GitHub Secrets (فقط یکبار)
# SERVER_HOST, SERVER_USERNAME, SSH_PRIVATE_KEY, PROJECT_PATH

# 6. هر Push به main = دیپلوی خودکار! ✨
```

📖 راهنمای کامل: [CI-CD-SETUP.md](./CI-CD-SETUP.md)

---

## 🚀 دیپلوی دستی

### روش 1️⃣: استفاده از اسکریپت دیپلوی (توصیه می‌شود)

```bash
# کلون و تنظیم
cd /home/archive
git clone <repo-url>
cd iran_tournament_frontend
cp .env.example .env

# دیپلوی (همه چیز خودکار)
chmod +x deploy-production.sh
./deploy-production.sh

# ✅ Done! -> http://localhost:3000
```

### روش 2️⃣: دیپلوی قدم به قدم

```bash
# نصب PM2 (اگر نیست)
npm install -g pm2

# نصب و build
npm install
npm run build

# تنظیم .env
cp .env.example .env

# شروع با PM2
pm2 start ecosystem.config.cjs
pm2 save
pm2 startup  # برای شروع خودکار بعد از reboot
```

---

## 🔧 تنظیمات اولیه

### فایل `.env`:
```env
# بکند روی همین سرور - پورت 8020
API_BASE_URL=http://localhost:8020/api
PORT=3000
NODE_ENV=production
```

---

## 📊 مدیریت با PM2

### دستورات اصلی:

```bash
# وضعیت
pm2 status
pm2 list

# لاگ‌ها (real-time)
pm2 logs iran-tournament-frontend
pm2 logs iran-tournament-frontend --lines 100

# ری‌استارت
pm2 restart iran-tournament-frontend

# توقف
pm2 stop iran-tournament-frontend

# شروع مجدد
pm2 start iran-tournament-frontend

# حذف
pm2 delete iran-tournament-frontend

# مانیتورینگ
pm2 monit
```

### بروزرسانی:

```bash
# با CI/CD
git push origin main  # خودکار دیپلوی می‌شود!

# دستی
cd /home/archive/iran_tournament_frontend
git pull origin main
./deploy-production.sh
```

---

## 📚 مستندات کامل

| فایل | محتوا |
|------|-------|
| [README.md](./README.md) | معرفی پروژه و ویژگی‌ها |
| [DEPLOY.md](./DEPLOY.md) | راهنمای کامل دیپلوی |
| [CI-CD-SETUP.md](./CI-CD-SETUP.md) | راه‌اندازی CI/CD خودکار |
| **QUICKSTART.md** | همین راهنمای سریع! |

---

## ❓ مشکل دارید؟

### Application شروع نمی‌شود:
```bash
# بررسی وضعیت PM2
pm2 status

# مشاهده لاگ
pm2 logs iran-tournament-frontend --lines 50

# بررسی خطاها
pm2 logs iran-tournament-frontend --err --lines 50
```

### پورت 3000 گرفته است:
```bash
# پیدا کردن پروسه
sudo lsof -i :3000

# یا ری‌استارت PM2
pm2 restart iran-tournament-frontend
```

### اتصال به بکند برقرار نیست:
```bash
# بررسی بکند روی پورت 8020
curl http://localhost:8020/api

# بررسی فایل .env
cat .env | grep API_BASE_URL

# بررسی متغیرهای محیطی PM2
pm2 env iran-tournament-frontend
```

### PM2 بعد از reboot شروع نمی‌شود:
```bash
# یکبار این رو اجرا کن:
pm2 startup
pm2 save
```

---

## 🎉 انجام شد!

- 🌐 Frontend: `http://localhost:3000`
- 🔌 Backend API: `http://localhost:8020/api`
- 📊 لاگ‌ها: `pm2 logs iran-tournament-frontend`
- 🔄 بروزرسانی: `git pull` (با CI/CD خودکار!)
- 📈 مانیتورینگ: `pm2 monit`

---

## 🔍 نکات مهم:

1. **Backend باید روی پورت 8020 در حال اجرا باشد**
2. **PM2 به صورت daemon در background اجرا می‌شود**
3. **لاگ‌ها در `logs/pm2-*.log` ذخیره می‌شوند**
4. **Backup ها در `backups/` قرار می‌گیرند**
5. **PM2 auto-restart دارد (اگر crash کرد، خودش دوباره میاره بالا)**

---

## 💡 مزایای PM2:

✅ **مدیریت پروسه حرفه‌ای**
✅ **Auto-restart در صورت crash**
✅ **لاگ‌گذاری خودکار**
✅ **مانیتورینگ real-time**
✅ **کم‌ترین overhead**
✅ **Cluster mode support**
✅ **شروع خودکار بعد از reboot**

---

<div align="center">

**Need help?** Check the full guides:
[DEPLOY.md](./DEPLOY.md) | [CI-CD-SETUP.md](./CI-CD-SETUP.md)

**🎮 Connected to Backend on Port 8020**

</div>
