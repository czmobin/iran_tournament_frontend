export interface ChatMessage {
  id: number
  user: {
    id: number
    username: string
    first_name: string
    last_name: string
  }
  tournament: number
  message: string
  created_at: string
  is_deleted: boolean
}

export const useTournamentChat = () => {
  const { apiFetch } = useApi()

  const messages = ref<ChatMessage[]>([])
  const isLoading = ref(false)
  const error = ref<string | null>(null)

  // دریافت پیام‌های چت
  const fetchMessages = async (tournamentSlug: string) => {
    try {
      isLoading.value = true
      error.value = null

      // Encode slug برای سازگاری با slug های فارسی
      const encodedSlug = typeof tournamentSlug === 'string' && isNaN(Number(tournamentSlug))
        ? encodeURIComponent(tournamentSlug)
        : tournamentSlug

      const response = await apiFetch(`/tournaments/chat/tournament/${encodedSlug}/`)
      messages.value = response.results || response

      return { success: true }
    } catch (err: any) {
      error.value = err.data?.message || 'خطا در دریافت پیام‌ها'
      return { success: false, message: error.value }
    } finally {
      isLoading.value = false
    }
  }

  // ارسال پیام جدید
  const sendMessage = async (tournamentId: number | string, message: string) => {
    try {
      error.value = null

      const response = await apiFetch('/tournaments/chat/', {
        method: 'POST',
        body: {
          tournament: tournamentId,
          message
        }
      })

      // اضافه کردن پیام جدید به لیست
      messages.value.push(response)

      return { success: true, message: response }
    } catch (err: any) {
      error.value = err.data?.message || 'خطا در ارسال پیام'
      return { success: false, message: error.value }
    }
  }

  // حذف پیام
  const deleteMessage = async (messageId: number) => {
    try {
      error.value = null

      await apiFetch(`/tournaments/chat/${messageId}/delete-message/`, {
        method: 'POST'
      })

      // حذف یا علامت‌گذاری پیام در لیست
      const messageIndex = messages.value.findIndex(m => m.id === messageId)
      if (messageIndex !== -1) {
        messages.value[messageIndex].is_deleted = true
      }

      return { success: true }
    } catch (err: any) {
      error.value = err.data?.message || 'خطا در حذف پیام'
      return { success: false, message: error.value }
    }
  }

  return {
    messages,
    isLoading,
    error,
    fetchMessages,
    sendMessage,
    deleteMessage
  }
}
