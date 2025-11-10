#!/bin/bash

# اسکریپت دیپلوی خودکار Iran Tournament Frontend
# استفاده: ./deploy.sh [pm2|docker]

set -e

DEPLOY_METHOD=${1:-pm2}

echo "🚀 شروع فرآیند دیپلوی..."
echo "📦 روش دیپلوی: $DEPLOY_METHOD"
echo ""

# رنگ‌ها برای خروجی
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# تابع برای نمایش پیام موفقیت
success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# تابع برای نمایش پیام اطلاعاتی
info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# تابع برای نمایش پیام خطا
error() {
    echo -e "${RED}✗ $1${NC}"
    exit 1
}

# بررسی وجود git
if ! command -v git &> /dev/null; then
    error "Git نصب نیست"
fi

# گرفتن آخرین تغییرات
info "دریافت آخرین تغییرات از Git..."
git pull || error "خطا در دریافت تغییرات از Git"
success "تغییرات دریافت شد"

# نصب/بروزرسانی dependencies
info "نصب/بروزرسانی dependencies..."
npm install || error "خطا در نصب dependencies"
success "Dependencies نصب شد"

# ساخت پروژه
info "ساخت نسخه production..."
npm run build || error "خطا در ساخت پروژه"
success "پروژه ساخته شد"

# دیپلوی بر اساس روش انتخاب شده
if [ "$DEPLOY_METHOD" = "docker" ]; then
    info "دیپلوی با Docker..."

    if ! command -v docker &> /dev/null; then
        error "Docker نصب نیست"
    fi

    # توقف کانتینرهای قبلی
    docker-compose down

    # ساخت و اجرای کانتینر جدید
    docker-compose up -d --build || error "خطا در اجرای Docker"

    success "Docker کانتینر با موفقیت راه‌اندازی شد"

    # نمایش لاگ‌ها
    info "نمایش لاگ‌های Docker (Ctrl+C برای خروج)..."
    docker-compose logs -f

elif [ "$DEPLOY_METHOD" = "pm2" ]; then
    info "دیپلوی با PM2..."

    if ! command -v pm2 &> /dev/null; then
        error "PM2 نصب نیست. برای نصب: npm install -g pm2"
    fi

    # ری‌استارت PM2
    if pm2 describe iran-tournament-frontend &> /dev/null; then
        info "ری‌استارت اپلیکیشن..."
        pm2 restart iran-tournament-frontend || error "خطا در ری‌استارت PM2"
    else
        info "شروع اپلیکیشن با PM2..."
        pm2 start ecosystem.config.cjs || error "خطا در شروع PM2"
    fi

    # ذخیره تنظیمات PM2
    pm2 save

    success "PM2 با موفقیت راه‌اندازی شد"

    # نمایش وضعیت
    pm2 status

    info "برای مشاهده لاگ‌ها: pm2 logs iran-tournament-frontend"

else
    error "روش دیپلوی نامعتبر. از 'pm2' یا 'docker' استفاده کنید"
fi

echo ""
success "🎉 دیپلوی با موفقیت انجام شد!"
echo ""
info "برای تست: curl http://localhost:3000"
