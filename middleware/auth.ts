export default defineNuxtRouteMiddleware(async (to, from) => {
  const authStore = useAuthStore()

  console.log('[Auth Middleware] Checking auth for:', to.path, {
    isInitializing: authStore.isInitializing,
    isAuthenticated: authStore.isAuthenticated,
    hasToken: !!authStore.accessToken
  })

  // Wait for initialization
  if (authStore.isInitializing) {
    console.log('[Auth Middleware] Waiting for auth initialization...')
    let tries = 0
    while (authStore.isInitializing && tries < 20) {
      await new Promise(resolve => setTimeout(resolve, 50))
      tries++
    }

    if (authStore.isInitializing) {
      console.warn('[Auth Middleware] Timeout waiting for initialization')
    } else {
      console.log('[Auth Middleware] Initialization complete')
    }
  }

  // Check authentication
  if (!authStore.isAuthenticated) {
    console.log('[Auth Middleware] Not authenticated, redirecting to login')
    return navigateTo('/login')
  }

  console.log('[Auth Middleware] Authenticated, allowing access')
})