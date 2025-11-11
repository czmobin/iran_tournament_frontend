#!/bin/bash

################################################################################
# اسکریپت Build و آماده‌سازی کد
# فقط کد رو build می‌کنه، اجرا نمی‌کنه
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
    exit 1
}

# Banner
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║        🔨 Build & Deploy Code                         ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$APP_DIR/logs"
BACKUP_DIR="$APP_DIR/backups"

# بررسی Node.js
if ! command -v node &> /dev/null; then
    log_error "Node.js نصب نیست!"
fi

if ! command -v npm &> /dev/null; then
    log_error "npm نصب نیست!"
fi

# ایجاد دایرکتوری‌ها
mkdir -p "$LOG_DIR"
mkdir -p "$BACKUP_DIR"

# اطلاعات Git
log_info "اطلاعات deploy..."
GIT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
DEPLOY_DATE=$(date +%Y%m%d-%H%M%S)

log_success "Branch: ${GIT_BRANCH}, Commit: ${GIT_COMMIT}"

# Backup
if [ -d "$APP_DIR/.output" ]; then
    log_info "Backup از build قبلی..."
    BACKUP_FILE="$BACKUP_DIR/output-backup-${DEPLOY_DATE}.tar.gz"
    tar -czf "$BACKUP_FILE" .output 2>/dev/null || true
    log_success "Backup: $BACKUP_FILE"

    cd "$BACKUP_DIR"
    ls -t | tail -n +4 | xargs -r rm -f
    cd "$APP_DIR"
fi

# پاک کردن cache
log_info "پاک کردن cache..."
rm -rf node_modules/.cache
rm -rf .nuxt
rm -rf .output
log_success "Cache پاک شد"

# نصب dependencies
log_info "نصب dependencies..."
npm ci || npm install || log_error "خطا در نصب dependencies"
log_success "Dependencies نصب شد"

# Build
log_info "Build پروژه..."
export NODE_OPTIONS="--max-old-space-size=2048"
npm run build 2>&1 | tee "$LOG_DIR/build.log" || {
    log_error "خطا در build!"
    echo ""
    echo "══════════════════════════════════════════════════"
    echo "آخرین 30 خط لاگ:"
    echo "══════════════════════════════════════════════════"
    tail -n 30 "$LOG_DIR/build.log"
    exit 1
}
log_success "Build موفق"

# بررسی .env
if [ ! -f "$APP_DIR/.env" ]; then
    log_warning "فایل .env وجود ندارد!"
    if [ -f "$APP_DIR/.env.example" ]; then
        log_info "کپی .env.example..."
        cp "$APP_DIR/.env.example" "$APP_DIR/.env"
        log_warning "فایل .env را ویرایش کنید"
    fi
fi

# پاکسازی
log_info "پاکسازی..."
find "$LOG_DIR" -name "*.log" -type f -mtime +7 -delete 2>/dev/null || true
log_success "پاکسازی انجام شد"

# نتیجه
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║              ✅ Build Successful!                     ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
log_info "📦 Build: .output/server/index.mjs"
log_info "🔗 Commit: ${GIT_COMMIT}"
log_info "📅 Date: ${DEPLOY_DATE}"
echo ""

log_success "🎉 کد آماده است!"
echo ""
log_info "برای اجرا:"
echo "  • با PM2: pm2 start ecosystem.config.cjs"
echo "  • یا مستقیم: node .output/server/index.mjs"
echo ""
