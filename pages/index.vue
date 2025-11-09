<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-600 to-blue-600">

    <!-- Hero Section - Responsive -->
    <main class="container mx-auto px-4 py-12 md:py-16 lg:py-20 text-center">
      <h2 class="text-3xl md:text-4xl lg:text-5xl font-black text-white mb-4 md:mb-6 leading-tight">
        به دنیای تورنومنت کلش رویال خوش آمدید! ⚔️
      </h2>
      
      <p class="text-base md:text-lg lg:text-xl text-white/90 mb-6 md:mb-8 max-w-2xl mx-auto px-4">
        در تورنومنت‌های آنلاین شرکت کنید، رقابت کنید و جوایز نقدی ببرید!
      </p>

      <!-- Buttons - Responsive -->
      <div class="flex flex-col sm:flex-row gap-3 md:gap-4 justify-center px-4">
        <NuxtLink
          to="/tournaments"
          class="bg-yellow-400 text-purple-900 px-6 md:px-8 py-3 md:py-4 rounded-xl font-bold text-base md:text-lg hover:bg-yellow-300 transition transform hover:scale-105"
        >
          شروع کنید 🚀
        </NuxtLink>

        <button
          @click="showLearnMore = true"
          class="bg-white/20 backdrop-blur text-white px-6 md:px-8 py-3 md:py-4 rounded-xl font-bold text-base md:text-lg hover:bg-white/30 transition border-2 border-white/50"
        >
          بیشتر بدانید
        </button>
      </div>

      <!-- Stats - Responsive Grid -->
      <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-6 mt-12 md:mt-16 lg:mt-20 max-w-4xl mx-auto">
        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
          <div class="text-3xl md:text-4xl font-black text-yellow-400 mb-2">{{ stats.tournaments }}</div>
          <div class="text-white/80 text-sm md:text-base">تورنومنت برگزار شده</div>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
          <div class="text-3xl md:text-4xl font-black text-yellow-400 mb-2">{{ stats.players }}</div>
          <div class="text-white/80 text-sm md:text-base">بازیکن فعال</div>
        </div>

        <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6 border border-white/20">
          <div class="text-3xl md:text-4xl font-black text-yellow-400 mb-2">{{ stats.prizes }}</div>
          <div class="text-white/80 text-sm md:text-base">جوایز پرداخت شده</div>
        </div>
      </div>
    </main>

    <!-- Learn More Modal - Fixed Overlay -->
    <Transition name="modal">
      <div
        v-if="showLearnMore"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/70 backdrop-blur-sm"
        @click.self="showLearnMore = false"
      >
        <div class="bg-gradient-to-br from-purple-600 to-blue-600 rounded-3xl p-6 md:p-10 border border-white/20 max-w-5xl w-full max-h-[90vh] overflow-y-auto">
          <!-- Close Button -->
          <div class="flex justify-between items-center mb-6 sticky top-0 bg-gradient-to-br from-purple-600 to-blue-600 pb-4">
            <h3 class="text-2xl md:text-3xl font-black text-white">
              درباره ایران تورنومنت
            </h3>
            <button
              @click="showLearnMore = false"
              class="text-white/80 hover:text-white transition p-2 hover:bg-white/10 rounded-lg"
            >
              <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Content Grid -->
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-8">
            <!-- چگونه کار می‌کند -->
            <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6">
              <div class="text-4xl mb-4">🎮</div>
              <h4 class="text-xl font-bold text-white mb-3">چگونه کار می‌کند؟</h4>
              <ul class="text-white/80 space-y-2 text-sm md:text-base">
                <li>✓ ابتدا در سایت ثبت‌نام کنید</li>
                <li>✓ تگ کلش رویال خود را وصل کنید</li>
                <li>✓ در تورنومنت دلخواه ثبت‌نام کنید</li>
                <li>✓ در زمان مقرر در بازی شرکت کنید</li>
                <li>✓ جایزه خود را دریافت کنید!</li>
              </ul>
            </div>

            <!-- امنیت و اعتماد -->
            <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6">
              <div class="text-4xl mb-4">🔒</div>
              <h4 class="text-xl font-bold text-white mb-3">امنیت و اعتماد</h4>
              <ul class="text-white/80 space-y-2 text-sm md:text-base">
                <li>✓ اتصال مستقیم به API کلش رویال</li>
                <li>✓ پرداخت امن از طریق درگاه معتبر</li>
                <li>✓ شفافیت کامل در نتایج</li>
                <li>✓ پشتیبانی ۲۴ساعته</li>
                <li>✓ پرداخت سریع جوایز</li>
              </ul>
            </div>

            <!-- ویژگی‌های پلتفرم -->
            <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6">
              <div class="text-4xl mb-4">⚡</div>
              <h4 class="text-xl font-bold text-white mb-3">ویژگی‌ها</h4>
              <ul class="text-white/80 space-y-2 text-sm md:text-base">
                <li>✓ لیدربورد زنده و لحظه‌ای</li>
                <li>✓ چت اختصاصی هر تورنومنت</li>
                <li>✓ سیستم کیف پول داخلی</li>
                <li>✓ تاریخچه کامل بازی‌ها</li>
                <li>✓ اعلان‌های لحظه‌ای</li>
              </ul>
            </div>

            <!-- انواع تورنومنت -->
            <div class="bg-white/10 backdrop-blur-lg rounded-2xl p-6">
              <div class="text-4xl mb-4">🏆</div>
              <h4 class="text-xl font-bold text-white mb-3">انواع تورنومنت</h4>
              <ul class="text-white/80 space-y-2 text-sm md:text-base">
                <li>✓ تورنومنت‌های رایگان تمرینی</li>
                <li>✓ مسابقات با جایزه نقدی</li>
                <li>✓ لیگ‌های فصلی</li>
                <li>✓ رویدادهای ویژه</li>
                <li>✓ تورنومنت‌های اختصاصی کلن</li>
              </ul>
            </div>
          </div>

          <!-- Call to Action -->
          <div class="mt-8 text-center">
            <NuxtLink
              to="/tournaments"
              class="inline-block bg-yellow-400 text-purple-900 px-8 py-4 rounded-xl font-bold text-lg hover:bg-yellow-300 transition transform hover:scale-105"
              @click="showLearnMore = false"
            >
              همین حالا شروع کن! 🚀
            </NuxtLink>
          </div>
        </div>
      </div>
    </Transition>
  </div>
