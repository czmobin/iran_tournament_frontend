export default defineNuxtPlugin(async (nuxtApp) => {
  const authStore = useAuthStore(nuxtApp.$pinia as any)

  console.log('[Auth Plugin] Starting initialization...')

  // Set initializing flag
  authStore.isInitializing = true

  // Initialize auth store
  await authStore.initialize()

  // Done initializing
  authStore.isInitializing = false

  console.log('[Auth Plugin] Initialization complete:', {
    isAuthenticated: authStore.isAuthenticated,
    hasToken: !!authStore.accessToken,
    hasUser: !!authStore.user
  })
})