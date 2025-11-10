<template>
  <div class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed mobile-bg md:desktop-bg">
    <!-- Global Loading -->
    <div v-if="isInitializing" class="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-600/90 to-blue-600/90">
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
const isInitializing = ref(true)

onMounted(async () => {
  // Initialize auth
  await authStore.initialize()

  // کمی تاخیر برای نمایش صاف
  await new Promise(resolve => setTimeout(resolve, 100))

  isInitializing.value = false
})
</script>

<style scoped>
.mobile-bg {
  background-image: url('/mobile_index.png');
}

@media (min-width: 768px) {
  .desktop-bg {
    background-image: url('/desktop_index.png');
  }
}
</style>