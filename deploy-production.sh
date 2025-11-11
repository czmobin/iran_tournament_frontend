#!/bin/bash

################################################################################
# اسکریپت دیپلوی Production با PM2
# این اسکریپت به صورت خودکار توسط GitHub Actions اجرا می‌شود
################################################################################

set -e  # توقف در صورت بروز خطا

# رنگ‌ها برای خروجی
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# تنظیمات
APP_NAME="iran-tournament-frontend"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$APP_DIR/logs"
BACKUP_DIR="$APP_DIR/backups"

# توابع کمکی
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# نمایش banner
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║     🚀 Iran Tournament Frontend Deployment           ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# بررسی وجود ابزارهای لازم
if ! command -v node &> /dev/null; then
    log_error "Node.js نصب نیست!"
fi

if ! command -v npm &> /dev/null; then
    log_error "npm نصب نیست!"
fi

if ! command -v pm2 &> /dev/null; then
    log_warning "PM2 نصب نیست! در حال نصب..."
    npm install -g pm2 || log_error "نصب PM2 ناموفق بود! لطفاً دستی نصب کنید: npm install -g pm2"
    log_success "PM2 با موفقیت نصب شد"
fi

# ایجاد دایرکتوری‌های لازم
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

# ۱. دریافت اطلاعات Git
log_info "دریافت اطلاعات Git..."
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
DEPLOY_DATE=$(date +%Y%m%d-%H%M%S)
DEPLOY_TAG="${GIT_COMMIT}-${DEPLOY_DATE}"

log_success "Branch: ${GIT_BRANCH}, Commit: ${GIT_COMMIT}"

# ۲. Backup فایل‌های قبلی
if [ -d "$APP_DIR/.output" ]; then
    log_info "ایجاد backup از build قبلی..."
    BACKUP_FILE="$BACKUP_DIR/output-backup-${DEPLOY_DATE}.tar.gz"
    tar -czf "$BACKUP_FILE" .output 2>/dev/null || true
    log_success "Backup ذخیره شد: $BACKUP_FILE"

    # نگه داشتن فقط 3 backup آخر
    cd "$BACKUP_DIR"
    ls -t | tail -n +4 | xargs -r rm -f
    cd "$APP_DIR"
fi

# ۳. پاک کردن cache ها
log_info "پاک کردن cache ها و build های قبلی..."
rm -rf node_modules/.cache
rm -rf .nuxt
rm -rf .output
log_success "Cache ها پاک شدند"

# ۴. نصب dependencies
log_info "نصب dependencies..."
npm ci || npm install || log_error "خطا در نصب dependencies"
log_success "Dependencies نصب شدند"

# ۵. Build پروژه
log_info "ساخت production build..."
# افزایش حافظه Node.js برای build
export NODE_OPTIONS="--max-old-space-size=2048"
npm run build 2>&1 | tee "$LOG_DIR/build.log" || {
    log_error "خطا در build پروژه!"
    echo ""
    echo "══════════════════════════════════════════════════"
    echo "آخرین 30 خط از لاگ build:"
    echo "══════════════════════════════════════════════════"
    tail -n 30 "$LOG_DIR/build.log"
    exit 1
}
log_success "Build با موفقیت ساخته شد"

# ۶. بررسی فایل .env
if [ ! -f "$APP_DIR/.env" ]; then
    log_warning "فایل .env وجود ندارد!"
    if [ -f "$APP_DIR/.env.example" ]; then
        log_info "کپی از .env.example..."
        cp "$APP_DIR/.env.example" "$APP_DIR/.env"
        log_warning "لطفاً فایل .env را ویرایش کنید!"
    fi
fi

# بارگذاری متغیرهای محیطی
if [ -f "$APP_DIR/.env" ]; then
    export $(cat "$APP_DIR/.env" | grep -v '^#' | grep -v '^$' | xargs)
fi

# ۷. مدیریت PM2
log_info "مدیریت PM2 process..."

# بررسی اگر قبلاً اجرا شده
if pm2 describe iran-tournament-frontend &> /dev/null; then
    log_info "ری‌استارت application با PM2..."
    pm2 restart iran-tournament-frontend --update-env || log_error "خطا در ری‌استارت PM2"
    log_success "Application ری‌استارت شد"
else
    log_info "شروع application با PM2..."
    pm2 start ecosystem.config.cjs || log_error "خطا در شروع PM2"
    log_success "Application شروع شد"
fi

# ذخیره تنظیمات PM2
pm2 save

# ۸. بررسی وضعیت
log_info "بررسی وضعیت PM2..."
sleep 3

pm2 describe iran-tournament-frontend | grep -E "status|restart|uptime" || true

if pm2 describe iran-tournament-frontend | grep -q "online"; then
    log_success "Application به صورت online در حال اجراست"
else
    log_error "Application شروع نشد!"
fi

# ۹. بررسی پورت
log_info "بررسی پورت 3000..."
sleep 3

if lsof -i :3000 &> /dev/null; then
    log_success "Application روی پورت 3000 در حال اجراست"
else
    log_warning "پورت 3000 هنوز فعال نشده است"
    log_info "نمایش لاگ‌های PM2:"
    pm2 logs iran-tournament-frontend --lines 30 --nostream
fi

# ۱۰. تست سلامت
log_info "تست endpoint..."
sleep 3

HEALTH_CHECK_ATTEMPTS=0
MAX_ATTEMPTS=10

while [ $HEALTH_CHECK_ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    if curl -f http://localhost:3000 -s -o /dev/null 2>&1; then
        log_success "✅ Application is healthy!"
        break
    else
        HEALTH_CHECK_ATTEMPTS=$((HEALTH_CHECK_ATTEMPTS + 1))
        if [ $HEALTH_CHECK_ATTEMPTS -lt $MAX_ATTEMPTS ]; then
            log_info "تلاش $HEALTH_CHECK_ATTEMPTS از $MAX_ATTEMPTS - صبر کنید..."
            sleep 3
        fi
    fi
done

if [ $HEALTH_CHECK_ATTEMPTS -eq $MAX_ATTEMPTS ]; then
    log_warning "⚠️  Application بعد از $MAX_ATTEMPTS تلاش پاسخ نداد"
    log_info "لاگ‌های PM2:"
    pm2 logs iran-tournament-frontend --lines 30 --nostream
fi

# ۱۱. پاکسازی
log_info "پاکسازی فایل‌های موقت..."
find "$LOG_DIR" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
log_success "پاکسازی انجام شد"

# ۱۲. نمایش اطلاعات نهایی
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║            ✅ Deployment Successful!                  ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
log_info "🏷️  Deploy Tag: ${DEPLOY_TAG}"
log_info "🔗 Git Commit: ${GIT_COMMIT}"
log_info "📅 Deploy Date: ${DEPLOY_DATE}"
log_info "📦 PM2 Process: iran-tournament-frontend"
log_info "🌐 URL: http://localhost:3000"
log_info "🔌 API Backend: http://localhost:8020/api"
echo ""

log_success "🎉 دیپلوی با موفقیت انجام شد!"
echo ""
log_info "دستورات مفید:"
echo "  • مشاهده وضعیت: pm2 status"
echo "  • مشاهده لاگ‌ها: pm2 logs iran-tournament-frontend"
echo "  • ری‌استارت: pm2 restart iran-tournament-frontend"
echo "  • توقف: pm2 stop iran-tournament-frontend"
echo "  • مانیتورینگ: pm2 monit"
echo ""

# نمایش وضعیت PM2
pm2 list
