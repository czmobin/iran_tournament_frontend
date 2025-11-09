<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
    <!-- Loading State -->
    <div v-if="isLoading" class="flex flex-col justify-center items-center py-16 md:py-20">
      <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-purple-600 mb-4"></div>
      <p class="text-gray-600 font-bold">در حال بارگذاری جزئیات...</p>
    </div>

    <!-- Error State -->
    <div v-else-if="error" class="container mx-auto px-4 py-12">
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl p-6 md:p-8 text-center">
        <div class="text-6xl mb-4">😕</div>
        <p class="text-red-700 font-bold text-lg mb-4">{{ error }}</p>
        <NuxtLink
          to="/tournaments"
          class="inline-block px-6 md:px-8 py-3 md:py-4 bg-gradient-to-r from-red-600 to-pink-600 text-white rounded-xl font-bold hover:from-red-700 hover:to-pink-700 transition-all shadow-lg active:scale-95"
        >
          🔙 بازگشت به لیست تورنومنت‌ها
        </NuxtLink>
      </div>
    </div>

    <!-- Tournament Details -->
    <div v-else-if="tournament" class="container mx-auto px-4 py-6 md:py-12">
      <!-- Back Button (Mobile) -->
      <button
        @click="$router.back()"
        class="mb-4 md:hidden flex items-center gap-2 text-purple-600 font-bold active:scale-95 transition-transform"
      >
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
        </svg>
        بازگشت
      </button>

      <!-- Header -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl overflow-hidden mb-4 md:mb-6">
        <!-- Cover Image -->
        <div class="h-48 md:h-64 bg-gradient-to-r from-purple-500 via-pink-500 to-blue-500 relative">
          <img
            v-if="tournament.cover_image"
            :src="tournament.cover_image"
            :alt="tournament.title"
            class="w-full h-full object-cover"
          />

          <!-- Status Badge -->
          <div
            :class="[
              'absolute top-3 md:top-4 right-3 md:right-4 px-3 md:px-4 py-1.5 md:py-2 rounded-full text-xs md:text-sm font-bold shadow-lg',
              statusBadgeClass
            ]"
          >
            {{ statusText }}
          </div>
        </div>

        <!-- Tournament Info -->
        <div class="p-4 md:p-8">
          <h1 class="text-2xl md:text-4xl font-black text-gray-800 mb-3 md:mb-4">
            {{ tournament.title }}
          </h1>

          <p class="text-sm md:text-lg text-gray-600 mb-4 md:mb-6">
            {{ tournament.description }}
          </p>

          <!-- Stats Grid - Mobile Optimized -->
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4 mb-4 md:mb-6">
            <div class="bg-gradient-to-br from-purple-50 to-purple-100 rounded-xl md:rounded-2xl p-3 md:p-4 text-center border border-purple-200">
              <div class="text-lg md:text-2xl font-black text-purple-600 mb-1">
                {{ formatPrice(tournament.entry_fee) }}
              </div>
              <div class="text-xs md:text-sm text-gray-600">💰 هزینه ورودی</div>
            </div>

            <div class="bg-gradient-to-br from-green-50 to-green-100 rounded-xl md:rounded-2xl p-3 md:p-4 text-center border border-green-200">
              <div class="text-lg md:text-2xl font-black text-green-600 mb-1">
                {{ formatPrice(tournament.prize_pool) }}
              </div>
              <div class="text-xs md:text-sm text-gray-600">🏆 جایزه کل</div>
            </div>

            <div class="bg-gradient-to-br from-blue-50 to-blue-100 rounded-xl md:rounded-2xl p-3 md:p-4 text-center border border-blue-200">
              <div class="text-lg md:text-2xl font-black text-blue-600 mb-1">
                {{ tournament.current_participants }} / {{ tournament.max_participants }}
              </div>
              <div class="text-xs md:text-sm text-gray-600">👥 شرکت‌کنندگان</div>
            </div>

            <div class="bg-gradient-to-br from-yellow-50 to-yellow-100 rounded-xl md:rounded-2xl p-3 md:p-4 text-center border border-yellow-200">
              <div class="text-lg md:text-2xl font-black text-yellow-600 mb-1">
                {{ formatDate(tournament.start_date) }}
              </div>
              <div class="text-xs md:text-sm text-gray-600">📅 تاریخ شروع</div>
            </div>
          </div>

          <!-- Action Button -->
          <div v-if="authStore.isAuthenticated">
            <button
              v-if="tournament.status === 'registration' && !isUserParticipant"
              @click="handleJoinTournament"
              :disabled="isFull || joiningTournament"
              class="w-full md:w-auto px-8 py-4 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold rounded-xl hover:from-purple-700 hover:to-pink-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
            >
              {{ joiningTournament ? 'در حال ثبت‌نام...' : isFull ? 'تورنومنت پر شده' : 'ثبت‌نام در تورنومنت' }}
            </button>

            <div
              v-else-if="isUserParticipant"
              class="bg-green-50 border-2 border-green-500 rounded-xl p-4 text-center"
            >
              <div class="text-green-700 font-bold text-lg">
                ✅ شما در این تورنومنت ثبت‌نام کرده‌اید
              </div>
            </div>
          </div>
          <div v-else class="bg-yellow-50 border-l-4 border-yellow-500 p-4 rounded-lg">
            <p class="text-yellow-700">
              برای ثبت‌نام در تورنومنت، لطفاً
              <NuxtLink to="/login" class="font-bold underline">وارد شوید</NuxtLink>
            </p>
          </div>
        </div>
      </div>

      <!-- Tabs -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl overflow-hidden">
        <!-- Tab Headers - Mobile Scrollable -->
        <div class="flex border-b overflow-x-auto scrollbar-hide">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="[
              'flex-shrink-0 px-4 md:px-6 py-3 md:py-4 font-bold transition-all text-sm md:text-base',
              activeTab === tab.id
                ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-md'
                : 'text-gray-600 hover:bg-gray-100 active:bg-gray-200'
            ]"
          >
            <span class="mr-1">{{ tab.icon }}</span>
            {{ tab.label }}
          </button>
        </div>

        <!-- Tab Content -->
        <div class="p-4 md:p-6">
          <!-- Rules Tab -->
          <div v-if="activeTab === 'rules'">
            <h3 class="text-2xl font-bold text-gray-800 mb-4">قوانین تورنومنت</h3>
            <div class="prose max-w-none text-gray-700" v-html="tournament.rules || 'قوانین هنوز تعیین نشده است.'"></div>
          </div>

          <!-- Participants Tab -->
          <div v-else-if="activeTab === 'participants'">
            <h3 class="text-2xl font-bold text-gray-800 mb-4">
              شرکت‌کنندگان ({{ participants.length }})
            </h3>

            <div v-if="loadingParticipants" class="flex justify-center py-8">
              <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
            </div>

            <div v-else-if="participants.length === 0" class="text-center py-8 text-gray-500">
              هنوز کسی ثبت‌نام نکرده است
            </div>

            <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
              <div
                v-for="participant in participants"
                :key="participant.id"
                class="bg-gray-50 rounded-xl p-4 flex items-center gap-4"
              >
                <div class="w-12 h-12 bg-gradient-to-r from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-xl">
                  {{ participant.user.username.charAt(0).toUpperCase() }}
                </div>
                <div class="flex-1">
                  <div class="font-bold text-gray-800">
                    {{ participant.user.first_name }} {{ participant.user.last_name }}
                  </div>
                  <div class="text-sm text-gray-500">@{{ participant.user.username }}</div>
                  <div v-if="participant.user.clash_royale_tag" class="text-xs text-purple-600">
                    {{ participant.user.clash_royale_tag }}
                  </div>
                </div>
                <div
                  v-if="participant.status === 'confirmed'"
                  class="text-green-500 text-2xl"
                  title="تایید شده"
                >
                  ✓
                </div>
              </div>
            </div>
          </div>

          <!-- Rankings Tab -->
          <div v-else-if="activeTab === 'rankings'">
            <h3 class="text-xl md:text-2xl font-bold text-gray-800 mb-4">🏆 رنکینگ و جدول امتیازات</h3>

            <div v-if="loadingRankings" class="flex justify-center py-8">
              <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
            </div>

            <div v-else-if="rankings.length === 0" class="text-center py-8 text-gray-500">
              <div class="text-6xl mb-4">🏆</div>
              <p>هنوز رنکینگی ثبت نشده است</p>
            </div>

            <!-- Mobile: Card Layout -->
            <div v-else class="block md:hidden space-y-3">
              <div
                v-for="(ranking, index) in rankings"
                :key="ranking.id"
                :class="[
                  'rounded-xl p-4 border-2',
                  index === 0 ? 'bg-gradient-to-r from-yellow-50 to-yellow-100 border-yellow-300' :
                  index === 1 ? 'bg-gradient-to-r from-gray-50 to-gray-100 border-gray-300' :
                  index === 2 ? 'bg-gradient-to-r from-orange-50 to-orange-100 border-orange-300' :
                  'bg-white border-gray-200'
                ]"
              >
                <div class="flex items-center justify-between mb-3">
                  <div class="flex items-center gap-3">
                    <div class="text-3xl">
                      <span v-if="index === 0">🥇</span>
                      <span v-else-if="index === 1">🥈</span>
                      <span v-else-if="index === 2">🥉</span>
                      <span v-else class="text-xl font-bold text-gray-600">#{{ ranking.rank }}</span>
                    </div>
                    <div>
                      <div class="font-bold text-gray-800">
                        {{ ranking.user.first_name }} {{ ranking.user.last_name }}
                      </div>
                      <div class="text-sm text-gray-500">@{{ ranking.user.username }}</div>
                    </div>
                  </div>
                  <div class="text-2xl font-black text-blue-600">
                    {{ ranking.score }}
                  </div>
                </div>

                <div class="grid grid-cols-3 gap-2 mt-3 pt-3 border-t border-gray-200">
                  <div class="text-center">
                    <div class="text-lg font-bold text-green-600">{{ ranking.wins }}</div>
                    <div class="text-xs text-gray-500">برد</div>
                  </div>
                  <div class="text-center">
                    <div class="text-lg font-bold text-red-600">{{ ranking.losses }}</div>
                    <div class="text-xs text-gray-500">باخت</div>
                  </div>
                  <div class="text-center">
                    <div class="text-lg font-bold text-gray-600">{{ ranking.draws }}</div>
                    <div class="text-xs text-gray-500">مساوی</div>
                  </div>
                </div>

                <div class="mt-2 text-center text-sm text-purple-600 font-bold">
                  👑 تاج‌ها: {{ ranking.crowns_earned }} - {{ ranking.crowns_lost }}
                </div>
              </div>
            </div>

            <!-- Desktop: Table Layout -->
            <div v-else class="hidden md:block overflow-x-auto">
              <table class="w-full">
                <thead>
                  <tr class="bg-gradient-to-r from-purple-100 to-pink-100 text-gray-700">
                    <th class="px-4 py-3 text-right">رنک</th>
                    <th class="px-4 py-3 text-right">بازیکن</th>
                    <th class="px-4 py-3 text-center">برد</th>
                    <th class="px-4 py-3 text-center">باخت</th>
                    <th class="px-4 py-3 text-center">مساوی</th>
                    <th class="px-4 py-3 text-center">تاج‌ها</th>
                    <th class="px-4 py-3 text-center">امتیاز</th>
                  </tr>
                </thead>
                <tbody>
                  <tr
                    v-for="(ranking, index) in rankings"
                    :key="ranking.id"
                    :class="[
                      index % 2 === 0 ? 'bg-white' : 'bg-gray-50',
                      index === 0 ? 'bg-yellow-50' : ''
                    ]"
                  >
                    <td class="px-4 py-3 font-bold">
                      <span v-if="index === 0" class="text-2xl">🥇</span>
                      <span v-else-if="index === 1" class="text-2xl">🥈</span>
                      <span v-else-if="index === 2" class="text-2xl">🥉</span>
                      <span v-else>{{ ranking.rank }}</span>
                    </td>
                    <td class="px-4 py-3 font-bold text-gray-800">
                      {{ ranking.user.first_name }} {{ ranking.user.last_name }}
                    </td>
                    <td class="px-4 py-3 text-center text-green-600 font-bold">{{ ranking.wins }}</td>
                    <td class="px-4 py-3 text-center text-red-600 font-bold">{{ ranking.losses }}</td>
                    <td class="px-4 py-3 text-center text-gray-600 font-bold">{{ ranking.draws }}</td>
                    <td class="px-4 py-3 text-center text-purple-600 font-bold">
                      {{ ranking.crowns_earned }} - {{ ranking.crowns_lost }}
                    </td>
                    <td class="px-4 py-3 text-center text-blue-600 font-bold text-lg">
                      {{ ranking.score }}
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>

          <!-- Chat Tab -->
          <div v-else-if="activeTab === 'chat'">
            <TournamentChat
              v-if="tournament"
              :tournament-id="tournament.id"
              :tournament-slug="tournament.slug"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTournamentStore } from '~/stores/tournament'
