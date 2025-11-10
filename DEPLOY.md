# راهنمای دیپلوی پروژه Iran Tournament Frontend

این راهنما روش‌های مختلف دیپلوی این پروژه Nuxt.js را توضیح می‌دهد.

## پیش‌نیازها

- Node.js نسخه 18 یا بالاتر
- npm یا yarn
- سرور با دسترسی SSH (برای VPS)

## روش 1️⃣: دیپلوی با Docker (توصیه می‌شود)

### مزایا
- ایزوله بودن محیط
- راه‌اندازی آسان
- قابل انتقال به سرورهای مختلف

### مراحل

1. **نصب Docker روی سرور:**
```bash
# برای Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

2. **کپی پروژه به سرور:**
```bash
# روی کامپیوتر لوکال
scp -r . user@your-server:/home/user/iran-tournament
```

3. **ساخت فایل .env:**
```bash
cd /home/user/iran-tournament
cp .env.example .env
nano .env  # ویرایش و تنظیم API_BASE_URL
```

4. **اجرای Docker:**
```bash
# ساخت و اجرا
docker-compose up -d

# مشاهده لاگ‌ها
docker-compose logs -f

# توقف
docker-compose down
```

5. **بررسی وضعیت:**
```bash
curl http://localhost:3000
```

---

## روش 2️⃣: دیپلوی با PM2 (بدون Docker)

### مزایا
- مدیریت پروسه با قابلیت restart خودکار
- مانیتورینگ آسان
- کنترل بیشتر

### مراحل

1. **نصب PM2:**
```bash
npm install -g pm2
```

2. **آپلود پروژه به سرور:**
```bash
# روی کامپیوتر لوکال
scp -r . user@your-server:/home/user/iran-tournament
```

3. **نصب dependencies و build:**
```bash
cd /home/user/iran-tournament

# کپی فایل محیطی
cp .env.example .env
nano .env  # ویرایش و تنظیم API_BASE_URL

# نصب
npm install

# ساخت نسخه production
npm run build
```

4. **اجرا با PM2:**
```bash
# شروع با فایل ecosystem
pm2 start ecosystem.config.cjs

# یا اجرای مستقیم
pm2 start .output/server/index.mjs --name iran-tournament

# ذخیره برای راه‌اندازی خودکار
pm2 save
pm2 startup
```

5. **دستورات مدیریتی PM2:**
```bash
# مشاهده وضعیت
pm2 status

# مشاهده لاگ‌ها
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

## روش 3️⃣: تنظیم Nginx به عنوان Reverse Proxy

برای استفاده از دامنه و HTTPS، باید Nginx را تنظیم کنید.

### مراحل

1. **نصب Nginx:**
```bash
sudo apt update
sudo apt install nginx
```

2. **کپی فایل تنظیمات:**
```bash
sudo cp nginx.conf.example /etc/nginx/sites-available/iran-tournament
```

3. **ویرایش تنظیمات:**
```bash
sudo nano /etc/nginx/sites-available/iran-tournament

# دامنه خود را جایگزین کنید:
# server_name yourdomain.com www.yourdomain.com;
```

4. **فعال‌سازی:**
```bash
sudo ln -s /etc/nginx/sites-available/iran-tournament /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

5. **نصب SSL با Let's Encrypt (برای HTTPS):**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

---

## روش 4️⃣: دیپلوی استاتیک (Static Generation)

اگر نیازی به SSR ندارید، می‌توانید نسخه استاتیک بسازید.

### مراحل

1. **تغییر حالت rendering در `nuxt.config.ts`:**
```typescript
export default defineNuxtConfig({
  ssr: false,  // اضافه کنید
  // یا برای static generation:
  // nitro: {
  //   preset: 'static'
  // }
})
```

2. **ساخت نسخه استاتیک:**
```bash
npm run generate
```

3. **فایل‌های خروجی در پوشه `.output/public` قرار می‌گیرند**

4. **آپلود به هر هاست استاتیک:**
```bash
# مثال با rsync
rsync -avz .output/public/ user@server:/var/www/html/
```

---

## تنظیمات متغیرهای محیطی

فایل `.env` را بسازید:

```env
# آدرس API
API_BASE_URL=https://api.yourdomain.com/api

# پورت (اختیاری)
PORT=3000

# محیط
NODE_ENV=production
```

---

## نکات امنیتی

1. **فایروال را تنظیم کنید:**
```bash
sudo ufw allow 22    # SSH
sudo ufw allow 80    # HTTP
sudo ufw allow 443   # HTTPS
sudo ufw enable
```

2. **فایل .env را به گیت اضافه نکنید**
```bash
echo ".env" >> .gitignore
```

3. **کلیدهای SSH را تنظیم کنید و پسورد SSH را غیرفعال کنید**

4. **Nginx rate limiting را فعال کنید**

---

## مانیتورینگ و لاگ‌ها

### با PM2:
```bash
pm2 logs
pm2 monit
```

### با Docker:
```bash
docker-compose logs -f
docker stats
```

### Nginx logs:
```bash
sudo tail -f /var/log/nginx/iran-tournament-access.log
sudo tail -f /var/log/nginx/iran-tournament-error.log
```

---

## بروزرسانی اپلیکیشن

### با Docker:
```bash
git pull
docker-compose down
docker-compose up -d --build
```

### با PM2:
```bash
git pull
npm install
npm run build
pm2 restart iran-tournament-frontend
```

---

## رفع مشکلات رایج

### پورت در حال استفاده است:
```bash
# پیدا کردن پروسه
sudo lsof -i :3000
# یا
sudo netstat -tulpn | grep 3000

# کشتن پروسه
kill -9 PID
```

### مشکل permission:
```bash
# دادن دسترسی به پوشه
sudo chown -R $USER:$USER /home/user/iran-tournament
```

### حافظه کم:
```bash
# کاهش تعداد instance های PM2
pm2 scale iran-tournament-frontend 1
```

---

## پشتیبان‌گیری

```bash
# بکاپ خودکار با cron
0 2 * * * tar -czf /backup/iran-tournament-$(date +\%Y\%m\%d).tar.gz /home/user/iran-tournament
```

---

## منابع بیشتر

- [مستندات Nuxt Deployment](https://nuxt.com/docs/getting-started/deployment)
- [مستندات PM2](https://pm2.keymetrics.io/)
- [مستندات Docker](https://docs.docker.com/)
- [راهنمای Nginx](https://nginx.org/en/docs/)

---

## پشتیبانی

در صورت بروز مشکل:
1. لاگ‌ها را بررسی کنید
2. متغیرهای محیطی را چک کنید
3. فایروال و پورت‌ها را بررسی کنید
