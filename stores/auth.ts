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
          } catch (error) {
            // اگه توکن منقضی شده، پاک کن
            console.error('Token expired, clearing auth')
            this.clearStorage()
            this.accessToken = null
            this.refreshToken = null
            this.user = null
          }
        }
      } finally {
        this.isInitializing = false
      }
    },
    
    // بقیه متدها همون...
    async register(data: any) {
      try {
        this.isLoading = true
        const { apiFetch } = useApi()
        
        const response = await apiFetch('/auth/register/', {
          method: 'POST',
          body: data
        })
        
        this.user = response.user
        this.accessToken = response.tokens.access
        this.refreshToken = response.tokens.refresh
        
        this.saveToStorage()
        
        return { success: true, message: response.message }
      } catch (error: any) {
        return {
          success: false,
          message: error.data?.message || 'خطا در ثبت‌نام',
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },
    
    async login(username: string, password: string) {
      try {
        this.isLoading = true
        const { apiFetch } = useApi()
        
        const response = await apiFetch('/auth/login/', {
          method: 'POST',
          body: { username, password }
        })
        
        this.user = response.user
        this.accessToken = response.tokens.access
        this.refreshToken = response.tokens.refresh
        
        this.saveToStorage()
        
        return { success: true, message: response.message }
      } catch (error: any) {
        return {
          success: false,
          message: error.data?.non_field_errors?.[0] || 'خطا در ورود'
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
      } catch (error) {
        console.error('Error fetching profile:', error)
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