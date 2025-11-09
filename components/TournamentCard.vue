<template>
  <div class="bg-white rounded-xl md:rounded-2xl shadow-lg md:shadow-xl overflow-hidden hover:shadow-2xl transition transform hover:-translate-y-1 md:hover:-translate-y-2">
    <!-- Banner -->
    <div class="h-32 md:h-40 bg-gradient-to-r from-purple-500 to-pink-500 relative">
      <div class="absolute top-3 md:top-4 right-3 md:right-4 bg-green-500 text-white px-2 md:px-3 py-1 rounded-full text-xs md:text-sm font-bold">
        {{ tournament.status }}
      </div>
    </div>

    <!-- Content -->
    <div class="p-4 md:p-6">
      <h3 class="text-lg md:text-2xl font-bold text-gray-800 mb-2">
        {{ tournament.title }}
      </h3>
      
      <p class="text-sm md:text-base text-gray-600 mb-3 md:mb-4 line-clamp-2">
        {{ tournament.description }}
      </p>

      <!-- Info -->
      <div class="flex justify-between items-center mb-3 md:mb-4">
        <div>
          <div class="text-xs md:text-sm text-gray-500">ورودی</div>
          <div class="text-base md:text-lg font-bold text-purple-600">
            {{ formatPrice(tournament.entry_fee) }}
          </div>
        </div>

        <div class="text-left">
          <div class="text-xs md:text-sm text-gray-500">جایزه</div>
          <div class="text-base md:text-lg font-bold text-green-600">
            🏆 {{ formatPrice(tournament.prize_pool) }}
          </div>
        </div>
      </div>

      <!-- Players & Date -->
      <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-2 mb-3 md:mb-4">
        <div class="text-xs md:text-sm text-gray-600">
          👥 {{ tournament.current_participants }} / {{ tournament.max_participants }} بازیکن
        </div>
        
        <div class="text-xs md:text-sm text-gray-600">
          📅 {{ formatDate(tournament.start_date) }}
        </div>
      </div>

      <!-- Progress Bar -->
      <div class="w-full bg-gray-200 rounded-full h-2 mb-3 md:mb-4">
        <div 
          class="bg-purple-600 h-2 rounded-full transition-all"
          :style="{ width: participantsPercent + '%' }"
        ></div>
      </div>

      <!-- Button -->
      <button 
        class="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-2.5 md:py-3 rounded-xl hover:from-purple-700 hover:to-pink-700 transition text-sm md:text-base"
        @click="joinTournament"
      >
        ثبت‌نام در تورنومنت
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  tournament: {
    id: number
    title: string
    description: string
    entry_fee: number
    prize_pool: number
    max_participants: number
    current_participants: number
    start_date: string
    status: string
  }
}>()

const participantsPercent = computed(() => {
  return (props.tournament.current_participants / props.tournament.max_participants) * 100
})

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fa-IR').format(price) + ' تومان'
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fa-IR')
}

const joinTournament = () => {
  alert('قابلیت ثبت‌نام بزودی اضافه میشه!')
}
</script>
