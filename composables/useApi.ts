export const useApi = () => {
  const config = useRuntimeConfig()
  const authStore = useAuthStore()

  const apiFetch = $fetch.create({
    baseURL: config.public.apiBase,

    onRequest({ options }) {
      // Add auth token to requests
      const token = authStore.accessToken
      if (token) {
        // Initialize headers if not exists
        if (!options.headers) {
          options.headers = {}
        }

        // Convert Headers to plain object if needed
        if (options.headers instanceof Headers) {
          const headersObj: Record<string, string> = {}
          options.headers.forEach((value, key) => {
            headersObj[key] = value
          })
          options.headers = headersObj
        }

        // Add Authorization header
        options.headers = {
          ...options.headers as Record<string, string>,
          Authorization: `Bearer ${token}`
        }
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