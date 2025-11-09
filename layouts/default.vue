<template>
  <div>
    <!-- Global Loading -->
    <div v-if="isInitializing" class="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-600 to-blue-600">
      <div class="text-center">
        <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-white mx-auto mb-4"></div>
        <p class="text-white text-lg font-medium">در حال بارگذاری...</p>
      </div>
    </div>

    <!-- Main Content -->
    <div v-else>
      <!-- Navbar -->
      <Navbar />

      <!-- Page Content -->
      <slot />
    </div>
  </div>
</template>

<script setup lang="ts">
const authStore = useAuthStore()
const notificationStore = useNotificationsStore()
const isInitializing = ref(true)

// Polling interval (30 seconds)
const POLL_INTERVAL = 30000
let pollTimer: NodeJS.Timeout | null = null

// Fetch notifications periodically
const startNotificationPolling = () => {
  // Initial fetch
  if (authStore.isAuthenticated) {
    notificationStore.fetchNotifications({ limit: 10 })
  }

  // Set up polling
  pollTimer = setInterval(() => {
    if (authStore.isAuthenticated) {
      notificationStore.fetchNotifications({ limit: 10 })
    }
  }, POLL_INTERVAL)
}

// Stop polling
const stopNotificationPolling = () => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
}

onMounted(async () => {
  // Initialize auth
  await authStore.initialize()

  // کمی تاخیر برای نمایش صاف
  await new Promise(resolve => setTimeout(resolve, 100))

  isInitializing.value = false

  // Start notification polling if authenticated
  if (authStore.isAuthenticated) {
    startNotificationPolling()
  }
})

onUnmounted(() => {
  stopNotificationPolling()
})

// Watch auth state changes
watch(() => authStore.isAuthenticated, (isAuth) => {
  if (isAuth) {
    startNotificationPolling()
  } else {
    stopNotificationPolling()
  }
})
</script>