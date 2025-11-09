<template>
  <div class="relative" ref="dropdownRef">
    <!-- Notification Bell Button -->
    <button
      @click="toggleDropdown"
      class="relative text-white hover:bg-white/20 p-2 rounded-lg transition"
      :class="{ 'bg-white/20': showDropdown }"
    >
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9"
        />
      </svg>

      <!-- Unread Count Badge -->
      <span
        v-if="notificationStore.unreadCount > 0"
        class="absolute -top-1 -right-1 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center"
      >
        {{ notificationStore.unreadCount > 9 ? '9+' : notificationStore.unreadCount }}
      </span>
    </button>

    <!-- Dropdown Menu -->
    <div
      v-if="showDropdown"
      class="absolute left-0 mt-2 w-80 md:w-96 bg-white rounded-xl shadow-2xl border border-gray-200 overflow-hidden z-50"
    >
      <!-- Header -->
      <div class="bg-gradient-to-r from-purple-600 to-pink-600 px-4 py-3 text-white">
        <div class="flex items-center justify-between">
          <h3 class="font-bold text-lg">اعلان‌ها</h3>
          <button
            v-if="notificationStore.unreadCount > 0"
            @click="markAllAsRead"
            class="text-sm hover:bg-white/20 px-3 py-1 rounded-lg transition"
          >
            خواندن همه
          </button>
        </div>
      </div>

      <!-- Notifications List -->
      <div class="max-h-96 overflow-y-auto">
        <!-- Loading State -->
        <div v-if="notificationStore.isLoading" class="p-8 text-center">
          <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-purple-600 mx-auto"></div>
          <p class="text-gray-600 mt-2">در حال بارگذاری...</p>
        </div>

        <!-- Empty State -->
        <div v-else-if="notificationStore.notifications.length === 0" class="p-8 text-center">
          <svg class="w-16 h-16 text-gray-300 mx-auto mb-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4"
            />
          </svg>
          <p class="text-gray-600 font-medium">اعلانی وجود ندارد</p>
          <p class="text-gray-400 text-sm mt-1">اعلان‌های جدید اینجا نمایش داده می‌شوند</p>
        </div>

        <!-- Notifications -->
        <div v-else>
          <div
            v-for="notification in notificationStore.notifications.slice(0, 5)"
            :key="notification.id"
            @click="handleNotificationClick(notification)"
            class="border-b border-gray-100 px-4 py-3 hover:bg-gray-50 cursor-pointer transition"
            :class="{ 'bg-blue-50': !notification.is_read }"
          >
            <div class="flex items-start gap-3">
              <!-- Icon based on type -->
              <div class="flex-shrink-0 mt-1">
                <span class="text-2xl">{{ getNotificationIcon(notification.notification_type) }}</span>
              </div>

              <!-- Content -->
              <div class="flex-1 min-w-0">
                <h4 class="font-bold text-gray-900 text-sm" :class="{ 'text-purple-700': !notification.is_read }">
                  {{ notification.title }}
                </h4>
                <p class="text-gray-600 text-sm mt-1 line-clamp-2">
                  {{ notification.message }}
                </p>
                <p class="text-gray-400 text-xs mt-2">
                  {{ formatDate(notification.created_at) }}
                </p>
              </div>

              <!-- Unread Indicator -->
              <div v-if="!notification.is_read" class="flex-shrink-0">
                <div class="w-2 h-2 bg-blue-600 rounded-full"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Footer -->
      <div v-if="notificationStore.notifications.length > 0" class="border-t border-gray-200 px-4 py-3 bg-gray-50">
        <NuxtLink
          to="/notifications"
          @click="showDropdown = false"
          class="block text-center text-purple-600 hover:text-purple-700 font-bold text-sm transition"
        >
          مشاهده همه اعلان‌ها
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Notification } from '~/stores/notifications'

const notificationStore = useNotificationsStore()
const router = useRouter()

const showDropdown = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)

// Toggle dropdown
const toggleDropdown = async () => {
  showDropdown.value = !showDropdown.value

  // Fetch notifications when opening
  if (showDropdown.value && notificationStore.notifications.length === 0) {
    await notificationStore.fetchNotifications()
  }
}

// Mark all as read
const markAllAsRead = async () => {
  await notificationStore.markAllAsRead()
}

// Handle notification click
const handleNotificationClick = async (notification: Notification) => {
  // Mark as read
  if (!notification.is_read) {
    await notificationStore.markAsRead(notification.id)
  }

  // Navigate to link if exists
  if (notification.link) {
    router.push(notification.link)
  }

  showDropdown.value = false
}

// Get icon based on notification type
const getNotificationIcon = (type: string): string => {
  const icons: Record<string, string> = {
    tournament: '🏆',
    payment: '💰',
    success: '✅',
    warning: '⚠️',
    error: '❌',
    info: 'ℹ️'
  }
  return icons[type] || 'ℹ️'
}

// Format date
const formatDate = (dateString: string): string => {
  const date = new Date(dateString)
  const now = new Date()
  const diff = now.getTime() - date.getTime()
  const minutes = Math.floor(diff / 60000)
  const hours = Math.floor(minutes / 60)
  const days = Math.floor(hours / 24)

  if (minutes < 1) return 'همین الان'
  if (minutes < 60) return `${minutes} دقیقه پیش`
  if (hours < 24) return `${hours} ساعت پیش`
  if (days < 7) return `${days} روز پیش`

  return date.toLocaleDateString('fa-IR')
}

// Close dropdown when clicking outside
const handleClickOutside = (event: MouseEvent) => {
  if (dropdownRef.value && !dropdownRef.value.contains(event.target as Node)) {
    showDropdown.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

// Close dropdown when route changes
watch(() => router.currentRoute.value.path, () => {
  showDropdown.value = false
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
