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

### اجرای نسخه Production

```bash
# Build پروژه
npm run build

# اجرا با Node.js
node .output/server/index.mjs
```

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
└── public/             # فایل‌های استاتیک
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

- [مستندات Nuxt](https://nuxt.com/docs)
- [مستندات Tailwind CSS](https://tailwindcss.com/docs)

## 📄 لایسنس

این پروژه تحت لایسنس MIT منتشر شده است.

---

<div align="center">
ساخته شده با ❤️ برای جامعه گیمرز ایران
</div>
