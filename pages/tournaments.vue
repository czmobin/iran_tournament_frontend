<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-12">
      <!-- Header -->
      <div class="flex flex-col md:flex-row md:items-center md:justify-between mb-8">
        <h1 class="text-4xl font-black text-gray-800 mb-4 md:mb-0">
          تورنومنت‌ها ⚔️
        </h1>

        <!-- Status Filter Tabs -->
        <div class="flex gap-2 bg-white rounded-xl p-1 shadow-sm">
          <button
            v-for="filter in statusFilters"
            :key="filter.value"
            @click="selectedStatus = filter.value"
            :class="[
              'px-4 py-2 rounded-lg font-bold transition-all text-sm',
              selectedStatus === filter.value
                ? 'bg-gradient-to-r from-purple-600 to-blue-600 text-white shadow-md'
                : 'text-gray-600 hover:bg-gray-100'
            ]"
          >
            {{ filter.label }}
          </button>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="tournamentStore.isLoading" class="flex justify-center items-center py-20">
        <div class="animate-spin rounded-full h-16 w-16 border-t-4 border-b-4 border-purple-600"></div>
      </div>

      <!-- Error State -->
      <div v-else-if="tournamentStore.error" class="bg-red-50 border-l-4 border-red-500 p-6 rounded-lg">
        <p class="text-red-700 font-bold">{{ tournamentStore.error }}</p>
        <button
          @click="loadTournaments"
          class="mt-4 px-6 py-2 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors"
        >
          تلاش مجدد
        </button>
      </div>

      <!-- Empty State -->
      <div v-else-if="!filteredTournaments.length" class="text-center py-20">
        <div class="text-6xl mb-4">🏆</div>
        <h3 class="text-2xl font-bold text-gray-700 mb-2">تورنومنتی یافت نشد</h3>
        <p class="text-gray-500">در حال حاضر تورنومنتی با این فیلتر وجود ندارد</p>
      </div>

      <!-- Tournaments Grid -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <TournamentCard
          v-for="tournament in filteredTournaments"
          :key="tournament.id"
          :tournament="tournament"
        />
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

// فیلترهای وضعیت
const statusFilters = [
  { label: 'همه', value: 'all' },
  { label: 'ثبت‌نام', value: 'registration' },
  { label: 'در حال برگزاری', value: 'ongoing' },
  { label: 'پایان یافته', value: 'finished' }
]

const selectedStatus = ref('all')

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
</script>