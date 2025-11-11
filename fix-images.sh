#!/bin/bash

# اسکریپت فیکس مشکل تصاویر background

echo "🔧 در حال فیکس مشکل تصاویر..."

# بررسی وجود فایل‌های تصویری
if [ ! -f ".github/screenshots/mobile_index.png" ] || [ ! -f ".github/screenshots/desktop_index.png" ]; then
    echo "❌ فایل‌های تصویری در .github/screenshots/ پیدا نشدند!"
    exit 1
fi

# ایجاد پوشه public اگر وجود نداره
mkdir -p public

# کپی فایل‌های تصویری به public
echo "📁 کپی فایل‌های تصویری به public/..."
cp .github/screenshots/mobile_index.png public/
cp .github/screenshots/desktop_index.png public/

# بررسی موفقیت
if [ -f "public/mobile_index.png" ] && [ -f "public/desktop_index.png" ]; then
    echo "✅ فایل‌های تصویری با موفقیت کپی شدند"
    ls -lh public/*.png
else
    echo "❌ خطا در کپی فایل‌ها"
    exit 1
fi

echo ""
echo "✅ فیکس کامل شد!"
echo ""
echo "⚠️  حالا باید rebuild کنی:"
echo "   npm run build"
echo ""
echo "   بعد ری‌استارت کن:"
echo "   pm2 restart iran-tournament-frontend"
echo "   یا"
echo "   PORT=3020 node .output/server/index.mjs"
