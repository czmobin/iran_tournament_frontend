import { defineStore } from 'pinia'

export interface Notification {
  id: number
  user: number
  title: string
  message: string
  notification_type: 'info' | 'success' | 'warning' | 'error' | 'tournament' | 'payment'
  is_read: boolean
  created_at: string
  updated_at: string
  link?: string
}

export const useNotificationsStore = defineStore('notifications', {
  state: () => ({
    notifications: [] as Notification[],
    unreadCount: 0,
    isLoading: false,
    error: null as string | null,
  }),

  getters: {
    // فیلتر اعلان‌های خوانده نشده
    unreadNotifications: (state) =>
      state.notifications.filter(n => !n.is_read),

    // فیلتر بر اساس نوع
    tournamentNotifications: (state) =>
      state.notifications.filter(n => n.notification_type === 'tournament'),

    paymentNotifications: (state) =>
      state.notifications.filter(n => n.notification_type === 'payment'),
  },

  actions: {
    // دریافت لیست اعلان‌ها
    async fetchNotifications(filters?: { is_read?: boolean; limit?: number }) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        let url = '/notifications/'
        const params = new URLSearchParams()

        if (filters?.is_read !== undefined) params.append('is_read', String(filters.is_read))
        if (filters?.limit) params.append('limit', filters.limit.toString())

        if (params.toString()) {
          url += `?${params.toString()}`
        }

        const response = await apiFetch(url)
        this.notifications = response.results || response

        // محاسبه تعداد اعلان‌های خوانده نشده
        this.unreadCount = this.notifications.filter(n => !n.is_read).length

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت اعلان‌ها'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // علامت‌گذاری اعلان به عنوان خوانده شده
    async markAsRead(notificationId: number) {
      try {
        this.error = null
        const { apiFetch } = useApi()

        await apiFetch(`/notifications/${notificationId}/mark-read/`, {
          method: 'PUT'
        })

        // به‌روزرسانی در لیست محلی
        const notification = this.notifications.find(n => n.id === notificationId)
        if (notification) {
          notification.is_read = true
          this.unreadCount = Math.max(0, this.unreadCount - 1)
        }

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در علامت‌گذاری اعلان'
        return { success: false, message: this.error }
      }
    },

    // علامت‌گذاری همه اعلان‌ها به عنوان خوانده شده
    async markAllAsRead() {
      try {
        this.error = null

        // علامت‌گذاری همه اعلان‌های خوانده نشده
        const unreadIds = this.unreadNotifications.map(n => n.id)

        await Promise.all(
          unreadIds.map(id => this.markAsRead(id))
        )

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در علامت‌گذاری اعلان‌ها'
        return { success: false, message: this.error }
      }
    },

    // پاک کردن خطا
    clearError() {
      this.error = null
    }
  }
})
