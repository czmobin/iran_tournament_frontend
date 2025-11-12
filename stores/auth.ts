import { defineStore } from 'pinia'

interface User {
  id: number
  username: string
  email: string
  first_name: string
  last_name: string
  wallet_balance: number
  profile_picture: string | null
  is_verified: boolean
  clash_royale_tag: string | null
  phone_number: string | null
  created_at: string
}

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    accessToken: null as string | null,
    refreshToken: null as string | null,
    isLoading: false,
    isInitializing: true, // ← جدید!
  }),
  
  getters: {
    isAuthenticated: (state) => !!state.accessToken,
    userFullName: (state) => {
      if (!state.user) return ''
      return `${state.user.first_name} ${state.user.last_name}`.trim() || state.user.username
    }
  },
  
  actions: {
    // Initialize - با کنترل بهتر
    async initialize() {
      if (!process.client) return

      this.isInitializing = true

      try {
        // بارگذاری از localStorage
        this.loadFromStorage()

        // اگه توکن داریم، پروفایل رو fetch کن
        if (this.accessToken) {
          try {
            await this.fetchProfile()
          } catch (error: any) {
            // فقط در صورت 401 یا 403، توکن رو پاک کن
            // برای سایر خطاها (مثل network error)، توکن رو نگه دار
            const errorStatus = error?.status || error?.response?.status
            const is401or403 = errorStatus === 401 || errorStatus === 403

            if (is401or403) {
              console.error('Token expired or invalid, clearing auth')
              this.clearStorage()
              this.accessToken = null
              this.refreshToken = null
              this.user = null
            } else {
              // خطای دیگه‌ای بود (مثلاً network) - توکن رو نگه دار
              console.warn('Failed to fetch profile, but keeping token. Error status:', errorStatus, error)
            }
          }
        }
      } finally {
        this.isInitializing = false
      }
    },

    // OTP-based Authentication Methods
    async sendOTP(phoneNumber: string) {
      try {
        this.isLoading = true
        const { apiFetch } = useApi()

        console.log('[Auth Store] Sending OTP to:', phoneNumber)

        const response = await apiFetch('/auth/send-otp/', {
          method: 'POST',
          body: { phone_number: phoneNumber }
        })

        console.log('[Auth Store] OTP sent:', response)

        return {
          success: true,
          message: response.message,
          taskId: response.task_id,
          userExists: response.user_exists
        }
      } catch (error: any) {
        console.error('[Auth Store] Send OTP failed:', error)
        return {
          success: false,
          message: error.data?.message || error.data?.phone_number?.[0] || 'خطا در ارسال کد تایید'
        }
      } finally {
        this.isLoading = false
      }
    },

    async verifyOTP(phoneNumber: string, otp: string) {
      try {
        this.isLoading = true
        const { apiFetch } = useApi()

        console.log('[Auth Store] Verifying OTP for:', phoneNumber)

        const response = await apiFetch('/auth/verify-otp/', {
          method: 'POST',
          body: { phone_number: phoneNumber, otp }
        })

        console.log('[Auth Store] OTP verification response:', response)

        if (response.action === 'login') {
          // کاربر موجود - لاگین کامل
          this.user = response.user
          this.accessToken = response.tokens.access
          this.refreshToken = response.tokens.refresh
          this.saveToStorage()

          return {
            success: true,
            action: 'login',
            message: 'ورود موفقیت‌آمیز بود'
          }
        } else if (response.action === 'register') {
          // کاربر جدید - نیاز به تکمیل ثبت‌نام
          return {
            success: true,
            action: 'register',
            message: response.message,
            phoneNumber: response.phone_number
          }
        }

        return {
          success: false,
          message: 'پاسخ نامعتبر از سرور'
        }
      } catch (error: any) {
        console.error('[Auth Store] Verify OTP failed:', error)
        return {
          success: false,
          message: error.data?.message || error.data?.otp?.[0] || 'کد تایید نامعتبر است'
        }
      } finally {
        this.isLoading = false
      }
    },

    async completeRegistration(data: {
      phone_number: string
      username: string
      first_name: string
      last_name: string
      email?: string
      clash_royale_tag?: string
    }) {
      try {
        this.isLoading = true
        const { apiFetch } = useApi()

        console.log('[Auth Store] Completing registration for:', data.phone_number)

        const response = await apiFetch('/auth/complete-registration/', {
          method: 'POST',
          body: data
        })

        console.log('[Auth Store] Registration completed:', response)

        this.user = response.user
        this.accessToken = response.tokens.access
        this.refreshToken = response.tokens.refresh
        this.saveToStorage()

        return {
          success: true,
          message: response.message || 'ثبت‌نام با موفقیت انجام شد'
        }
      } catch (error: any) {
        console.error('[Auth Store] Complete registration failed:', error)
        return {
          success: false,
          message: error.data?.message || 'خطا در تکمیل ثبت‌نام',
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },
    
    async logout() {
      try {
        const { apiFetch } = useApi()
        
        await apiFetch('/auth/logout/', {
          method: 'POST',
          body: { refresh: this.refreshToken }
        })
      } catch (error) {
        // Ignore
      } finally {
        this.user = null
        this.accessToken = null
        this.refreshToken = null
        this.clearStorage()
        navigateTo('/login')
      }
    },
    
    async refreshToken() {
      if (!this.refreshToken) return false
      
      try {
        const config = useRuntimeConfig()
        
        const response = await $fetch('/auth/token/refresh/', {
          baseURL: config.public.apiBase,
          method: 'POST',
          body: { refresh: this.refreshToken }
        })
        
        this.accessToken = response.access
        this.saveToStorage()
        
        return true
      } catch (error) {
        return false
      }
    },
    
    async fetchProfile() {
      if (!this.accessToken) return { success: false }

      try {
        this.isLoading = true
        const { apiFetch } = useApi()

        const response = await apiFetch('/accounts/profile/')

        this.user = response
        this.saveToStorage()

        return { success: true }
      } catch (error: any) {
        console.error('Error fetching profile:', error)

        // ساختار خطا رو اصلاح کن تا initialize بتونه status code رو ببینه
        if (error.response) {
          error.response = error.response
        } else if (error.status) {
          // برخی موارد که خطا مستقیماً status داره
          error.response = { status: error.status }
        }

        throw error // ← مهم: throw کن تا initialize بفهمه
      } finally {
        this.isLoading = false
      }
    },

    async updateProfile(profileData: Partial<User>) {
      if (!this.accessToken) return { success: false }

      try {
        this.isLoading = true
        const { apiFetch } = useApi()

        const response = await apiFetch('/accounts/profile/', {
          method: 'PUT',
          body: profileData
        })

        this.user = response
        this.saveToStorage()

        return { success: true, message: 'پروفایل با موفقیت به‌روزرسانی شد' }
      } catch (error: any) {
        return {
          success: false,
          message: error.data?.message || 'خطا در به‌روزرسانی پروفایل',
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },

    async fetchStats() {
      if (!this.accessToken) return { success: false }

      try {
        const { apiFetch } = useApi()

        const response = await apiFetch('/accounts/stats/')

        return { success: true, data: response }
      } catch (error: any) {
        return {
          success: false,
          message: error.data?.message || 'خطا در دریافت آمار'
        }
      }
    },
    
    updateUser(userData: Partial<User>) {
      if (this.user) {
        this.user = { ...this.user, ...userData }
        this.saveToStorage()
      }
    },
    
    saveToStorage() {
      if (process.client) {
        localStorage.setItem('accessToken', this.accessToken || '')
        localStorage.setItem('refreshToken', this.refreshToken || '')
        localStorage.setItem('user', JSON.stringify(this.user))
      }
    },
    
    loadFromStorage() {
      if (process.client) {
        this.accessToken = localStorage.getItem('accessToken')
        this.refreshToken = localStorage.getItem('refreshToken')
        const userStr = localStorage.getItem('user')
        if (userStr) {
          try {
            this.user = JSON.parse(userStr)
          } catch (e) {
            console.error('Error parsing user data:', e)
            this.clearStorage()
          }
        }
      }
    },
    
    clearStorage() {
      if (process.client) {
        localStorage.removeItem('accessToken')
        localStorage.removeItem('refreshToken')
        localStorage.removeItem('user')
      }
    }
  }
})