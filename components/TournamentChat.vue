<template>
  <div class="flex flex-col h-[600px] bg-gray-50 rounded-xl overflow-hidden">
    <!-- Chat Header -->
    <div class="bg-gradient-to-r from-purple-600 to-pink-600 text-white p-4">
      <h3 class="text-xl font-bold">💬 چت تورنومنت</h3>
      <p class="text-sm opacity-90">{{ messages.length }} پیام</p>
    </div>

    <!-- Messages Container -->
    <div
      ref="messagesContainer"
      class="flex-1 overflow-y-auto p-4 space-y-4"
    >
      <!-- Loading State -->
      <div v-if="isLoading && messages.length === 0" class="flex justify-center py-8">
        <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
      </div>

      <!-- Empty State -->
      <div v-else-if="messages.length === 0" class="text-center py-12 text-gray-500">
        <div class="text-6xl mb-4">💬</div>
        <p>هنوز پیامی ارسال نشده است</p>
        <p class="text-sm mt-2">اولین نفری باشید که پیام می‌فرستد!</p>
      </div>

      <!-- Messages -->
      <div
        v-for="message in messages"
        :key="message.id"
        :class="[
          'flex',
          message.user.id === authStore.user?.id ? 'justify-end' : 'justify-start'
        ]"
      >
        <div
          :class="[
            'max-w-[70%] rounded-2xl p-4 shadow-sm',
            message.user.id === authStore.user?.id
              ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
              : 'bg-white text-gray-800'
          ]"
        >
          <!-- User Info (only for other users) -->
          <div
            v-if="message.user.id !== authStore.user?.id"
            class="flex items-center gap-2 mb-2"
          >
            <div class="w-8 h-8 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-sm">
              {{ message.user.username.charAt(0).toUpperCase() }}
            </div>
            <div class="text-sm font-bold">
              {{ message.user.first_name }} {{ message.user.last_name }}
            </div>
          </div>

          <!-- Message Content -->
          <div v-if="!message.is_deleted" class="mb-2">
            {{ message.message }}
          </div>
          <div v-else class="italic opacity-70 mb-2">
            پیام حذف شده
          </div>

          <!-- Message Footer -->
          <div class="flex items-center justify-between gap-4">
            <div
              :class="[
                'text-xs opacity-75',
                message.user.id === authStore.user?.id ? 'text-white' : 'text-gray-500'
              ]"
            >
              {{ formatTime(message.created_at) }}
            </div>

            <!-- Delete Button (only for own messages) -->
            <button
              v-if="message.user.id === authStore.user?.id && !message.is_deleted"
              @click="handleDeleteMessage(message.id)"
              class="text-xs opacity-75 hover:opacity-100 transition"
            >
              🗑️
            </button>
          </div>
        </div>
      </div>

      <!-- Loading More Indicator -->
      <div v-if="isLoading && messages.length > 0" class="flex justify-center py-2">
        <div class="animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-purple-600"></div>
      </div>
    </div>

    <!-- Message Input -->
    <div class="bg-white border-t p-4">
      <form @submit.prevent="handleSendMessage" class="flex gap-2">
        <input
          v-model="newMessage"
          type="text"
          placeholder="پیام خود را بنویسید..."
          class="flex-1 px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-purple-600 focus:outline-none"
          :disabled="!authStore.isAuthenticated"
        />

        <button
          type="submit"
          :disabled="!newMessage.trim() || isSending || !authStore.isAuthenticated"
          class="px-6 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold rounded-xl hover:from-purple-700 hover:to-pink-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
        >
          {{ isSending ? '...' : '📤' }}
        </button>
      </form>

      <div v-if="!authStore.isAuthenticated" class="text-sm text-gray-500 mt-2 text-center">
        برای ارسال پیام باید وارد شوید
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/auth'
import { useTournamentChat } from '~/composables/useTournamentChat'

const props = defineProps<{
  tournamentId: number | string
  tournamentSlug: string
}>()

const authStore = useAuthStore()
const { messages, isLoading, fetchMessages, sendMessage, deleteMessage } = useTournamentChat()

const messagesContainer = ref<HTMLElement | null>(null)
const newMessage = ref('')
const isSending = ref(false)

const formatTime = (date: string) => {
  const messageDate = new Date(date)
  const now = new Date()
  const diffInHours = (now.getTime() - messageDate.getTime()) / (1000 * 60 * 60)

  if (diffInHours < 24) {
    return messageDate.toLocaleTimeString('fa-IR', {
      hour: '2-digit',
      minute: '2-digit'
    })
  } else {
    return messageDate.toLocaleDateString('fa-IR', {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    })
  }
}

const scrollToBottom = () => {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
    }
  })
}

const handleSendMessage = async () => {
  if (!newMessage.value.trim()) return

  isSending.value = true

  const result = await sendMessage(props.tournamentId, newMessage.value.trim())

  if (result.success) {
    newMessage.value = ''
    scrollToBottom()
  } else {
    alert('❌ ' + result.message)
  }

  isSending.value = false
}

const handleDeleteMessage = async (messageId: number) => {
  if (!confirm('آیا مطمئن هستید که می‌خواهید این پیام را حذف کنید؟')) {
    return
  }

  const result = await deleteMessage(messageId)

  if (!result.success) {
    alert('❌ ' + result.message)
  }
}

// بارگذاری اولیه پیام‌ها
onMounted(async () => {
  await fetchMessages(props.tournamentSlug)
  scrollToBottom()
})

// Auto-refresh every 10 seconds
let refreshInterval: NodeJS.Timeout

onMounted(() => {
  refreshInterval = setInterval(() => {
    fetchMessages(props.tournamentSlug)
  }, 10000) // 10 seconds
})

onUnmounted(() => {
  if (refreshInterval) {
    clearInterval(refreshInterval)
  }
})

// Scroll to bottom when new messages arrive
watch(
  () => messages.value.length,
  () => {
    scrollToBottom()
  }
)
</script>
