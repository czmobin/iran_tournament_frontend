<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
    <!-- Hero Section -->
    <div class="bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 text-white py-8 md:py-12 px-4 mb-6 md:mb-8 relative overflow-hidden">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/2 -translate-y-1/2"></div>
        <div class="absolute bottom-0 right-0 w-96 h-96 bg-white rounded-full translate-x-1/2 translate-y-1/2"></div>
      </div>

      <div class="container mx-auto relative z-10">
        <div class="text-center mb-6 md:mb-8">
          <div class="text-5xl md:text-6xl mb-3 md:mb-4 animate-bounce">⚔️</div>
          <h1 class="text-3xl md:text-5xl font-black mb-2 md:mb-3">
            تورنومنت‌های کلش رویال
          </h1>
          <p class="text-base md:text-xl text-white/90 max-w-2xl mx-auto px-4">
            به جنگ‌های حماسی بپیوند و جوایز نقدی بدست بیار!
          </p>
        </div>

        <!-- Quick Stats -->
        <div class="grid grid-cols-3 gap-3 md:gap-6 max-w-3xl mx-auto">
          <div class="bg-white/10 backdrop-blur-lg rounded-xl md:rounded-2xl p-3 md:p-4 border border-white/20 text-center">
            <div class="text-2xl md:text-3xl font-black text-yellow-300">{{ tournamentStore.tournaments.length }}</div>
            <div class="text-xs md:text-sm text-white/80">تورنومنت فعال</div>
          </div>
          <div class="bg-white/10 backdrop-blur-lg rounded-xl md:rounded-2xl p-3 md:p-4 border border-white/20 text-center">
            <div class="text-2xl md:text-3xl font-black text-yellow-300">{{ totalPlayers }}</div>
            <div class="text-xs md:text-sm text-white/80">بازیکن شرکت‌کننده</div>
          </div>
          <div class="bg-white/10 backdrop-blur-lg rounded-xl md:rounded-2xl p-3 md:p-4 border border-white/20 text-center">
            <div class="text-2xl md:text-3xl font-black text-yellow-300">{{ totalPrizes }}</div>
            <div class="text-xs md:text-sm text-white/80">جایزه کل</div>
          </div>
        </div>
      </div>
    </div>

    <div class="container mx-auto px-4 pb-12">
      <!-- Filter Section -->
      <div class="mb-6 md:mb-8">
        <div class="flex items-center gap-2 md:gap-3 mb-3 md:mb-4">
          <div class="text-xl md:text-2xl">🎯</div>
          <h2 class="text-lg md:text-xl font-bold text-gray-800">فیلتر تورنومنت‌ها</h2>
        </div>

        <!-- Status Filter Tabs - Mobile Optimized -->
        <div class="grid grid-cols-2 md:flex md:flex-wrap gap-2 md:gap-3">
          <button
            v-for="filter in statusFilters"
            :key="filter.value"
            @click="selectedStatus = filter.value"
            :class="[
              'px-4 md:px-6 py-3 md:py-3 rounded-xl font-bold transition-all text-sm md:text-base shadow-sm',
              selectedStatus === filter.value
                ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-lg scale-105'
                : 'bg-white text-gray-700 hover:bg-gray-50 active:scale-95'
            ]"
          >
            <span class="mr-1">{{ filter.icon }}</span>
            {{ filter.label }}
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="tournamentStore.isLoading" class="flex flex-col justify-center items-center py-16 md:py-20">
        <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-purple-600 mb-4"></div>
        <p class="text-gray-600 font-bold">در حال بارگذاری تورنومنت‌ها...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="tournamentStore.error" class="bg-white rounded-2xl shadow-xl p-6 md:p-8 text-center">
        <div class="text-6xl mb-4">😕</div>
        <p class="text-red-700 font-bold text-lg mb-4">{{ tournamentStore.error }}</p>
        <button
          @click="loadTournaments"
          class="px-6 md:px-8 py-3 md:py-4 bg-gradient-to-r from-red-600 to-pink-600 text-white rounded-xl font-bold hover:from-red-700 hover:to-pink-700 transition-all shadow-lg active:scale-95"
        >
          🔄 تلاش مجدد
        </button>
      </div>

      <!-- Empty State -->
      <div v-else-if="!filteredTournaments.length" class="bg-white rounded-2xl shadow-xl p-8 md:p-12 text-center">
        <div class="text-7xl md:text-8xl mb-6 animate-pulse">🏆</div>
        <h3 class="text-2xl md:text-3xl font-bold text-gray-700 mb-3">تورنومنتی یافت نشد</h3>
        <p class="text-gray-500 text-base md:text-lg mb-6">در حال حاضر تورنومنتی با این فیلتر وجود ندارد</p>
        <button
          @click="selectedStatus = 'all'"
          class="px-6 md:px-8 py-3 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-xl font-bold hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg active:scale-95"
        >
          مشاهده همه تورنومنت‌ها
        </button>
      </div>

      <!-- Tournaments Grid -->
      <div v-else>
        <div class="flex items-center justify-between mb-4 md:mb-6">
          <div class="text-gray-700 font-bold text-sm md:text-base">
            {{ filteredTournaments.length }} تورنومنت یافت شد
          </div>
          <button
            @click="loadTournaments"
            class="text-purple-600 hover:text-purple-700 text-sm md:text-base font-bold flex items-center gap-2 active:scale-95 transition-transform"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
            </svg>
            به‌روزرسانی
          </button>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4 md:gap-6">
          <TournamentCard
            v-for="tournament in filteredTournaments"
            :key="tournament.id"
            :tournament="tournament"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTournamentStore } from '~/stores/tournament'

