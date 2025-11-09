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
    lastFetch: null as number | null,
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

    // آیا نیاز به refresh دارد؟ (هر 30 ثانیه)
    shouldRefresh: (state) => {
      if (!state.lastFetch) return true
      const thirtySeconds = 30 * 1000
      return Date.now() - state.lastFetch > thirtySeconds
    }
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

        console.log('[Notifications] Fetching from:', url)

        const response = await apiFetch(url)
        this.notifications = response.results || response
        this.lastFetch = Date.now()

        // محاسبه تعداد اعلان‌های خوانده نشده
        this.unreadCount = this.notifications.filter(n => !n.is_read).length

        console.log('[Notifications] Loaded:', this.notifications.length, 'Unread:', this.unreadCount)

        return { success: true }
      } catch (error: any) {
        console.error('[Notifications] Error fetching:', error)
        this.error = error.data?.message || 'خطا در دریافت اعلان‌ها'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // دریافت تعداد اعلان‌های خوانده نشده
    async fetchUnreadCount() {
      try {
        const { apiFetch } = useApi()
        const response = await apiFetch('/notifications/unread-count/')
        this.unreadCount = response.count || 0
        return { success: true, count: this.unreadCount }
      } catch (error: any) {
        console.error('[Notifications] Error fetching unread count:', error)
        return { success: false }
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
        if (notification && !notification.is_read) {
          notification.is_read = true
          this.unreadCount = Math.max(0, this.unreadCount - 1)
        }

        console.log('[Notifications] Marked as read:', notificationId)

        return { success: true }
      } catch (error: any) {
        console.error('[Notifications] Error marking as read:', error)
        this.error = error.data?.message || 'خطا در علامت‌گذاری اعلان'
        return { success: false, message: this.error }
      }
    },

    // علامت‌گذاری همه اعلان‌ها به عنوان خوانده شده
    async markAllAsRead() {
      try {
        this.error = null
        const { apiFetch } = useApi()

        // سعی کن endpoint مخصوص mark all as read رو صدا بزن
        try {
          await apiFetch('/notifications/mark-all-read/', {
            method: 'PUT'
          })
        } catch (error) {
          // اگه endpoint وجود نداشت، یکی یکی mark کن
          const unreadIds = this.unreadNotifications.map(n => n.id)
          await Promise.all(
            unreadIds.map(id => this.markAsRead(id))
          )
        }

        // به‌روزرسانی همه اعلان‌ها در لیست محلی
        this.notifications.forEach(n => {
          n.is_read = true
        })
        this.unreadCount = 0

        console.log('[Notifications] Marked all as read')

        return { success: true }
      } catch (error: any) {
        console.error('[Notifications] Error marking all as read:', error)
        this.error = error.data?.message || 'خطا در علامت‌گذاری اعلان‌ها'
        return { success: false, message: this.error }
      }
    },

    // حذف یک اعلان
    async deleteNotification(notificationId: number) {
      try {
        this.error = null
        const { apiFetch } = useApi()

        await apiFetch(`/notifications/${notificationId}/`, {
          method: 'DELETE'
        })

        // حذف از لیست محلی
        const index = this.notifications.findIndex(n => n.id === notificationId)
        if (index !== -1) {
          const wasUnread = !this.notifications[index].is_read
          this.notifications.splice(index, 1)
          if (wasUnread) {
            this.unreadCount = Math.max(0, this.unreadCount - 1)
          }
        }

        console.log('[Notifications] Deleted:', notificationId)

        return { success: true }
      } catch (error: any) {
        console.error('[Notifications] Error deleting:', error)
        this.error = error.data?.message || 'خطا در حذف اعلان'
        return { success: false, message: this.error }
      }
    },

    // پاک کردن خطا
    clearError() {
      this.error = null
    },

    // reset store
    reset() {
      this.notifications = []
      this.unreadCount = 0
      this.isLoading = false
      this.error = null
      this.lastFetch = null
    }
  }
})
