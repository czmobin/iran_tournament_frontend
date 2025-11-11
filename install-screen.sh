#!/bin/bash

################################################################################
# اسکریپت نصب Screen
# استفاده: ./install-screen.sh
################################################################################

set -e

echo "🔧 نصب Screen برای مدیریت session..."
echo ""

# بررسی اینکه قبلاً نصب شده یا نه
if command -v screen &> /dev/null; then
    echo "✅ Screen از قبل نصب شده است!"
    screen -v
    exit 0
fi

# تشخیص OS
if [ -f /etc/debian_version ]; then
    echo "📦 در حال نصب screen روی Debian/Ubuntu..."
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get update -qq
    sudo apt-get install -y screen
elif [ -f /etc/redhat-release ]; then
    echo "📦 در حال نصب screen روی RedHat/CentOS..."
    sudo yum install -y screen
else
    echo "❌ سیستم عامل شناسایی نشد!"
    echo "لطفاً screen را دستی نصب کنید"
    exit 1
fi

# بررسی نصب موفق
if command -v screen &> /dev/null; then
    echo ""
    echo "✅ Screen با موفقیت نصب شد!"
    screen -v
else
    echo ""
    echo "❌ نصب screen ناموفق بود!"
    exit 1
fi
