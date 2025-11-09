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