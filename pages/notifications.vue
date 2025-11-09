<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
    <!-- Hero Section -->
    <div class="bg-gradient-to-r from-purple-600 via-pink-600 to-indigo-600 text-white py-6 md:py-10 px-4 mb-6 md:mb-8 relative overflow-hidden">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 right-0 w-48 h-48 bg-white rounded-full translate-x-1/4 -translate-y-1/4"></div>
        <div class="absolute bottom-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/4 translate-y-1/4"></div>
      </div>

      <div class="container mx-auto relative z-10 text-center">
        <div class="text-5xl md:text-6xl mb-3 md:mb-4">🔔</div>
        <h1 class="text-2xl md:text-4xl font-black mb-2">
          اعلان‌ها
        </h1>
        <p class="text-sm md:text-base text-white/90">مدیریت و مشاهده اعلان‌های شما</p>
      </div>
    </div>

    <div class="container mx-auto px-4 pb-12">
      <!-- Actions Bar -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl p-4 md:p-6 mb-6 md:mb-8">
        <div class="flex flex-col sm:flex-row items-center justify-between gap-4">
          <div class="flex items-center gap-3">
            <h2 class="text-lg md:text-xl font-bold text-gray-800">
              {{ notificationsStore.unreadCount }} اعلان خوانده نشده
            </h2>
          </div>

          <div class="flex gap-3">
            <button
              @click="loadNotifications"
              :disabled="notificationsStore.isLoading"
              class="px-4 py-2 bg-gray-100 text-gray-700 rounded-xl hover:bg-gray-200 transition-all text-sm font-bold shadow-sm active:scale-95 disabled:opacity-50"
            >
              🔄 <span class="hidden sm:inline">بروزرسانی</span>
            </button>

            <button
              v-if="notificationsStore.unreadCount > 0"
              @click="markAllAsRead"
              :disabled="notificationsStore.isLoading"
              class="px-4 py-2 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl hover:from-purple-700 hover:to-pink-700 transition-all text-sm font-bold shadow-lg active:scale-95 disabled:opacity-50"
            >
              ✓ <span class="hidden sm:inline">خواندن همه</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Filter Tabs -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl p-4 md:p-6 mb-6 md:mb-8">
        <div class="grid grid-cols-2 md:flex md:flex-wrap gap-2">
          <button
            v-for="filter in filters"
            :key="filter.value"
            @click="selectedFilter = filter.value"
            :class="[
              'px-4 py-2.5 rounded-xl font-bold transition-all text-sm shadow-sm',
              selectedFilter === filter.value
                ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-md scale-105'
                : 'bg-gray-100 text-gray-700 hover:bg-gray-200 active:scale-95'
            ]"
          >
            {{ filter.icon }} {{ filter.label }}
          </button>
        </div>
      </div>

      <!-- Notifications List -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl overflow-hidden">
        <!-- Loading State -->
        <div v-if="notificationsStore.isLoading" class="flex justify-center items-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredNotifications.length === 0" class="text-center py-12 text-gray-500">
          <div class="text-6xl mb-4">🔔</div>
          <p>هیچ اعلانی وجود ندارد</p>
        </div>

        <!-- Notifications -->
        <div v-else class="divide-y divide-gray-100">
          <div
            v-for="notification in filteredNotifications"
            :key="notification.id"
            class="p-4 md:p-6 hover:bg-gray-50 transition"
            :class="{ 'bg-purple-50': !notification.is_read }"
          >
            <div class="flex items-start gap-4">
              <!-- Icon -->
              <div
                :class="[
                  'w-12 h-12 rounded-full flex items-center justify-center flex-shrink-0 text-2xl',
                  getNotificationColor(notification.notification_type)
                ]"
              >
                {{ getNotificationIcon(notification.notification_type) }}
              </div>

              <!-- Content -->
              <div class="flex-1 min-w-0">
                <div class="flex items-start justify-between gap-4 mb-2">
                  <div class="flex items-center gap-2">
                    <h3 class="text-base md:text-lg font-bold text-gray-800">
                      {{ notification.title }}
                    </h3>
                    <span
                      v-if="!notification.is_read"
                      class="w-2 h-2 bg-purple-600 rounded-full flex-shrink-0"
                    ></span>
                  </div>

                  <span
                    :class="[
                      'px-2 md:px-3 py-1 rounded-full text-xs font-bold whitespace-nowrap',
                      getNotificationBadgeColor(notification.notification_type)
                    ]"
                  >
                    {{ getNotificationTypeLabel(notification.notification_type) }}
                  </span>
                </div>

                <p class="text-sm md:text-base text-gray-600 mb-2">
                  {{ notification.message }}
                </p>

                <div class="flex flex-wrap items-center gap-3">
                  <p class="text-xs text-gray-400">
                    {{ formatDate(notification.created_at) }}
                  </p>

                  <div class="flex gap-2">
                    <button
                      v-if="!notification.is_read"
                      @click="markAsRead(notification.id)"
                      class="text-xs text-purple-600 hover:text-purple-700 font-bold"
                    >
                      علامت‌گذاری به عنوان خوانده شده
                    </button>

                    <button
                      v-if="notification.link"
                      @click="navigateTo(notification.link)"
                      class="text-xs text-blue-600 hover:text-blue-700 font-bold"
                    >
                      مشاهده جزئیات →
                    </button>

                    <button
                      @click="deleteNotification(notification.id)"
                      class="text-xs text-red-600 hover:text-red-700 font-bold"
                    >
                      حذف
                    </button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useNotificationsStore } from '~/stores/notifications'

definePageMeta({
  middleware: 'auth'
})

const notificationsStore = useNotificationsStore()
const selectedFilter = ref('all')

const filters = [
  { label: 'همه', value: 'all', icon: '📋' },
  { label: 'خوانده نشده', value: 'unread', icon: '🔴' },
  { label: 'تورنومنت', value: 'tournament', icon: '🏆' },
  { label: 'پرداخت', value: 'payment', icon: '💰' }
]

const filteredNotifications = computed(() => {
  switch (selectedFilter.value) {
    case 'unread':
      return notificationsStore.unreadNotifications
    case 'tournament':
      return notificationsStore.tournamentNotifications
    case 'payment':
      return notificationsStore.paymentNotifications
    default:
      return notificationsStore.notifications
  }
})

const loadNotifications = async () => {
  await notificationsStore.fetchNotifications()
}

const markAsRead = async (id: number) => {
  await notificationsStore.markAsRead(id)
}

const markAllAsRead = async () => {
  if (confirm('آیا مطمئن هستید که می‌خواهید همه اعلان‌ها را به عنوان خوانده شده علامت‌گذاری کنید؟')) {
    await notificationsStore.markAllAsRead()
  }
}

const deleteNotification = async (id: number) => {
  if (confirm('آیا مطمئن هستید که می‌خواهید این اعلان را حذف کنید؟')) {
    await notificationsStore.deleteNotification(id)
  }
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

const getNotificationBadgeColor = (type: string) => {
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

const getNotificationTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    info: 'اطلاعیه',
    success: 'موفق',
    warning: 'هشدار',
    error: 'خطا',
    tournament: 'تورنومنت',
    payment: 'پرداخت'
  }
  return labels[type] || 'اطلاعیه'
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
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// Load notifications on mount
onMounted(() => {
  loadNotifications()
})

useHead({
  title: 'اعلان‌ها - ایران تورنومنت'
})
</script>
