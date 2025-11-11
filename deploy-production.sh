#!/bin/bash

################################################################################
# اسکریپت دیپلوی Production با Screen
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
SCREEN_NAME="iran-tournament-frontend"
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

if ! command -v screen &> /dev/null; then
    log_warning "screen نصب نیست! در حال نصب..."
    sudo apt-get update && sudo apt-get install -y screen
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

# ۷. توقف application قبلی (اگر در حال اجراست)
log_info "بررسی application قبلی..."
if screen -list | grep -q "$SCREEN_NAME"; then
    log_info "توقف application قبلی..."
    screen -S "$SCREEN_NAME" -X quit || true
    sleep 3
    log_success "Application قبلی متوقف شد"
fi

# بررسی اینکه پورت 3000 آزاد باشد
if lsof -i :3000 &> /dev/null; then
    log_warning "پورت 3000 هنوز در حال استفاده است!"
    log_info "در حال kill کردن پروسه..."
    lsof -ti :3000 | xargs -r kill -9 2>/dev/null || true
    sleep 2
fi

# ۸. شروع application جدید
log_info "شروع application جدید در screen session..."

# بارگذاری متغیرهای محیطی
export NODE_ENV=production
if [ -f "$APP_DIR/.env" ]; then
    export $(cat "$APP_DIR/.env" | grep -v '^#' | grep -v '^$' | xargs)
fi

# شروع screen session
screen -dmS "$SCREEN_NAME" bash -c "
    cd '$APP_DIR'
    export NODE_ENV=production
    export PORT=\${PORT:-3000}
    export NUXT_PUBLIC_API_BASE=\${API_BASE_URL:-http://localhost:8020/api}

    echo '═══════════════════════════════════════════════════════'
    echo '🚀 Iran Tournament Frontend Starting...'
    echo '═══════════════════════════════════════════════════════'
    echo 'Time: \$(date)'
    echo 'Deploy Tag: ${DEPLOY_TAG}'
    echo 'Git Commit: ${GIT_COMMIT}'
    echo 'Working Directory: \$(pwd)'
    echo 'API URL: \$NUXT_PUBLIC_API_BASE'
    echo 'Port: \$PORT'
    echo '═══════════════════════════════════════════════════════'
    echo ''

    node .output/server/index.mjs 2>&1 | tee -a '$LOG_DIR/app.log'
"

sleep 3

# ۹. بررسی موفقیت
log_info "بررسی وضعیت application..."

if screen -list | grep -q "$SCREEN_NAME"; then
    log_success "Screen session با موفقیت ایجاد شد"

    # بررسی اینکه پورت 3000 در حال استفاده است
    sleep 5
    if lsof -i :3000 &> /dev/null; then
        log_success "Application روی پورت 3000 در حال اجراست"
    else
        log_warning "پورت 3000 هنوز فعال نشده است، لطفاً لاگ‌ها را بررسی کنید"
    fi
else
    log_error "خطا در شروع screen session!"
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
    log_info "لاگ‌های اخیر:"
    tail -n 20 "$LOG_DIR/app.log"
fi

# ۱۱. پاکسازی
log_info "پاکسازی فایل‌های موقت..."

# حذف node_modules قدیمی (اختیاری)
# پاکسازی لاگ‌های قدیمی (بیش از 7 روز)
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
log_info "📦 Screen Session: ${SCREEN_NAME}"
log_info "🌐 URL: http://localhost:3000"
log_info "🔌 API Backend: http://localhost:8020/api"
echo ""

log_success "🎉 دیپلوی با موفقیت انجام شد!"
echo ""
log_info "دستورات مفید:"
echo "  • مشاهده لاگ‌ها: ./screen-manager.sh logs"
echo "  • اتصال به session: screen -r ${SCREEN_NAME}"
echo "  • وضعیت: ./screen-manager.sh status"
echo "  • ری‌استارت: ./screen-manager.sh restart"
echo "  • توقف: ./screen-manager.sh stop"
echo "  • جدا شدن از screen: Ctrl+A ثم D"
echo ""

# نمایش لاگ‌های اخیر
log_info "لاگ‌های اخیر:"
tail -n 15 "$LOG_DIR/app.log" || log_warning "لاگ هنوز ایجاد نشده"
echo ""
