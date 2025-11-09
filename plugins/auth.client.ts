export default defineNuxtPlugin(async (nuxtApp) => {
  const authStore = useAuthStore(nuxtApp.$pinia as any)
  
  // Set initializing flag
  authStore.isInitializing = true
  
  // Initialize auth store
  await authStore.initialize()
  
  // Done initializing
  authStore.isInitializing = false
})