import { useAuthStore } from '~/stores/auth'

definePageMeta({
  layout: 'default'
})

const route = useRoute()
const tournamentStore = useTournamentStore()
const authStore = useAuthStore()

const tournamentId = route.params.id as string

const isLoading = ref(true)
const error = ref<string | null>(null)
const activeTab = ref('rules')
const loadingParticipants = ref(false)
const loadingRankings = ref(false)
const joiningTournament = ref(false)

const tabs = [
  { id: 'rules', label: 'قوانین', icon: '📋' },
  { id: 'participants', label: 'شرکت‌کنندگان', icon: '👥' },
  { id: 'rankings', label: 'رنکینگ', icon: '🏆' },
  { id: 'chat', label: 'چت', icon: '💬' }
]

const tournament = computed(() => tournamentStore.currentTournament)
const participants = computed(() => tournamentStore.participants)
const rankings = computed(() => tournamentStore.rankings)

const isFull = computed(() => {
  if (!tournament.value) return false
  return tournament.value.current_participants >= tournament.value.max_participants
})

const isUserParticipant = computed(() => tournamentStore.isUserParticipant)

const statusText = computed(() => {
  if (!tournament.value) return ''
  const statusMap: Record<string, string> = {
    draft: 'پیش‌نویس',
    registration: 'ثبت‌نام',
    ongoing: 'در حال برگزاری',
    finished: 'پایان یافته'
  }
  return statusMap[tournament.value.status] || tournament.value.status
})

