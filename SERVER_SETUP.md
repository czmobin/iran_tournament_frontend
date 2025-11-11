# 🚀 راهنمای راه‌اندازی روی سرور

این راهنما برای راه‌اندازی فرانت Nuxt.js روی سرور (کنار بکند Django) هست.

---

## 🎯 راه‌حل سریع (توصیه می‌شود)

### اسکریپت خودکار

```bash
cd /home/archive/iran_tournament_frontend
git pull
./setup-server.sh
```

**این اسکریپت همه چیز رو خودکار انجام میده:**
- ✅ IP سرور رو تشخیص میده
- ✅ فایل `.env` رو با تنظیمات صحیح می‌سازه (API به IP سرور اشاره می‌کنه نه localhost)
- ✅ تصاویر background رو کپی می‌کنه
- ✅ Dependencies رو نصب می‌کنه
- ✅ پروژه رو build می‌کنه
- ✅ بررسی نهایی انجام میده

**بعد از اجرا:** دستورات اجرا رو بهت نشون میده (PM2 یا Screen).

---

## 📋 راه‌حل دستی (قدم به قدم)

اگه میخوای دستی انجام بدی:

### 1️⃣ رفتن به پوشه پروژه

```bash
cd /home/archive/iran_tournament_frontend
```

### 2️⃣ دریافت آخرین تغییرات

```bash
git pull
```

### 3️⃣ ایجاد فایل .env با IP سرور

⚠️ **مهم:** به جای `YOUR_SERVER_IP` باید IP واقعی سرور رو بذاری (مثلاً 185.204.197.167)

```bash
echo "API_BASE_URL=http://YOUR_SERVER_IP:8020/api
PORT=3020
NODE_ENV=production" > .env

# مثال واقعی:
# echo "API_BASE_URL=http://185.204.197.167:8020/api
# PORT=3020
# NODE_ENV=production" > .env
```

### 4️⃣ کپی تصاویر background

```bash
./fix-images.sh
```

### 5️⃣ نصب Dependencies

```bash
npm install
```

### 6️⃣ Build مجدد پروژه ⚠️ مهم

**نکته مهم:** Nuxt در زمان build فایل `.env` رو می‌خونه، پس باید environment variable رو قبل از build set کنی:

```bash
# روش 1: Export کردن قبل از build (توصیه می‌شود)
export API_BASE_URL="http://185.204.197.167:8020/api"
npm run build

# روش 2: inline با build command
API_BASE_URL="http://185.204.197.167:8020/api" npm run build
```

این مرحله **حتماً** باید انجام بشه و با environment variable صحیح.

### 7️⃣ اجرای اپلیکیشن

بسته به روش اجرا:

#### اگه با PM2:
```bash
pm2 restart iran-tournament-frontend

# یا اگه اولین باره:
PORT=3020 pm2 start .output/server/index.mjs --name iran-tournament-frontend
pm2 save
```

#### اگه با Screen:
```bash
# رفتن به screen
screen -r iran-frontend

# Ctrl+C برای توقف
# بعد اجرای دوباره:
PORT=3020 node .output/server/index.mjs

# Ctrl+A سپس D برای detach
```

#### اگه با systemd:
```bash
sudo systemctl restart iran-tournament-frontend
```

---

## 🔍 بررسی درستی

بعد از انجام مراحل، چک کن:

```bash
# بررسی وجود فایل‌ها در public
ls -lh public/*.png

# بررسی وجود فایل‌ها در output
ls -lh .output/public/*.png

# هر دو باید نمایش داده بشن:
# mobile_index.png
# desktop_index.png
```

### تست در مرورگر

1. باز کن: `http://your-server-ip:3020`
2. F12 برای باز کردن Developer Tools
3. تب Network رو باز کن
4. فیلتر رو روی "Img" بذار
5. صفحه رو refresh کن
6. باید ببینی که `mobile_index.png` و `desktop_index.png` با وضعیت 200 لود میشن

---

## ❌ اگه هنوز مشکل داره

### بررسی دستی:

```bash
# چک کن که فایل‌ها کجا هستن
find . -name "mobile_index.png" -o -name "desktop_index.png"

# باید این مسیرها رو نشون بده:
# ./.github/screenshots/mobile_index.png
# ./.github/screenshots/desktop_index.png
# ./public/mobile_index.png
# ./public/desktop_index.png
# ./.output/public/mobile_index.png
# ./.output/public/desktop_index.png
```

### کپی دستی:

```bash
# اگه اسکریپت کار نکرد، دستی کپی کن:
mkdir -p public
cp .github/screenshots/mobile_index.png public/
cp .github/screenshots/desktop_index.png public/

# بعد حتماً build کن:
npm run build

# و ری‌استارت:
pm2 restart iran-tournament-frontend
```

### بررسی لاگ‌ها:

```bash
# اگه با PM2:
pm2 logs iran-tournament-frontend

# اگه با systemd:
sudo journalctl -u iran-tournament-frontend -f

# چک کن که ارور 404 برای فایل‌های .png نداشته باشی
```

---

## 📋 چک‌لیست نهایی

قبل از ری‌استارت، مطمئن شو:

- [ ] `git pull` انجام شده
- [ ] فایل‌ها در `public/` موجود هستن: `ls public/*.png`
- [ ] `npm install` اجرا شده
- [ ] `npm run build` اجرا شده
- [ ] فایل‌ها در `.output/public/` موجود هستن: `ls .output/public/*.png`
- [ ] فایل `.env` موجود هست و تنظیمات درسته
- [ ] اپلیکیشن ری‌استارت شده

---

## 🎯 خلاصه یک‌خطی

برای عجله‌ای‌ها:

```bash
cd /path/to/iran_tournament_frontend && \
git pull && \
./fix-images.sh && \
npm install && \
npm run build && \
pm2 restart iran-tournament-frontend
```

این همه چیز رو یکجا انجام میده! ✅
