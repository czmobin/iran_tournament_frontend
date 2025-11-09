export const useApi = () => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const apiFetch = $fetch.create({
    baseURL: config.public.apiBase,

    onRequest({ options }) {
      // Add auth token to requests
      const token = authStore.accessToken
      if (token) {
        // Ensure headers is a Headers instance
        const headers = new Headers(options.headers as HeadersInit)
        headers.set('Authorization', `Bearer ${token}`)
        options.headers = headers
      }
    },

    async onResponseError({ response }) {
      // Handle 401 errors (token expired)
      if (response.status === 401) {
        // Try to refresh token
        const refreshed = await authStore.refreshToken()
        if (!refreshed) {
          // Redirect to login
          authStore.logout()
          navigateTo('/login')
        }
      }
    }
  })

  return {
    apiFetch
  }
}