const statusBadgeClass = computed(() => {
  if (!tournament.value) return ''
  const classMap: Record<string, string> = {
    draft: 'bg-gray-500 text-white',
    registration: 'bg-green-500 text-white',
    ongoing: 'bg-yellow-500 text-white',
    finished: 'bg-red-500 text-white'
  }
  return classMap[tournament.value.status] || 'bg-gray-500 text-white'
})

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fa-IR').format(price) + ' تومان'
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fa-IR')
}

const loadTournamentDetails = async () => {
  isLoading.value = true
  error.value = null

  const result = await tournamentStore.fetchTournamentDetails(tournamentId)

  if (!result.success) {
    error.value = result.message || 'خطا در بارگذاری جزئیات تورنومنت'
  }

  isLoading.value = false
}

const loadParticipants = async () => {
  loadingParticipants.value = true
  await tournamentStore.fetchParticipants(tournamentId)
  loadingParticipants.value = false
}

const loadRankings = async () => {
  loadingRankings.value = true
  await tournamentStore.fetchRankings(tournamentId)
  loadingRankings.value = false
}

const handleJoinTournament = async () => {
  if (!authStore.isAuthenticated) {
    navigateTo('/login')
    return
  }

  joiningTournament.value = true

  const result = await tournamentStore.joinTournament(tournamentId)

  if (result.success) {
    alert('✅ ' + result.message)
    // بارگذاری مجدد شرکت‌کنندگان
    await loadParticipants()
  } else {
    alert('❌ ' + result.message)
  }

  joiningTournament.value = false
}

// بارگذاری اولیه
onMounted(async () => {
  await loadTournamentDetails()
  if (tournament.value) {
    await loadParticipants()
  }
})

// بارگذاری رنکینگ وقتی تب تغییر می‌کند
watch(activeTab, async (newTab) => {
  if (newTab === 'rankings' && rankings.value.length === 0) {
    await loadRankings()
  }
})

// پاک کردن داده‌ها هنگام خروج از صفحه
onUnmounted(() => {
  tournamentStore.clearCurrentTournament()
})
</script>
