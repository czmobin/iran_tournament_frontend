# تنظیمات بکند Django برای اتصال به Nuxt Frontend

## ⚠️ مشکل CORS

وقتی فرانت روی پورت 3020 و بکند روی پورت 8020 هستن، باید CORS رو توی Django تنظیم کنی.

## 📦 نصب django-cors-headers

```bash
# توی محیط مجازی Django
pip install django-cors-headers
```

## ⚙️ تنظیمات settings.py

به فایل `settings.py` بکند Django برو و این تغییرات رو اعمال کن:

### 1. اضافه کردن به INSTALLED_APPS

```python
INSTALLED_APPS = [
    # ...
    'corsheaders',
    # ...
]
```

### 2. اضافه کردن به MIDDLEWARE (در ابتدای لیست)

```python
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # <-- اضافه کن (در ابتدا)
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # ...
]
```

### 3. تنظیمات CORS

به انتهای فایل `settings.py` اضافه کن:

```python
# CORS Settings
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3020",
    "http://127.0.0.1:3020",
]

# یا اگه میخوای همه origin ها مجاز باشن (فقط برای development):
# CORS_ALLOW_ALL_ORIGINS = True

CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_METHODS = [
    'DELETE',
    'GET',
    'OPTIONS',
    'PATCH',
    'POST',
    'PUT',
]

CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]
```

### 4. اگه از Session/Cookie استفاده می‌کنی

```python
SESSION_COOKIE_SAMESITE = 'Lax'
CSRF_COOKIE_SAMESITE = 'Lax'

# اگه فرانت روی دامین متفاوت هست:
SESSION_COOKIE_DOMAIN = None
CSRF_COOKIE_DOMAIN = None
```

## 🔄 ری‌استارت بکند

بعد از تغییرات، بکند رو ری‌استارت کن:

```bash
# اگه با screen اجرا کردی:
screen -r your-backend-screen-name
# Ctrl+C برای توقف
python manage.py runserver 0.0.0.0:8020

# یا اگه با systemd یا PM2 اجرا کردی، ری‌استارت کن
```

## ✅ تست اتصال

بعد از تنظیمات:

1. مطمئن شو بکند روی `0.0.0.0:8020` در حال اجرا هست
2. فرانت رو روی پورت 3020 بالا بیار
3. توی مرورگر console رو باز کن و بررسی کن ارور CORS نداشته باشه

## 🔍 دیباگ

اگه هنوز مشکل داری، لاگ‌های Django رو چک کن:

```bash
# توی مرورگر:
# F12 -> Network -> یه request به API بزن -> ببین چه ارور میده

# توی بکند:
# لاگ‌های Django رو ببین تا ببینی request میاد یا نه
```

## 🌐 تنظیمات Production (با دامین واقعی)

اگه روی سرور production با دامین واقعی هستی:

```python
CORS_ALLOWED_ORIGINS = [
    "https://your-domain.com",
    "http://your-domain.com",
]

# و اگه با nginx کار می‌کنی:
CSRF_TRUSTED_ORIGINS = [
    "https://your-domain.com",
    "http://your-domain.com",
]
```
