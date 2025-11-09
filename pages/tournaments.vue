<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-12">
      <h1 class="text-4xl font-black text-gray-800 mb-8">
        تورنومنت‌های فعال ⚔️
      </h1>

      <!-- Grid of Tournaments -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <TournamentCard 
          v-for="tournament in tournaments" 
          :key="tournament.id"
          :tournament="tournament"
        />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// داده‌های نمونه
const tournaments = ref([
  {
    id: 1,
    title: 'تورنومنت طلایی',
    description: 'تورنومنت بزرگ فصل پاییز',
    entry_fee: 50000,
    prize_pool: 2000000,
    max_participants: 32,
    current_participants: 24,
    start_date: '2024-11-15',
    status: 'ثبت‌نام'
  },
  {
    id: 2,
    title: 'جام قهرمانان',
    description: 'مسابقات حرفه‌ای',
    entry_fee: 100000,
    prize_pool: 5000000,
    max_participants: 64,
    current_participants: 48,
    start_date: '2024-11-20',
    status: 'ثبت‌نام'
  },
  {
    id: 3,
    title: 'لیگ برنزی',
    description: 'برای بازیکنان مبتدی',
    entry_fee: 20000,
    prize_pool: 500000,
    max_participants: 16,
    current_participants: 12,
    start_date: '2024-11-18',
    status: 'ثبت‌نام'
  },
  {
    id: 4,
    title: 'لیگ برنزی',
    description: 'برای بازیکنان مبتدی',
    entry_fee: 20000,
    prize_pool: 500000,
    max_participants: 16,
    current_participants: 12,
    start_date: '2024-11-18',
    status: 'ثبت‌نام'
  }
])
</script>