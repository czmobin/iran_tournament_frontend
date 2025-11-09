<template>
  <div
    @click="goToDetails"
    class="block bg-white rounded-xl md:rounded-2xl shadow-lg md:shadow-xl overflow-hidden hover:shadow-2xl transition transform hover:-translate-y-1 md:hover:-translate-y-2 cursor-pointer active:scale-95"
  >
    <!-- Banner -->
    <div class="h-32 md:h-40 bg-gradient-to-r from-purple-500 to-pink-500 relative">
      <!-- Cover Image if available -->
      <img
        v-if="tournament.cover_image"
        :src="tournament.cover_image"
        :alt="tournament.title"
        class="w-full h-full object-cover"
      />

      <!-- Status Badge -->
      <div
        :class="[
          'absolute top-3 md:top-4 right-3 md:right-4 px-2 md:px-3 py-1 rounded-full text-xs md:text-sm font-bold',
          statusBadgeClass
        ]"
      >
        {{ statusText }}
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
          :class="[
            'h-2 rounded-full transition-all',
            isFull ? 'bg-red-500' : 'bg-purple-600'
          ]"
          :style="{ width: participantsPercent + '%' }"
        ></div>
      </div>

      <!-- Status Badge (instead of button) -->
      <div
        v-if="tournament.status === 'registration'"
        :class="[
          'w-full text-center font-bold py-2.5 md:py-3 rounded-xl text-sm md:text-base',
          isFull ? 'bg-gray-100 text-gray-500' : 'bg-gradient-to-r from-purple-600 to-pink-600 text-white'
        ]"
      >
        {{ isFull ? 'تورنومنت پر شده' : 'مشاهده جزئیات و ثبت‌نام' }}
      </div>

      <div
        v-else
        class="w-full text-center bg-gradient-to-r from-blue-600 to-indigo-600 text-white font-bold py-2.5 md:py-3 rounded-xl text-sm md:text-base"
      >
        مشاهده جزئیات
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { Tournament } from '~/stores/tournament'

const props = defineProps<{
  tournament: Tournament
}>()

const participantsPercent = computed(() => {
  return (props.tournament.current_participants / props.tournament.max_participants) * 100
})

const isFull = computed(() => {
  return props.tournament.current_participants >= props.tournament.max_participants
})

const statusText = computed(() => {
  const statusMap: Record<string, string> = {
    draft: 'پیش‌نویس',
    registration: 'ثبت‌نام',
    ongoing: 'در حال برگزاری',
    finished: 'پایان یافته'
  }
  return statusMap[props.tournament.status] || props.tournament.status
})

const statusBadgeClass = computed(() => {
  const classMap: Record<string, string> = {
    draft: 'bg-gray-500 text-white',
    registration: 'bg-green-500 text-white',
    ongoing: 'bg-yellow-500 text-white',
    finished: 'bg-red-500 text-white'
  }
  return classMap[props.tournament.status] || 'bg-gray-500 text-white'
})

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fa-IR').format(price) + ' تومان'
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fa-IR')
}

const goToDetails = async (event?: MouseEvent) => {
  console.log('🎯 Click detected!', event)

  try {
    // استفاده از slug برای SEO، اگر موجود نبود از ID استفاده می‌کنیم
    const identifier = props.tournament.slug || props.tournament.id
    const url = `/tournaments/${identifier}`
    console.log('🔄 Navigating to:', url, 'Identifier:', identifier, 'Tournament:', props.tournament)

    // در Nuxt 3 باید از navigateTo استفاده کنیم نه router.push
    const result = await navigateTo(url)
    console.log('✅ Navigation result:', result)
  } catch (error) {
    console.error('❌ Navigation error:', error)
    // نمایش خطا به کاربر
    alert('خطا در باز کردن صفحه: ' + (error as Error).message)
  }
}
</script>
