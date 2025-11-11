#!/bin/bash

################################################################################
# اسکریپت رفع مشکلات Build
# استفاده: ./fix-build.sh
################################################################################

set -e

# رنگ‌ها
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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
}

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║        🔧 Build Problem Fixer                         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# ۱. بررسی Node.js version
log_info "بررسی نسخه Node.js..."
NODE_VERSION=$(node --version)
log_success "Node.js: $NODE_VERSION"

if [[ "$NODE_VERSION" < "v18" ]]; then
    log_warning "نسخه Node.js شما قدیمی است! حداقل نسخه 18 نیاز است."
    log_info "برای آپدیت:"
    echo "  curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -"
    echo "  sudo apt-get install -y nodejs"
fi

# ۲. پاک کردن کامل cache ها
log_info "پاک کردن کامل cache ها..."
rm -rf node_modules
rm -rf .nuxt
rm -rf .output
rm -rf .gen
rm -rf node_modules/.cache
rm -rf ~/.npm/_cacache
log_success "Cache ها پاک شدند"

# ۳. پاک کردن package-lock.json
log_info "پاک کردن package-lock.json..."
rm -f package-lock.json
log_success "package-lock.json پاک شد"

# ۴. نصب مجدد dependencies
log_info "نصب مجدد dependencies (ممکن است چند دقیقه طول بکشد)..."
npm install || {
    log_error "خطا در نصب dependencies!"
    log_info "در حال تلاش با npm cache clean..."
    npm cache clean --force
    npm install || log_error "نصب ناموفق بود!"
}
log_success "Dependencies نصب شدند"

# ۵. بررسی فضای دیسک
log_info "بررسی فضای دیسک..."
DISK_USAGE=$(df -h . | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    log_warning "⚠️  فضای دیسک ${DISK_USAGE}% پر است!"
    log_info "پاکسازی فایل‌های موقت..."
    sudo apt-get clean
    sudo journalctl --vacuum-time=3d
fi

# ۶. بررسی حافظه
log_info "بررسی حافظه..."
FREE_MEM=$(free -m | awk 'NR==2 {print $7}')
log_info "حافظه آزاد: ${FREE_MEM}MB"

if [ "$FREE_MEM" -lt 500 ]; then
    log_warning "حافظه کم است! ممکن است build با مشکل مواجه شود."
    log_info "افزایش swap یا استفاده از ماشین قوی‌تر توصیه می‌شود."
fi

# ۷. تست build
log_info "تست build (با حافظه اضافی)..."
export NODE_OPTIONS="--max-old-space-size=2048"

echo ""
log_info "شروع build - لطفاً صبر کنید..."
echo "═══════════════════════════════════════════════════════"

if npm run build 2>&1 | tee build-test.log; then
    echo "═══════════════════════════════════════════════════════"
    log_success "✅ Build موفقیت‌آمیز بود!"
    log_info "فایل build.log ذخیره شد"

    # نمایش اطلاعات build
    if [ -d ".output" ]; then
        OUTPUT_SIZE=$(du -sh .output | cut -f1)
        log_info "اندازه output: $OUTPUT_SIZE"
    fi

    rm -f build-test.log
else
    echo "═══════════════════════════════════════════════════════"
    log_error "❌ Build ناموفق بود!"
    echo ""
    log_info "آخرین 50 خط از لاگ:"
    echo "═══════════════════════════════════════════════════════"
    tail -n 50 build-test.log
    echo "═══════════════════════════════════════════════════════"
    echo ""
    log_info "لاگ کامل در build-test.log ذخیره شد"
    log_info "برای مشاهده: cat build-test.log"
    exit 1
fi

echo ""
log_success "🎉 همه چیز درست شد!"
echo ""
log_info "مراحل بعدی:"
echo "  1. برای اجرا: ./screen-manager.sh start"
echo "  2. یا برای دیپلوی کامل: ./deploy-production.sh"
echo ""