</template>

<script setup lang="ts">
import { useTournamentStore } from '~/stores/tournament'

const authStore = useAuthStore()
const tournamentStore = useTournamentStore()
const mobileMenuOpen = ref(false)
const showLearnMore = ref(false)

const stats = ref({
  tournaments: 0,
  players: 0,
  prizes: '0 تومان'
})

onMounted(async () => {
  if (process.client) {
    authStore.loadFromStorage()
  }

  // بارگذاری آمار
  try {
    await loadStats()
  } catch (error) {
    console.error('[Homepage] Error loading stats:', error)
  }
})

const loadStats = async () => {
  try {
    // بارگذاری تورنومنت‌ها برای محاسبه آمار
    await tournamentStore.fetchTournaments()

    // محاسبه آمار
    stats.value.tournaments = tournamentStore.tournaments.length

    // محاسبه تعداد بازیکنان (مجموع شرکت‌کنندگان در همه تورنومنت‌ها)
    const totalPlayers = tournamentStore.tournaments.reduce(
      (sum, t) => sum + t.current_participants,
      0
    )
    stats.value.players = totalPlayers

    // محاسبه جوایز پرداخت شده (مجموع prize pool تورنومنت‌های پایان یافته)
    const totalPrizes = tournamentStore.tournaments
      .filter(t => t.status === 'finished')
      .reduce((sum, t) => sum + t.prize_pool, 0)

    stats.value.prizes = new Intl.NumberFormat('fa-IR').format(totalPrizes) + ' تومان'
  } catch (error) {
    console.error('[Homepage] Error calculating stats:', error)
    // در صورت خطا، مقادیر پیش‌فرض رو نگه دار
  }
}

useHead({
  title: 'ایران تورنومنت - تورنومنت‌های آنلاین کلش رویال',
  meta: [
    { name: 'description', content: 'بهترین پلتفرم برگزاری تورنومنت‌های کلش رویال در ایران' },
    { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=5' }
  ]
})
</script>

<style scoped>
/* Modal Transition Animations */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-active > div,
.modal-leave-active > div {
  transition: transform 0.3s ease, opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-from > div,
.modal-leave-to > div {
  transform: scale(0.9);
  opacity: 0;
}
</style>