export default defineNuxtRouteMiddleware(async (to, from) => {
  const authStore = useAuthStore()
  
  // Wait for initialization
  if (authStore.isInitializing) {
    // Wait a bit
    let tries = 0
    while (authStore.isInitializing && tries < 20) {
      await new Promise(resolve => setTimeout(resolve, 50))
      tries++
    }
  }
  
  // Check authentication
  if (!authStore.isAuthenticated) {
    return navigateTo('/login')
  }
})