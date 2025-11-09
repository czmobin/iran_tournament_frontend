<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 py-8">
    <div class="container mx-auto px-4">
      <!-- Header -->
      <div class="bg-white rounded-2xl shadow-lg p-6 mb-6">
        <div class="flex items-center justify-between flex-wrap gap-4">
          <div>
            <h1 class="text-3xl font-black text-gray-900 mb-2">
              🔔 اعلان‌ها
            </h1>
            <p class="text-gray-600">
              مدیریت و مشاهده اعلان‌های خود
            </p>
          </div>

          <div class="flex items-center gap-3">
            <NuxtLink
              to="/notifications/settings"
              class="bg-gray-100 hover:bg-gray-200 text-gray-700 px-4 py-2 rounded-lg transition font-bold"
            >
              ⚙️ تنظیمات
            </NuxtLink>

            <button
              v-if="notificationStore.unreadCount > 0"
              @click="markAllAsRead"
              :disabled="isMarkingAllRead"
              class="bg-purple-600 hover:bg-purple-700 text-white px-4 py-2 rounded-lg transition font-bold disabled:opacity-50"
            >
              ✅ خواندن همه
            </button>
          </div>
        </div>
      </div>

      <!-- Filter Tabs -->
      <div class="bg-white rounded-2xl shadow-lg mb-6 overflow-hidden">
        <div class="flex overflow-x-auto">
          <button
            v-for="filter in filters"
            :key="filter.value"
            @click="currentFilter = filter.value"
            class="flex-1 min-w-[120px] px-6 py-4 font-bold transition"
            :class="currentFilter === filter.value
              ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
              : 'text-gray-600 hover:bg-gray-100'"
          >
            {{ filter.icon }} {{ filter.label }}
            <span v-if="filter.count > 0" class="ml-2 text-sm">
              ({{ filter.count }})
            </span>
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="notificationStore.isLoading" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600 mx-auto mb-4"></div>
        <p class="text-gray-600">در حال بارگذاری اعلان‌ها...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="notificationStore.error" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="text-red-500 text-6xl mb-4">❌</div>
        <h3 class="text-xl font-bold text-gray-900 mb-2">خطا در بارگذاری اعلان‌ها</h3>
        <p class="text-gray-600 mb-6">{{ notificationStore.error }}</p>
        <button
          @click="fetchNotifications"
          class="bg-purple-600 hover:bg-purple-700 text-white px-6 py-3 rounded-lg transition font-bold"
        >
          تلاش مجدد
        </button>
      </div>

      <!-- Empty State -->
      <div v-else-if="filteredNotifications.length === 0" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="text-gray-300 text-6xl mb-4">📭</div>
        <h3 class="text-xl font-bold text-gray-900 mb-2">
          {{ currentFilter === 'all' ? 'اعلانی وجود ندارد' : 'اعلانی در این دسته وجود ندارد' }}
        </h3>
        <p class="text-gray-600">
          {{ currentFilter === 'all'
            ? 'اعلان‌های جدید اینجا نمایش داده می‌شوند'
            : 'فیلتر دیگری را انتخاب کنید یا به صفحه همه اعلان‌ها بروید' }}
        </p>
      </div>

      <!-- Notifications List -->
      <div v-else class="space-y-4">
        <div
          v-for="notification in filteredNotifications"
          :key="notification.id"
          @click="handleNotificationClick(notification)"
          class="bg-white rounded-2xl shadow-lg p-6 hover:shadow-xl transition cursor-pointer"
          :class="{ 'border-2 border-blue-400': !notification.is_read }"
        >
          <div class="flex items-start gap-4">
            <!-- Icon -->
            <div class="flex-shrink-0">
              <div
                class="w-12 h-12 rounded-full flex items-center justify-center text-2xl"
                :class="getNotificationBgClass(notification.notification_type)"
              >
                {{ getNotificationIcon(notification.notification_type) }}
              </div>
            </div>

            <!-- Content -->
            <div class="flex-1 min-w-0">
              <div class="flex items-start justify-between gap-4 mb-2">
                <h3
                  class="font-bold text-lg"
                  :class="notification.is_read ? 'text-gray-900' : 'text-purple-700'"
                >
                  {{ notification.title }}
                </h3>

                <!-- Unread Badge -->
                <span
                  v-if="!notification.is_read"
                  class="flex-shrink-0 bg-blue-600 text-white text-xs px-2 py-1 rounded-full font-bold"
                >
                  جدید
                </span>
              </div>

              <p class="text-gray-600 mb-3 leading-relaxed">
                {{ notification.message }}
              </p>

              <div class="flex items-center justify-between flex-wrap gap-3">
                <div class="flex items-center gap-2 text-sm text-gray-500">
                  <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      stroke-linecap="round"
                      stroke-linejoin="round"
                      stroke-width="2"
                      d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"
                    />
                  </svg>
                  <span>{{ formatDate(notification.created_at) }}</span>
                </div>

                <div class="flex items-center gap-2">
                  <span
                    class="text-xs px-3 py-1 rounded-full font-bold"
                    :class="getNotificationTypeClass(notification.notification_type)"
                  >
                    {{ getNotificationTypeLabel(notification.notification_type) }}
                  </span>

                  <button
                    v-if="!notification.is_read"
                    @click.stop="markAsRead(notification.id)"
                    class="text-sm text-purple-600 hover:text-purple-700 font-bold"
                  >
                    علامت‌گذاری خوانده شده
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Load More Button -->
      <div v-if="hasMore && !notificationStore.isLoading" class="mt-6 text-center">
        <button
          @click="loadMore"
          class="bg-white hover:bg-gray-50 text-purple-600 px-8 py-3 rounded-lg transition font-bold shadow-lg"
        >
          بارگذاری بیشتر
        </button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Notification } from '~/stores/notifications'

