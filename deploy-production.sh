#!/bin/bash

################################################################################
# اسکریپت دیپلوی Production با مدیریت هوشمند Docker
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
IMAGE_NAME="iran-tournament-frontend"
CONTAINER_NAME="iran-tournament-frontend"
MAX_IMAGES_TO_KEEP=2  # تعداد image هایی که نگه داشته می‌شوند

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

# بررسی وجود Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker نصب نیست!"
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose نصب نیست!"
fi

# ۱. بررسی و دریافت Git commit hash برای تگ‌گذاری
log_info "دریافت اطلاعات Git..."
GIT_COMMIT=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
BUILD_DATE=$(date +%Y%m%d-%H%M%S)
IMAGE_TAG="${GIT_COMMIT}-${BUILD_DATE}"

log_success "Branch: ${GIT_BRANCH}, Commit: ${GIT_COMMIT}"

# ۲. ذخیره image فعلی برای rollback (اگر وجود داشته باشد)
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    log_info "ذخیره backup از کانتینر فعلی..."
    CURRENT_IMAGE=$(docker inspect --format='{{.Image}}' ${CONTAINER_NAME} 2>/dev/null || echo "")
    if [ ! -z "$CURRENT_IMAGE" ]; then
        docker tag $CURRENT_IMAGE ${IMAGE_NAME}:backup-$(date +%Y%m%d-%H%M%S) || true
        log_success "Backup ذخیره شد"
    fi
fi

# ۳. توقف و حذف کانتینر قبلی
log_info "توقف کانتینرهای قبلی..."
docker-compose down --remove-orphans || true
log_success "کانتینرهای قبلی متوقف شدند"

# ۴. ساخت image جدید با تگ
log_info "ساخت Docker image جدید..."
export DOCKER_BUILDKIT=1  # استفاده از BuildKit برای build سریعتر
docker build \
    --tag ${IMAGE_NAME}:${IMAGE_TAG} \
    --tag ${IMAGE_NAME}:latest \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --progress=plain \
    . || log_error "خطا در ساخت Docker image"

log_success "Image با موفقیت ساخته شد: ${IMAGE_NAME}:${IMAGE_TAG}"

# ۵. اجرای کانتینر جدید
log_info "راه‌اندازی کانتینر جدید..."
docker-compose up -d || log_error "خطا در راه‌اندازی کانتینر"

# ۶. بررسی سلامت کانتینر
log_info "بررسی وضعیت کانتینر..."
sleep 5

if docker ps | grep -q ${CONTAINER_NAME}; then
    log_success "کانتینر با موفقیت در حال اجراست"

    # نمایش لاگ‌های اولیه
    log_info "لاگ‌های اولیه کانتینر:"
    docker logs --tail 20 ${CONTAINER_NAME}
else
    log_error "کانتینر شروع نشد! در حال بررسی لاگ‌ها..."
    docker logs ${CONTAINER_NAME}
    exit 1
fi

# ۷. پاکسازی Docker (بخش مهم!)
log_warning "شروع پاکسازی Docker..."

# 7.1. حذف dangling images (image هایی که تگ ندارند)
log_info "حذف dangling images..."
docker image prune -f || true

# 7.2. نگه داشتن فقط N تا از آخرین image ها
log_info "نگه داشتن فقط ${MAX_IMAGES_TO_KEEP} image اخیر..."
OLD_IMAGES=$(docker images ${IMAGE_NAME} --format "{{.ID}}" | tail -n +$((MAX_IMAGES_TO_KEEP + 1)))
if [ ! -z "$OLD_IMAGES" ]; then
    echo "$OLD_IMAGES" | xargs -r docker rmi -f 2>/dev/null || true
    log_success "Image های قدیمی حذف شدند"
else
    log_info "Image قدیمی برای حذف وجود ندارد"
fi

# 7.3. حذف volume های استفاده نشده
log_info "پاکسازی volume های استفاده نشده..."
docker volume prune -f || true

# 7.4. حذف network های استفاده نشده
log_info "پاکسازی network های استفاده نشده..."
docker network prune -f || true

# 7.5. حذف build cache قدیمی (نگه داشتن فقط cache اخیر)
log_info "پاکسازی build cache..."
docker builder prune -f --filter "until=24h" || true

log_success "پاکسازی Docker کامل شد"

# ۸. نمایش اطلاعات فضای استفاده شده
echo ""
log_info "وضعیت فضای Docker:"
docker system df

# ۹. نمایش اطلاعات نهایی
echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║            ✅ Deployment Successful!                  ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""
log_info "🏷️  Image Tag: ${IMAGE_TAG}"
log_info "📦 Container: ${CONTAINER_NAME}"
log_info "🔗 Git Commit: ${GIT_COMMIT}"
log_info "📅 Build Date: ${BUILD_DATE}"
echo ""

# ۱۰. تست سلامت
log_info "تست endpoint..."
sleep 3
if curl -f http://localhost:3000 -s -o /dev/null; then
    log_success "✅ Application is healthy!"
else
    log_warning "⚠️  Application might not be ready yet. Check logs: docker logs ${CONTAINER_NAME}"
fi

echo ""
log_success "🎉 دیپلوی با موفقیت انجام شد!"
echo ""
log_info "دستورات مفید:"
echo "  • مشاهده لاگ‌ها: docker logs -f ${CONTAINER_NAME}"
echo "  • ری‌استارت: docker-compose restart"
echo "  • توقف: docker-compose down"
echo "  • وضعیت: docker ps"
echo ""
