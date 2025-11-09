<template>
  <div class="relative">
    <!-- Bell Button -->
    <button
      @click="toggleDropdown"
      class="relative p-2 text-gray-600 hover:text-purple-600 transition-colors rounded-full hover:bg-purple-50 active:scale-95"
      :class="{ 'bg-purple-50 text-purple-600': isOpen }"
    >
      <!-- Bell Icon -->
      <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 17h5l-1.405-1.405A2.032 2.032 0 0118 14.158V11a6.002 6.002 0 00-4-5.659V5a2 2 0 10-4 0v.341C7.67 6.165 6 8.388 6 11v3.159c0 .538-.214 1.055-.595 1.436L4 17h5m6 0v1a3 3 0 11-6 0v-1m6 0H9" />
      </svg>

      <!-- Badge -->
      <span
        v-if="notificationsStore.unreadCount > 0"
        class="absolute top-0 right-0 inline-flex items-center justify-center px-2 py-1 text-xs font-bold leading-none text-white transform translate-x-1/2 -translate-y-1/2 bg-red-600 rounded-full min-w-[20px]"
      >
        {{ notificationsStore.unreadCount > 99 ? '99+' : notificationsStore.unreadCount }}
      </span>
    </button>

    <!-- Dropdown -->
    <Transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0 scale-95"
      enter-to-class="opacity-100 scale-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100 scale-100"
      leave-to-class="opacity-0 scale-95"
    >
      <div
        v-if="isOpen"
        class="absolute left-0 md:right-0 md:left-auto mt-2 w-80 md:w-96 bg-white rounded-xl shadow-2xl border border-gray-200 z-50"
      >
        <!-- Header -->
        <div class="p-4 border-b border-gray-200 flex items-center justify-between">
          <h3 class="text-lg font-bold text-gray-800">اعلان‌ها</h3>
          <div class="flex gap-2">
            <button
              v-if="notificationsStore.unreadCount > 0"
              @click="markAllAsRead"
              class="text-xs text-purple-600 hover:text-purple-700 font-bold"
            >
              خواندن همه
            </button>
            <NuxtLink
              to="/notifications"
              @click="isOpen = false"
              class="text-xs text-purple-600 hover:text-purple-700 font-bold"
            >
              مشاهده همه
            </NuxtLink>
          </div>
        </div>

        <!-- Notifications List -->
        <div class="max-h-96 overflow-y-auto">
          <!-- Loading -->
          <div v-if="notificationsStore.isLoading" class="flex justify-center items-center py-8">
            <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-purple-600"></div>
          </div>

          <!-- Empty State -->
          <div v-else-if="notificationsStore.notifications.length === 0" class="text-center py-8 text-gray-500">
            <div class="text-5xl mb-3">🔔</div>
            <p class="text-sm">اعلانی وجود ندارد</p>
          </div>

          <!-- Notifications -->
          <div v-else>
            <div
              v-for="notification in notificationsStore.notifications.slice(0, 5)"
              :key="notification.id"
              @click="handleNotificationClick(notification)"
              class="p-4 border-b border-gray-100 hover:bg-gray-50 transition cursor-pointer"
              :class="{ 'bg-purple-50': !notification.is_read }"
            >
              <div class="flex items-start gap-3">
                <!-- Icon -->
                <div
                  :class="[
                    'w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0',
                    getNotificationColor(notification.notification_type)
                  ]"
                >
                  {{ getNotificationIcon(notification.notification_type) }}
                </div>

                <!-- Content -->
                <div class="flex-1 min-w-0">
                  <div class="flex items-start justify-between gap-2">
                    <h4 class="text-sm font-bold text-gray-800 line-clamp-1">
                      {{ notification.title }}
                    </h4>
                    <span
                      v-if="!notification.is_read"
                      class="w-2 h-2 bg-purple-600 rounded-full flex-shrink-0 mt-1"
                    ></span>
                  </div>
                  <p class="text-xs text-gray-600 mt-1 line-clamp-2">
                    {{ notification.message }}
                  </p>
                  <p class="text-xs text-gray-400 mt-1">
                    {{ formatDate(notification.created_at) }}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Footer -->
        <div v-if="notificationsStore.notifications.length > 5" class="p-3 border-t border-gray-200 text-center">
          <NuxtLink
            to="/notifications"
            @click="isOpen = false"
            class="text-sm text-purple-600 hover:text-purple-700 font-bold"
          >
            مشاهده {{ notificationsStore.notifications.length - 5 }} اعلان دیگر ←
          </NuxtLink>
        </div>
      </div>
    </Transition>

    <!-- Backdrop -->
    <div
      v-if="isOpen"
      @click="isOpen = false"
      class="fixed inset-0 z-40"
    ></div>
  </div>
</template>

<script setup lang="ts">
import { useNotificationsStore } from '~/stores/notifications'
import type { Notification } from '~/stores/notifications'

const notificationsStore = useNotificationsStore()
const router = useRouter()
const isOpen = ref(false)

const toggleDropdown = async () => {
  isOpen.value = !isOpen.value

  // Load notifications when opening
  if (isOpen.value && notificationsStore.shouldRefresh) {
    await notificationsStore.fetchNotifications({ limit: 10 })
  }
}

const markAllAsRead = async () => {
  await notificationsStore.markAllAsRead()
}

const handleNotificationClick = async (notification: Notification) => {
  // Mark as read
  if (!notification.is_read) {
    await notificationsStore.markAsRead(notification.id)
  }

  // Navigate if link exists
  if (notification.link) {
    router.push(notification.link)
  }

  // Close dropdown
  isOpen.value = false
}

const getNotificationIcon = (type: string) => {
  const icons: Record<string, string> = {
    info: 'ℹ️',
    success: '✅',
    warning: '⚠️',
    error: '❌',
    tournament: '🏆',
    payment: '💰'
  }
  return icons[type] || 'ℹ️'
}

const getNotificationColor = (type: string) => {
  const colors: Record<string, string> = {
    info: 'bg-blue-100 text-blue-600',
    success: 'bg-green-100 text-green-600',
    warning: 'bg-yellow-100 text-yellow-600',
    error: 'bg-red-100 text-red-600',
    tournament: 'bg-purple-100 text-purple-600',
    payment: 'bg-green-100 text-green-600'
  }
  return colors[type] || 'bg-gray-100 text-gray-600'
}

const formatDate = (date: string) => {
  const now = new Date()
  const notifDate = new Date(date)
  const diffMs = now.getTime() - notifDate.getTime()
  const diffMins = Math.floor(diffMs / 60000)
  const diffHours = Math.floor(diffMs / 3600000)
  const diffDays = Math.floor(diffMs / 86400000)

  if (diffMins < 1) return 'همین الان'
  if (diffMins < 60) return `${diffMins} دقیقه پیش`
  if (diffHours < 24) return `${diffHours} ساعت پیش`
  if (diffDays < 7) return `${diffDays} روز پیش`

  return notifDate.toLocaleDateString('fa-IR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Close dropdown when clicking outside
onMounted(() => {
  // Load initial unread count
  notificationsStore.fetchUnreadCount()
})

// Close dropdown on route change
watch(() => router.currentRoute.value.path, () => {
  isOpen.value = false
})
</script>
