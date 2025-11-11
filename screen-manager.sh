#!/bin/bash

################################################################################
# اسکریپت مدیریت Screen برای Iran Tournament Frontend
# استفاده: ./screen-manager.sh [start|stop|restart|status|logs]
################################################################################

set -e

# تنظیمات
SCREEN_NAME="iran-tournament-frontend"
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$APP_DIR/logs/app.log"
PID_FILE="$APP_DIR/.app.pid"

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

# ایجاد دایرکتوری logs
mkdir -p "$APP_DIR/logs"

# تابع start
start_app() {
    log_info "بررسی وضعیت application..."

    # بررسی اینکه آیا قبلاً در حال اجراست
    if screen -list | grep -q "$SCREEN_NAME"; then
        log_warning "Application در حال حاضر در حال اجراست!"
        log_info "از 'screen -r $SCREEN_NAME' برای اتصال استفاده کنید"
        return 0
    fi

    log_info "شروع application در screen session..."

    # بارگذاری متغیرهای محیطی
    if [ -f "$APP_DIR/.env" ]; then
        export $(cat "$APP_DIR/.env" | grep -v '^#' | xargs)
    fi

    # شروع screen session
    screen -dmS "$SCREEN_NAME" bash -c "
        cd '$APP_DIR'
        export NODE_ENV=production
        export PORT=\${PORT:-3000}
        export NUXT_PUBLIC_API_BASE=\${API_BASE_URL:-http://localhost:8020/api}

        echo '🚀 Starting Iran Tournament Frontend...'
        echo 'Time: \$(date)'
        echo 'Working Directory: \$(pwd)'
        echo 'API URL: \$NUXT_PUBLIC_API_BASE'
        echo 'Port: \$PORT'
        echo '---'

        node .output/server/index.mjs 2>&1 | tee -a '$LOG_FILE'
    "

    sleep 2

    # بررسی موفقیت
    if screen -list | grep -q "$SCREEN_NAME"; then
        log_success "Application با موفقیت شروع شد!"
        log_info "Screen session: $SCREEN_NAME"
        log_info "برای مشاهده logs: ./screen-manager.sh logs"
        log_info "برای اتصال به session: screen -r $SCREEN_NAME"
        log_info "برای جدا شدن از session: Ctrl+A ثم D"

        # ذخیره PID (تقریبی)
        SCREEN_PID=$(screen -list | grep "$SCREEN_NAME" | awk '{print $1}' | cut -d. -f1)
        echo "$SCREEN_PID" > "$PID_FILE"
    else
        log_error "خطا در شروع application!"
        log_info "لاگ‌ها را بررسی کنید: tail -f $LOG_FILE"
        exit 1
    fi
}

# تابع stop
stop_app() {
    log_info "توقف application..."

    if ! screen -list | grep -q "$SCREEN_NAME"; then
        log_warning "Application در حال اجرا نیست!"
        return 0
    fi

    # ارسال Ctrl+C به screen session
    screen -S "$SCREEN_NAME" -X quit

    sleep 2

    # بررسی توقف
    if ! screen -list | grep -q "$SCREEN_NAME"; then
        log_success "Application با موفقیت متوقف شد!"
        rm -f "$PID_FILE"
    else
        log_warning "Application هنوز در حال اجراست، تلاش برای kill force..."
        screen -S "$SCREEN_NAME" -X kill
        rm -f "$PID_FILE"
        log_success "Application به اجبار متوقف شد!"
    fi
}

# تابع restart
restart_app() {
    log_info "ری‌استارت application..."
    stop_app
    sleep 2
    start_app
}

# تابع status
show_status() {
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  📊 وضعیت Iran Tournament Frontend"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if screen -list | grep -q "$SCREEN_NAME"; then
        log_success "Status: در حال اجرا ✅"
        echo ""
        echo "Screen Sessions:"
        screen -list | grep "$SCREEN_NAME" || true
        echo ""

        if [ -f "$PID_FILE" ]; then
            PID=$(cat "$PID_FILE")
            echo "PID: $PID"
        fi

        # بررسی پورت
        if command -v lsof &> /dev/null; then
            PORT_INFO=$(lsof -i :3000 2>/dev/null | grep LISTEN || echo "پورت 3000 در حال استفاده نیست")
            echo "Port 3000: $PORT_INFO"
        fi

        echo ""
        log_info "برای اتصال: screen -r $SCREEN_NAME"
        log_info "برای مشاهده logs: ./screen-manager.sh logs"
    else
        log_error "Status: متوقف ❌"
    fi

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# تابع logs
show_logs() {
    if [ -f "$LOG_FILE" ]; then
        log_info "نمایش 50 خط آخر لاگ (Ctrl+C برای خروج)..."
        echo ""
        tail -f -n 50 "$LOG_FILE"
    else
        log_warning "فایل لاگ وجود ندارد: $LOG_FILE"
    fi
}

# تابع attach
attach_screen() {
    if screen -list | grep -q "$SCREEN_NAME"; then
        log_info "اتصال به screen session..."
        log_info "برای جدا شدن: Ctrl+A ثم D"
        sleep 1
        screen -r "$SCREEN_NAME"
    else
        log_error "Screen session وجود ندارد!"
        log_info "ابتدا با './screen-manager.sh start' application را شروع کنید"
    fi
}

# Main
case "$1" in
    start)
        start_app
        ;;
    stop)
        stop_app
        ;;
    restart)
        restart_app
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    attach)
        attach_screen
        ;;
    *)
        echo "استفاده: $0 {start|stop|restart|status|logs|attach}"
        echo ""
        echo "دستورات:"
        echo "  start   - شروع application"
        echo "  stop    - توقف application"
        echo "  restart - ری‌استارت application"
        echo "  status  - نمایش وضعیت"
        echo "  logs    - نمایش لاگ‌ها"
        echo "  attach  - اتصال به screen session"
        exit 1
        ;;
esac

exit 0
