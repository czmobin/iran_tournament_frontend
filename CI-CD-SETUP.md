# 🚀 راهنمای راه‌اندازی CI/CD خودکار

این راهنما نحوه راه‌اندازی دیپلوی خودکار پروژه را هنگام merge به main توضیح می‌دهد.

---

## 📋 فهرست مطالب

1. [نمای کلی](#نمای-کلی)
2. [پیش‌نیازها](#پیش‌نیازها)
3. [راه‌اندازی سرور](#راه‌اندازی-سرور)
4. [تنظیمات GitHub](#تنظیمات-github)
5. [تست CI/CD](#تست-cicd)
6. [مدیریت و نگهداری](#مدیریت-و-نگهداری)
7. [رفع مشکلات](#رفع-مشکلات)

---

## 🎯 نمای کلی

### چه اتفاقی می‌افتد؟

```
کد جدید → Push به main → GitHub Actions → SSH به سرور → دیپلوی خودکار
```

### ویژگی‌های سیستم CI/CD:

✅ **دیپلوی خودکار** - هر merge به main خودکار دیپلوی می‌شود
✅ **مدیریت هوشمند Docker** - فقط 2 image آخر نگه داشته می‌شود
✅ **Cleanup خودکار** - فضای دیسک مدیریت می‌شود
✅ **Rollback Safety** - backup از image قبلی گرفته می‌شود
✅ **Health Checks** - سلامت application بررسی می‌شود
✅ **Zero Downtime** - سرویس قطع نمی‌شود

---

## 🔧 پیش‌نیازها

### روی سرور:
- Ubuntu/Debian Linux
- Docker و Docker Compose نصب شده
- Git نصب شده
- دسترسی SSH
- حداقل 2GB فضای خالی دیسک

### روی GitHub:
- دسترسی به تنظیمات Repository
- امکان اضافه کردن Secrets

---

## 🖥️ راه‌اندازی سرور

### مرحله 1: نصب Docker

```bash
# نصب Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# نصب Docker Compose (اگر نصب نشده)
sudo apt update
sudo apt install docker-compose-plugin

# بررسی نصب
docker --version
docker compose version
```

### مرحله 2: کلون پروژه روی سرور

```bash
# رفتن به دایرکتوری دلخواه
cd /home/user

# کلون پروژه
git clone https://github.com/YOUR_USERNAME/iran_tournament_frontend.git
cd iran_tournament_frontend

# تنظیم برنچ main
git checkout main
```

### مرحله 3: تنظیم فایل .env

```bash
# کپی فایل نمونه
cp .env.example .env

# ویرایش فایل
nano .env
```

محتوای `.env`:
```env
API_BASE_URL=https://api.yourdomain.com/api
NODE_ENV=production
```

### مرحله 4: دادن دسترسی اجرا به اسکریپت‌ها

```bash
chmod +x deploy-production.sh
chmod +x docker-cleanup.sh
```

### مرحله 5: تست دیپلوی دستی

```bash
# اولین بار دستی دیپلوی کنید
./deploy-production.sh
```

اگر موفقیت‌آمیز بود، application روی `http://SERVER_IP:3000` در دسترس است.

---

## 🔐 تنظیمات GitHub

### مرحله 1: ساختن SSH Key

روی **سرور** این دستورات را اجرا کنید:

```bash
# ساختن SSH key جدید (یا استفاده از key موجود)
ssh-keygen -t ed25519 -C "github-actions" -f ~/.ssh/github_actions

# نمایش public key
cat ~/.ssh/github_actions.pub

# نمایش private key (برای GitHub Secret)
cat ~/.ssh/github_actions
```

### مرحله 2: اضافه کردن Public Key به سرور

```bash
# اضافه کردن public key به authorized_keys
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys

# تنظیم دسترسی‌ها
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### مرحله 3: اضافه کردن Secrets به GitHub

1. برو به **Repository → Settings → Secrets and variables → Actions**
2. کلیک روی **New repository secret**
3. این secrets را اضافه کن:

| Secret Name | مقدار | توضیحات |
|-------------|-------|---------|
| `SERVER_HOST` | `1.2.3.4` | IP یا دامنه سرور |
| `SERVER_USERNAME` | `user` | نام کاربری SSH |
| `SSH_PRIVATE_KEY` | محتوای `~/.ssh/github_actions` | کل محتوای private key |
| `SERVER_PORT` | `22` | پورت SSH (پیش‌فرض 22) |
| `PROJECT_PATH` | `/home/archive/iran_tournament_frontend` | مسیر پروژه روی سرور |

### مرحله 4: تست اتصال SSH

روی **کامپیوتر لوکال** تست کنید:

```bash
# ذخیره private key در فایل موقت
echo "PRIVATE_KEY_CONTENT" > /tmp/test_key
chmod 600 /tmp/test_key

# تست SSH
ssh -i /tmp/test_key user@SERVER_IP "echo 'SSH works!'"

# حذف فایل موقت
rm /tmp/test_key
```

---

## ✅ تست CI/CD

### تست 1: دیپلوی دستی از GitHub Actions

1. برو به **Actions** در repository
2. روی workflow **"Deploy to Server"** کلیک کن
3. **Run workflow** → **Run workflow** را بزن
4. منتظر بمان تا کامل شود (معمولاً 2-5 دقیقه)

### تست 2: دیپلوی خودکار با Push

```bash
# یک تغییر کوچک ایجاد کن
echo "# Test" >> README.md

# commit و push به main
git add README.md
git commit -m "test: CI/CD deployment"
git push origin main
```

بعد از push:
1. برو به **Actions** در GitHub
2. باید یک workflow جدید در حال اجرا باشد
3. منتظر بمان تا سبز شود ✅

---

## 🔧 مدیریت و نگهداری

### پاکسازی دوره‌ای با Cron

برای اجرای خودکار cleanup هر روز:

```bash
# ویرایش crontab
crontab -e

# اضافه کردن این خط (هر روز ساعت 2 صبح) - پاکسازی لاگ‌های قدیمی
0 2 * * * find /home/archive/iran_tournament_frontend/logs -name "*.log" -type f -mtime +7 -delete
```

### مانیتورینگ وضعیت

```bash
# وضعیت کانتینر
docker ps

# لاگ‌های اخیر
docker logs -f iran-tournament-frontend --tail 100

# وضعیت فضای Docker
docker system df

# مشاهده health status
docker inspect iran-tournament-frontend | grep -A 10 Health
```

### دستورات مفید

```bash
# ری‌استارت manual
docker-compose restart

# دیپلوی دستی
./deploy-production.sh

# cleanup دستی
./docker-cleanup.sh

# مشاهده لاگ‌های deployment
tail -f /var/log/docker-cleanup.log

# بررسی فضای دیسک
df -h
du -sh /var/lib/docker
```

---

## 🐛 رفع مشکلات

### مشکل 1: Deployment ناموفق

**علائم:** GitHub Action قرمز می‌شود

**راه حل:**
```bash
# بررسی لاگ‌های سرور
ssh user@server
cd /home/archive/iran_tournament_frontend
./screen-manager.sh logs

# یا مشاهده مستقیم لاگ
tail -f logs/app.log

# بررسی فضای دیسک
df -h

# بررسی وضعیت screen
./screen-manager.sh status
```

### مشکل 2: SSH Connection Failed

**علائم:** خطای "Permission denied" یا "Connection refused"

**راه حل:**
```bash
# بررسی SSH service
sudo systemctl status ssh

# بررسی authorized_keys
cat ~/.ssh/authorized_keys

# بررسی دسترسی‌ها
ls -la ~/.ssh/

# تست SSH از لوکال
ssh -vvv user@server
```

### مشکل 3: فضای دیسک پر است

**علائم:** خطای "no space left on device"

**راه حل:**
```bash
# cleanup عمیق Docker
docker system prune -a --volumes -f

# بررسی بزرگترین فایل‌ها
du -sh /var/lib/docker/*
du -h / | sort -rh | head -n 20

# حذف لاگ‌های قدیمی
sudo journalctl --vacuum-time=3d
```

### مشکل 4: Application شروع نمی‌شود

**علائم:** Container مرتب restart می‌شود

**راه حل:**
```bash
# بررسی لاگ‌ها
docker logs iran-tournament-frontend --tail 100

# بررسی فایل .env
cat .env

# تست manual build
docker-compose up --build

# بررسی health check
docker inspect iran-tournament-frontend | grep -A 10 Health
```

### مشکل 5: Port already in use

**راه حل:**
```bash
# پیدا کردن پروسه
sudo lsof -i :3000

# کشتن پروسه
sudo kill -9 PID

# یا تغییر پورت در .env و docker-compose.yml
```

---

## 📊 بهینه‌سازی‌های پیشرفته

### 1. کاهش زمان Build

در `Dockerfile`:
```dockerfile
# استفاده از cache برای npm
RUN --mount=type=cache,target=/root/.npm npm ci
```

### 2. Multi-stage Build Optimization

```dockerfile
# کپی فقط فایل‌های لازم
COPY --from=builder --chown=nodejs:nodejs /app/.output ./.output
```

### 3. استفاده از Docker BuildKit

```bash
export DOCKER_BUILDKIT=1
docker-compose build
```

### 4. محدود کردن منابع

Uncomment کردن بخش resources در `docker-compose.yml`:
```yaml
deploy:
  resources:
    limits:
      cpus: '1'
      memory: 1G
```

---

## 🎓 نکات امنیتی

1. ✅ **هرگز Private Key را commit نکنید**
2. ✅ **فایل .env را در .gitignore نگه دارید**
3. ✅ **از SSH key با passphrase استفاده کنید**
4. ✅ **دسترسی SSH را محدود کنید** (فقط از IP های مشخص)
5. ✅ **Container ها را به عنوان non-root user اجرا کنید** (✅ در Dockerfile انجام شده)
6. ✅ **فایروال را تنظیم کنید**
7. ✅ **به روز رسانی منظم** Docker و dependencies

```bash
# تنظیم فایروال
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 📚 منابع بیشتر

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [SSH Key Management](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Nuxt Deployment](https://nuxt.com/docs/getting-started/deployment)

---

## 🆘 پشتیبانی

در صورت بروز مشکل:
1. لاگ‌های GitHub Actions را بررسی کنید
2. لاگ‌های Docker را چک کنید (`docker logs`)
3. فضای دیسک را بررسی کنید (`df -h`)
4. SSH connection را تست کنید

---

<div align="center">

**✨ دیپلوی خودکار راه‌اندازی شد! ✨**

هر تغییر در `main` خودکار روی سرور اعمال می‌شود 🚀

</div>
