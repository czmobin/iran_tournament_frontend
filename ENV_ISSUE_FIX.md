# 🔧 رفع مشکل Environment Variable در Nuxt

## ❓ مشکل چی بود؟

وقتی فرانت build میشد، به جای IP سرور (`http://185.204.197.167:8020/api`) به `localhost:8020` درخواست میزد.

---

## 🔍 علت مشکل

Nuxt فایل `.env` رو در **زمان build** می‌خونه، نه runtime.

```javascript
// nuxt.config.ts
runtimeConfig: {
  public: {
    apiBase: process.env.API_BASE_URL || 'http://localhost:8020/api'
  }
}
```

اگه در زمان build متغیر `API_BASE_URL` set نشده باشه، به fallback value (`localhost`) می‌افته.

---

## ✅ راه‌حل 1: استفاده از setup-server.sh (توصیه می‌شود)

اسکریپت `setup-server.sh` این مشکل رو حل می‌کنه:

```bash
cd /home/archive/iran_tournament_frontend
git pull
./setup-server.sh
```

این اسکریپت:
1. IP سرور رو تشخیص میده
2. فایل `.env` می‌سازه
3. **Environment variable رو قبل از build export می‌کنه** ← کلید موفقیت!
4. Build می‌کنه

---

## ✅ راه‌حل 2: Build دستی با Environment Variable

اگه میخوای دستی build کنی:

```bash
cd /home/archive/iran_tournament_frontend

# ایجاد .env (برای development)
echo "API_BASE_URL=http://185.204.197.167:8020/api
PORT=3020
NODE_ENV=production" > .env

# Build با environment variable (مهم!)
export API_BASE_URL="http://185.204.197.167:8020/api"
npm run build

# یا به صورت inline:
API_BASE_URL="http://185.204.197.167:8020/api" npm run build
```

**نکته:** فقط ایجاد فایل `.env` کافی نیست، باید environment variable رو هم export کنی.

---

## ✅ راه‌حل 3: Hardcode (موقت - برای تست)

اگه فقط میخوای سریع تست کنی:

```typescript
// nuxt.config.ts
runtimeConfig: {
  public: {
    apiBase: process.env.API_BASE_URL || 'http://185.204.197.167:8020/api'
  }
}
```

سپس:
```bash
npm run build
pm2 restart iran-tournament-frontend
```

⚠️ **توجه:** این روش برای تست خوبه ولی برای production بهتره از environment variable استفاده کنی.

---

## 🧪 بررسی درستی

بعد از build و restart:

1. در مرورگر: `http://185.204.197.167:3020`
2. F12 → Network
3. سعی کن login کنی
4. باید ببینی:
   - ✅ Request URL: `http://185.204.197.167:8020/api/auth/login/`
   - ❌ نه: `http://localhost:8020/...`

---

## 📚 درس گرفته شده

برای deployment های بعدی:

1. **همیشه** environment variable رو قبل از build set کن
2. فقط ساختن `.env` کافی نیست
3. از `setup-server.sh` استفاده کن که همه چیز رو خودکار انجام میده
4. بعد از هر تغییر در `.env`، باید دوباره build کنی

---

## 🔄 در آینده برای بروزرسانی

```bash
cd /home/archive/iran_tournament_frontend
git pull

# اگه تنظیمات API عوض شده:
./setup-server.sh

# یا به صورت دستی:
export API_BASE_URL="http://NEW_IP:8020/api"
npm run build
pm2 restart iran-tournament-frontend
```
