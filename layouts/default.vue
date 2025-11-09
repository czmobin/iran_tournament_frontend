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
import { useNotificationsStore } from '~/stores/notifications'

const authStore = useAuthStore()
const notificationsStore = useNotificationsStore()
const isInitializing = ref(true)

onMounted(async () => {
  // Initialize auth
  await authStore.initialize()

  // کمی تاخیر برای نمایش صاف
  await new Promise(resolve => setTimeout(resolve, 100))

  isInitializing.value = false

  // اگر کاربر لاگین کرده، notification count رو بارگذاری کن
  if (authStore.isAuthenticated) {
    notificationsStore.fetchUnreadCount()

    // هر 30 ثانیه یکبار update کن
    const interval = setInterval(() => {
      if (authStore.isAuthenticated) {
        notificationsStore.fetchUnreadCount()
      } else {
        clearInterval(interval)
      }
    }, 30000) // 30 seconds

    // پاکسازی interval در unmount
    onUnmounted(() => {
      clearInterval(interval)
    })
  }
})

// وقتی کاربر logout میکنه، notification store رو reset کن
watch(() => authStore.isAuthenticated, (isAuth) => {
  if (!isAuth) {
    notificationsStore.reset()
  } else {
    // وقتی کاربر login میکنه، notification count رو بارگذاری کن
    notificationsStore.fetchUnreadCount()
  }
})
</script>