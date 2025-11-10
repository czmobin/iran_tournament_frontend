# 🏆 Iran Tournament - فرانت‌اند سیستم مدیریت تورنومنت

پلتفرم جامع برای مدیریت و نمایش تورنومنت‌های بازی‌های ویدیویی در ایران.

## 📸 نمایش پروژه

<div align="center">

### نمای دسکتاپ
![Desktop View](.github/screenshots/desktop_index.png)

### نمای موبایل
![Mobile View](.github/screenshots/mobile_index.png)

</div>

## ✨ ویژگی‌ها

- 🎮 نمایش تورنومنت‌های فعال و آینده
- 📱 طراحی ریسپانسیو (موبایل و دسکتاپ)
- 🌙 پشتیبانی از تم تاریک و روشن
- 🏅 نمایش جوایز و جزئیات تورنومنت‌ها
- ⚡ بهینه‌سازی شده برای عملکرد بالا
- 🎨 رابط کاربری زیبا و مدرن با Tailwind CSS
- 🔄 مدیریت state با Pinia
- 🌐 پشتیبانی کامل از زبان فارسی (RTL)

## 🛠 تکنولوژی‌ها

- **Framework:** [Nuxt 4](https://nuxt.com/)
- **UI Framework:** [Tailwind CSS](https://tailwindcss.com/)
- **State Management:** [Pinia](https://pinia.vuejs.org/)
- **Runtime:** Node.js 18+

## 🚀 نصب و راه‌اندازی

### پیش‌نیازها

- Node.js نسخه 18 یا بالاتر
- npm یا yarn

### نصب

```bash
# کلون کردن پروژه
git clone <repository-url>
cd iran_tournament_frontend

# نصب dependencies
npm install

# کپی فایل محیطی
cp .env.example .env

# ویرایش فایل .env و تنظیم API_BASE_URL
nano .env
```

### اجرای محیط Development

```bash
npm run dev
```

سایت روی `http://localhost:3000` در دسترس خواهد بود.

### ساخت نسخه Production

```bash
npm run build
```

### پیش‌نمایش نسخه Production

```bash
npm run preview
```

## 🌐 دیپلوی روی سرور

### 🚀 دیپلوی خودکار با CI/CD ⭐ (توصیه می‌شود)

پروژه دارای سیستم CI/CD کامل است که **هر merge به main را خودکار روی سرور دیپلوی می‌کند**.

**ویژگی‌ها:**
- ✅ دیپلوی خودکار با GitHub Actions
- ✅ مدیریت هوشمند فضای Docker (فقط 2 image آخر نگه داشته می‌شود)
- ✅ Backup خودکار قبل از deployment
- ✅ Health check و monitoring
- ✅ Zero downtime deployment

```bash
# تنظیم (فقط یکبار):
# 1. اضافه کردن GitHub Secrets (SERVER_HOST, SSH_PRIVATE_KEY, ...)
# 2. کلون پروژه روی سرور
# 3. تنظیم .env روی سرور

# استفاده:
git push origin main  # ← خودکار دیپلوی می‌شود! 🚀
```

📖 راهنمای کامل CI/CD: **[CI-CD-SETUP.md](./CI-CD-SETUP.md)**

---

### روش‌های دیپلوی دستی:

#### 🐳 Docker
```bash
cp .env.example .env && nano .env
docker-compose up -d
```

#### 🔄 PM2
```bash
npm install && npm run build
cp .env.example .env && nano .env
pm2 start ecosystem.config.cjs
```

#### 🧹 پاکسازی خودکار Docker
```bash
# اجرای اسکریپت cleanup (جلوگیری از پر شدن دیسک)
./docker-cleanup.sh

# یا تنظیم cron برای اجرای روزانه:
crontab -e
# اضافه کنید: 0 2 * * * /path/to/docker-cleanup.sh
```

📖 راهنمای کامل دیپلوی: **[DEPLOY.md](./DEPLOY.md)** | **[QUICKSTART.md](./QUICKSTART.md)**

## 📁 ساختار پروژه

```
iran_tournament_frontend/
├── .github/
│   └── screenshots/      # تصاویر نمایشی پروژه
├── assets/
│   └── css/             # فایل‌های CSS سفارشی
├── components/          # کامپوننت‌های Vue قابل استفاده مجدد
├── composables/         # Composable functions
├── layouts/             # Layout های صفحات
├── middleware/          # Middleware های routing
├── pages/              # صفحات اصلی (file-based routing)
│   └── tournaments/    # صفحات مربوط به تورنومنت‌ها
├── plugins/            # پلاگین‌های Vue
├── stores/             # Store های Pinia
├── public/             # فایل‌های استاتیک
├── Dockerfile          # تنظیمات Docker
├── docker-compose.yml  # Docker Compose config
├── ecosystem.config.cjs # تنظیمات PM2
├── nginx.conf.example  # نمونه تنظیمات Nginx
├── deploy.sh          # اسکریپت دیپلوی خودکار
└── DEPLOY.md          # راهنمای کامل دیپلوی
```

## 🔧 تنظیمات محیطی

فایل `.env` را ایجاد کنید و متغیرهای زیر را تنظیم کنید:

```env
# آدرس API بکند
API_BASE_URL=http://localhost:8000/api

# محیط اجرا
NODE_ENV=production
```

## 🤝 مشارکت

برای مشارکت در پروژه:

1. Fork کنید
2. برنچ feature خود را بسازید (`git checkout -b feature/AmazingFeature`)
3. تغییرات را commit کنید (`git commit -m 'Add some AmazingFeature'`)
4. به برنچ خود push کنید (`git push origin feature/AmazingFeature`)
5. یک Pull Request باز کنید

## 📝 مستندات بیشتر

- [راهنمای دیپلوی](./DEPLOY.md) - راهنمای کامل دیپلوی به فارسی
- [مستندات Nuxt](https://nuxt.com/docs)
- [مستندات Tailwind CSS](https://tailwindcss.com/docs)

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

<div align="center">
ساخته شده با ❤️ برای جامعه گیمرز ایران
</div>
