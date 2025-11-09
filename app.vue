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
</style>