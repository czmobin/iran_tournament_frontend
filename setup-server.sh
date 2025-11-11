#!/bin/bash

################################################################################
# اسکریپت تنظیم فرانت روی سرور
# این اسکریپت باید روی سرور اجرا بشه
################################################################################

set -e

# رنگ‌ها
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║     🔧 تنظیم Iran Tournament Frontend روی سرور       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo ""

# دریافت IP سرور
echo -e "${BLUE}🌐 در حال تشخیص IP سرور...${NC}"
SERVER_IP=$(hostname -I | awk '{print $1}' 2>/dev/null || echo "")

if [ -z "$SERVER_IP" ]; then
    # روش دوم
    SERVER_IP=$(ip route get 1 | awk '{print $7;exit}' 2>/dev/null || echo "")
fi

if [ -z "$SERVER_IP" ]; then
    echo -e "${RED}❌ نتونستم IP سرور رو تشخیص بدم!${NC}"
    echo -e "${YELLOW}IP سرور خودت رو وارد کن (مثلاً 185.204.197.167):${NC}"
    read -p "IP: " SERVER_IP
fi

echo -e "${GREEN}✅ IP سرور: $SERVER_IP${NC}"
echo ""

# ایجاد فایل .env
echo -e "${BLUE}📝 در حال ایجاد فایل .env...${NC}"

cat > .env << EOF
# آدرس API بکند (IP سرور - پورت 8020)
API_BASE_URL=http://${SERVER_IP}:8020/api

# پورت اپلیکیشن فرانت‌اند
PORT=3020

# محیط اجرا
NODE_ENV=production
EOF

echo -e "${GREEN}✅ فایل .env ایجاد شد:${NC}"
cat .env
echo ""

# کپی تصاویر
echo -e "${BLUE}🖼️  در حال کپی تصاویر background...${NC}"

if [ ! -f ".github/screenshots/mobile_index.png" ] || [ ! -f ".github/screenshots/desktop_index.png" ]; then
    echo -e "${RED}❌ فایل‌های تصویری در .github/screenshots/ پیدا نشدند!${NC}"
    echo -e "${YELLOW}⚠️  ادامه می‌دم ولی ممکنه تصاویر background لود نشن${NC}"
else
    mkdir -p public
    cp .github/screenshots/mobile_index.png public/ 2>/dev/null || true
    cp .github/screenshots/desktop_index.png public/ 2>/dev/null || true
    echo -e "${GREEN}✅ تصاویر کپی شدند${NC}"
fi
echo ""

# نصب dependencies
echo -e "${BLUE}📦 نصب dependencies...${NC}"
npm install
echo ""

# Build با environment variable
echo -e "${BLUE}🔨 در حال build پروژه...${NC}"
echo -e "${YELLOW}⏳ این کار ممکنه چند دقیقه طول بکشه...${NC}"

# Export کردن متغیرها قبل از build
export API_BASE_URL="http://${SERVER_IP}:8020/api"
export PORT=3020
export NODE_ENV=production

npm run build
echo ""

echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ تنظیمات با موفقیت انجام شد!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""

# بررسی نهایی
echo -e "${BLUE}📋 بررسی نهایی:${NC}"
echo ""
echo "  ✓ فایل .env ایجاد شد"
echo "  ✓ API Base URL: http://${SERVER_IP}:8020/api"
echo "  ✓ Dependencies نصب شدند"
echo "  ✓ پروژه build شد"
echo ""

# چک کردن فایل‌های build
if [ -d ".output/public" ]; then
    echo "  ✓ پوشه .output/public موجود است"
    if [ -f ".output/public/mobile_index.png" ]; then
        echo "  ✓ فایل mobile_index.png در output موجود است"
    fi
    if [ -f ".output/public/desktop_index.png" ]; then
        echo "  ✓ فایل desktop_index.png در output موجود است"
    fi
fi
echo ""

echo -e "${YELLOW}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  🚀 مرحله بعد: اجرای اپلیکیشن                        ║${NC}"
echo -e "${YELLOW}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo "برای اجرا یکی از روش‌های زیر رو استفاده کن:"
echo ""
echo "  1️⃣  با PM2 (توصیه می‌شود):"
echo "      PORT=3020 pm2 start .output/server/index.mjs --name iran-tournament-frontend"
echo "      pm2 save"
echo ""
echo "  2️⃣  با Screen:"
echo "      screen -S iran-frontend"
echo "      PORT=3020 node .output/server/index.mjs"
echo "      # Ctrl+A سپس D برای detach"
echo ""
echo "  3️⃣  مستقیم (برای تست):"
echo "      PORT=3020 node .output/server/index.mjs"
echo ""
echo -e "${GREEN}🌐 بعد از اجرا، سایت روی این آدرس در دسترسه:${NC}"
echo -e "${GREEN}   http://${SERVER_IP}:3020${NC}"
echo ""
