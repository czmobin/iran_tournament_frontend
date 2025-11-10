#!/bin/bash

################################################################################
# اسکریپت پاکسازی Docker - برای اجرای دوره‌ای با Cron
# این اسکریپت فضای دیسک را آزاد می‌کند و از پر شدن سرور جلوگیری می‌کند
################################################################################

set -e

# رنگ‌ها
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}ℹ️  $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $(date '+%Y-%m-%d %H:%M:%S') - $1${NC}"
}

echo "╔═══════════════════════════════════════════════════════╗"
echo "║        🧹 Docker Cleanup Script                       ║"
echo "╚═══════════════════════════════════════════════════════╝"

# نمایش فضای قبل از cleanup
log_info "وضعیت فضای Docker قبل از cleanup:"
docker system df

echo ""
log_info "شروع پاکسازی..."

# ۱. حذف کانتینرهای متوقف شده
log_info "حذف کانتینرهای متوقف شده..."
STOPPED_CONTAINERS=$(docker ps -a -q -f status=exited 2>/dev/null | wc -l)
if [ "$STOPPED_CONTAINERS" -gt 0 ]; then
    docker container prune -f
    log_success "تعداد ${STOPPED_CONTAINERS} کانتینر متوقف شده حذف شد"
else
    log_info "کانتینر متوقف شده‌ای وجود ندارد"
fi

# ۲. حذف image های بدون تگ (dangling)
log_info "حذف dangling images..."
DANGLING_IMAGES=$(docker images -f "dangling=true" -q 2>/dev/null | wc -l)
if [ "$DANGLING_IMAGES" -gt 0 ]; then
    docker image prune -f
    log_success "تعداد ${DANGLING_IMAGES} dangling image حذف شد"
else
    log_info "Dangling image وجود ندارد"
fi

# ۳. حذف image های قدیمی (بیش از 7 روز)
log_info "حذف image های قدیمی‌تر از 7 روز..."
OLD_IMAGES=$(docker images --format "{{.ID}}" --filter "before=$(docker images -q | head -n 3 | tail -n 1)" 2>/dev/null | wc -l)
if [ "$OLD_IMAGES" -gt 0 ]; then
    docker image prune -a -f --filter "until=168h"  # 7 days
    log_success "Image های قدیمی حذف شدند"
else
    log_info "Image قدیمی وجود ندارد"
fi

# ۴. حذف volume های استفاده نشده
log_info "حذف volume های استفاده نشده..."
UNUSED_VOLUMES=$(docker volume ls -qf dangling=true 2>/dev/null | wc -l)
if [ "$UNUSED_VOLUMES" -gt 0 ]; then
    docker volume prune -f
    log_success "تعداد ${UNUSED_VOLUMES} volume استفاده نشده حذف شد"
else
    log_info "Volume استفاده نشده‌ای وجود ندارد"
fi

# ۵. حذف network های استفاده نشده
log_info "حذف network های استفاده نشده..."
docker network prune -f > /dev/null 2>&1
log_success "Network های استفاده نشده حذف شدند"

# ۶. پاکسازی build cache
log_info "پاکسازی build cache قدیمی‌تر از 24 ساعت..."
docker builder prune -f --filter "until=24h" > /dev/null 2>&1
log_success "Build cache پاک شد"

# ۷. حذف image های none:none (معمولاً از build های ناموفق)
log_info "حذف image های <none>:<none>..."
NONE_IMAGES=$(docker images | grep '<none>' | awk '{print $3}' | wc -l)
if [ "$NONE_IMAGES" -gt 0 ]; then
    docker images | grep '<none>' | awk '{print $3}' | xargs -r docker rmi -f 2>/dev/null || true
    log_success "Image های <none>:<none> حذف شدند"
else
    log_info "Image <none>:<none> وجود ندارد"
fi

# ۸. نمایش فضای بعد از cleanup
echo ""
log_info "وضعیت فضای Docker بعد از cleanup:"
docker system df

# ۹. محاسبه فضای آزاد شده
echo ""
log_success "✅ پاکسازی Docker با موفقیت انجام شد!"

# ۱۰. هشدار در صورت پر بودن دیسک
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    log_warning "⚠️  فضای دیسک ${DISK_USAGE}% پر است! بررسی بیشتر نیاز است."
    echo ""
    log_info "بزرگترین دایرکتوری‌ها:"
    du -h --max-depth=1 /var/lib/docker 2>/dev/null | sort -rh | head -n 10 || true
else
    log_success "فضای دیسک: ${DISK_USAGE}% - وضعیت خوب است"
fi

echo ""
log_info "💡 نکته: برای cleanup عمیق‌تر می‌توانید استفاده کنید:"
echo "  docker system prune -a --volumes -f"
echo "  (این دستور تمام image ها، container ها و volume های استفاده نشده را حذف می‌کند)"
echo ""
