export default defineNuxtRouteMiddleware(async (to, from) => {
  const authStore = useAuthStore()
  
  // Wait for initialization
  if (authStore.isInitializing) {
    let tries = 0
    while (authStore.isInitializing && tries < 20) {
      await new Promise(resolve => setTimeout(resolve, 50))
      tries++
    }
  }
  
  // If already logged in, redirect
  if (authStore.isAuthenticated) {
    return navigateTo('/dashboard')
  }
})