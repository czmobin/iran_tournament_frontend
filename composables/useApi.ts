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

    async onResponseError({ response, request }) {
      // Handle 401 errors (token expired)
      if (response.status === 401) {
        console.log('Got 401 error, attempting token refresh...')

        // Try to refresh token
        const refreshed = await authStore.refreshToken()

        if (refreshed) {
          console.log('Token refreshed successfully')
          // توکن رفرش شد، اما درخواست اصلی رو دوباره ارسال نمی‌کنیم
          // چون $fetch.create این قابلیت رو نداره
          // کاربر باید صفحه رو رفرش کنه یا دوباره امتحان کنه
        } else {
          // Refresh token failed - logout user
          console.error('Token refresh failed, logging out')
          authStore.clearStorage()
          authStore.accessToken = null
          authStore.refreshToken = null
          authStore.user = null

          // فقط اگر در صفحه login نیستیم، ریدایرکت کن
          if (typeof window !== 'undefined' && !window.location.pathname.includes('/login')) {
            navigateTo('/login')
          }
        }
      }
    }
  })

  return {
    apiFetch
  }
}