definePageMeta({
  layout: 'default'
})

const tournamentStore = useTournamentStore()

// فیلترهای وضعیت با آیکون
const statusFilters = [
  { label: 'همه', value: 'all', icon: '🎮' },
  { label: 'ثبت‌نام', value: 'registration', icon: '🟢' },
  { label: 'در حال برگزاری', value: 'ongoing', icon: '⚡' },
  { label: 'پایان یافته', value: 'finished', icon: '🏁' }
]

const selectedStatus = ref('all')

// محاسبه آمار
const totalPlayers = computed(() => {
  return tournamentStore.tournaments.reduce(
    (sum, t) => sum + t.current_participants,
    0
  )
})

const totalPrizes = computed(() => {
  const total = tournamentStore.tournaments.reduce(
    (sum, t) => sum + t.prize_pool,
    0
  )
  // فرمت میلیونی
  if (total >= 1000000) {
    return Math.floor(total / 1000000) + 'M'
  } else if (total >= 1000) {
    return Math.floor(total / 1000) + 'K'
  }
  return total.toString()
})

// تورنومنت‌های فیلتر شده
const filteredTournaments = computed(() => {
  if (selectedStatus.value === 'all') {
    return tournamentStore.tournaments
  }

  switch (selectedStatus.value) {
    case 'registration':
      return tournamentStore.openTournaments
    case 'ongoing':
      return tournamentStore.ongoingTournaments
    case 'finished':
      return tournamentStore.finishedTournaments
    default:
      return tournamentStore.tournaments
  }
})

// بارگذاری تورنومنت‌ها
const loadTournaments = async () => {
  await tournamentStore.fetchTournaments()
}

// بارگذاری اولیه
onMounted(() => {
  loadTournaments()
})

// به‌روزرسانی وقتی فیلتر تغییر می‌کند
watch(selectedStatus, () => {
  if (selectedStatus.value !== 'all') {
    tournamentStore.fetchTournaments({ status: selectedStatus.value })
  } else {
    loadTournaments()
  }
})

// SEO
useHead({
  title: 'تورنومنت‌ها - ایران تورنومنت',
  meta: [
    { name: 'description', content: 'مشاهده و شرکت در تورنومنت‌های کلش رویال با جوایز نقدی' }
  ]
})
</script>