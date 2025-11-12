<template>
  <div>
    <NuxtLayout>
      <NuxtPage />
    </NuxtLayout>
  </div>
</template>

<script setup lang="ts">
const authStore = useAuthStore()

// Hydration fix
onBeforeMount(() => {
  if (process.client) {
    setTimeout(() => {
      document.documentElement.classList.remove('initial-load')
    }, 100)
  }
})

onMounted(() => {
  if (process.client) {
    document.body.style.opacity = '1'
  }
})
</script>

<style>
body {
  opacity: 0;
  transition: opacity 0.3s ease-in-out;
}

/* Page transitions */
.page-enter-active,
.page-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}

.page-enter-from {
  opacity: 0;
  transform: translateX(-20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateX(20px);
}
</style>