definePageMeta({
  middleware: 'auth'
})

const notificationStore = useNotificationsStore()
const router = useRouter()

const currentFilter = ref('all')
const isMarkingAllRead = ref(false)
const hasMore = ref(false)

// Filters
const filters = computed(() => [
  { value: 'all', label: 'همه', icon: '📋', count: notificationStore.notifications.length },
  { value: 'unread', label: 'خوانده نشده', icon: '🔵', count: notificationStore.unreadCount },
  { value: 'tournament', label: 'تورنومنت', icon: '🏆', count: notificationStore.tournamentNotifications.length },
  { value: 'payment', label: 'پرداخت', icon: '💰', count: notificationStore.paymentNotifications.length }
])

// Filtered notifications
const filteredNotifications = computed(() => {
  switch (currentFilter.value) {
    case 'unread':
      return notificationStore.unreadNotifications
    case 'tournament':
      return notificationStore.tournamentNotifications
    case 'payment':
      return notificationStore.paymentNotifications
    default:
      return notificationStore.notifications
  }
})

// Fetch notifications on mount
const fetchNotifications = async () => {
  await notificationStore.fetchNotifications()
}

// Mark all as read
const markAllAsRead = async () => {
  isMarkingAllRead.value = true
  await notificationStore.markAllAsRead()
  isMarkingAllRead.value = false
}

// Mark single notification as read
const markAsRead = async (id: number) => {
  await notificationStore.markAsRead(id)
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
}

// Load more notifications
const loadMore = async () => {
  // TODO: Implement pagination
  console.log('Load more notifications')
}

// Get notification icon
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

// Get notification background class
const getNotificationBgClass = (type: string): string => {
  const classes: Record<string, string> = {
    tournament: 'bg-purple-100 text-purple-600',
    payment: 'bg-green-100 text-green-600',
    success: 'bg-blue-100 text-blue-600',
    warning: 'bg-yellow-100 text-yellow-600',
    error: 'bg-red-100 text-red-600',
    info: 'bg-gray-100 text-gray-600'
  }
  return classes[type] || 'bg-gray-100 text-gray-600'
}

// Get notification type class
const getNotificationTypeClass = (type: string): string => {
  const classes: Record<string, string> = {
    tournament: 'bg-purple-100 text-purple-700',
    payment: 'bg-green-100 text-green-700',
    success: 'bg-blue-100 text-blue-700',
    warning: 'bg-yellow-100 text-yellow-700',
    error: 'bg-red-100 text-red-700',
    info: 'bg-gray-100 text-gray-700'
  }
  return classes[type] || 'bg-gray-100 text-gray-700'
}

// Get notification type label
const getNotificationTypeLabel = (type: string): string => {
  const labels: Record<string, string> = {
    tournament: 'تورنومنت',
    payment: 'پرداخت',
    success: 'موفقیت',
    warning: 'هشدار',
    error: 'خطا',
    info: 'اطلاعات'
  }
  return labels[type] || 'عمومی'
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

  return date.toLocaleDateString('fa-IR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
}

// Initialize
onMounted(() => {
  fetchNotifications()
})
</script>
