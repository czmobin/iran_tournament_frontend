<template>
  <div class="min-h-screen bg-gray-50">
    <!-- Loading State -->
    <div v-if="isLoading" class="min-h-screen flex items-center justify-center">
      <div class="text-center">
        <div class="animate-spin rounded-full h-16 w-16 border-b-4 border-purple-600 mx-auto mb-4"></div>
        <p class="text-gray-600">در حال بارگذاری...</p>
      </div>
    </div>

    <!-- Content -->
    <div v-else>
      <!-- Header -->
      <header class="bg-white shadow-sm">
        <div class="container mx-auto px-4 py-4">
          <div class="flex justify-between items-center">
            <h1 class="text-2xl font-bold text-gray-800">
              🏆 داشبورد
            </h1>
            
            <div class="flex items-center gap-4">
              <div class="text-left">
                <p class="text-sm text-gray-500">خوش آمدید</p>
                <p class="font-bold text-gray-800">{{ authStore.userFullName }}</p>
              </div>
              
              <button
                @click="handleLogout"
                class="bg-red-500 text-white px-4 py-2 rounded-lg hover:bg-red-600 transition"
              >
                خروج
              </button>
            </div>
          </div>
        </div>
      </header>

      <!-- Content -->
      <main class="container mx-auto px-4 py-8">
        <!-- User Info Card -->
        <div class="bg-white rounded-2xl shadow-lg p-6 mb-8">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold text-gray-800">
              اطلاعات کاربری
            </h2>
            
            <!-- Refresh Button -->
            <button
              @click="refreshProfile"
              :disabled="refreshing"
              class="text-purple-600 hover:text-purple-700 text-sm flex items-center gap-2 disabled:opacity-50"
            >
              <svg 
                class="w-4 h-4" 
                :class="{ 'animate-spin': refreshing }"
                fill="none" 
                stroke="currentColor" 
                viewBox="0 0 24 24"
              >
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
              </svg>
              به‌روزرسانی
            </button>
          </div>
          
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <p class="text-sm text-gray-500">نام کاربری</p>
              <p class="font-bold">{{ user?.username }}</p>
            </div>
            
            <div>
              <p class="text-sm text-gray-500">ایمیل</p>
              <p class="font-bold">{{ user?.email }}</p>
            </div>
            
            <div>
              <p class="text-sm text-gray-500">موجودی کیف پول</p>
              <p class="font-bold text-green-600">
                {{ formatPrice(user?.wallet_balance || 0) }}
              </p>
            </div>
            
            <div>
              <p class="text-sm text-gray-500">وضعیت حساب</p>
              <p class="font-bold flex items-center gap-2" :class="user?.is_verified ? 'text-green-600' : 'text-orange-600'">
                <span v-if="user?.is_verified">✓ تایید شده</span>
                <span v-else>⏳ در انتظار تایید</span>
              </p>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
          <NuxtLink
            to="/tournaments"
            class="bg-purple-500 hover:bg-purple-600 text-white p-6 rounded-2xl shadow-lg transition transform hover:scale-105"
          >
            <div class="text-4xl mb-2">🏆</div>
            <h3 class="text-xl font-bold mb-2">تورنومنت‌ها</h3>
            <p class="text-white/80">مشاهده و شرکت در تورنومنت‌ها</p>
          </NuxtLink>

          <NuxtLink
            to="/wallet"
            class="bg-green-500 hover:bg-green-600 text-white p-6 rounded-2xl shadow-lg transition transform hover:scale-105"
          >
            <div class="text-4xl mb-2">💰</div>
            <h3 class="text-xl font-bold mb-2">کیف پول</h3>
            <p class="text-white/80">مدیریت موجودی و تراکنش‌ها</p>
          </NuxtLink>

          <NuxtLink
            to="/profile"
            class="bg-blue-500 hover:bg-blue-600 text-white p-6 rounded-2xl shadow-lg transition transform hover:scale-105"
          >
            <div class="text-4xl mb-2">👤</div>
            <h3 class="text-xl font-bold mb-2">پروفایل</h3>
            <p class="text-white/80">ویرایش اطلاعات کاربری</p>
          </NuxtLink>
        </div>

        <!-- Recent Tournaments -->
        <div class="bg-white rounded-2xl shadow-lg p-6 mb-8">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold text-gray-800">تورنومنت‌های من</h2>
            <NuxtLink to="/tournaments" class="text-purple-600 hover:text-purple-700 text-sm font-bold">
              مشاهده همه →
            </NuxtLink>
          </div>

          <div v-if="loadingTournaments" class="flex justify-center py-8">
            <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
          </div>

          <div v-else-if="myTournaments.length === 0" class="text-center py-8 text-gray-500">
            <div class="text-6xl mb-4">🏆</div>
            <p>شما هنوز در هیچ تورنومنتی شرکت نکرده‌اید</p>
            <NuxtLink
              to="/tournaments"
              class="inline-block mt-4 px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition"
            >
              مشاهده تورنومنت‌ها
            </NuxtLink>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="tournament in myTournaments.slice(0, 3)"
              :key="tournament.id"
              class="bg-gray-50 rounded-xl p-4 hover:bg-gray-100 transition"
            >
              <NuxtLink :to="`/tournaments/${tournament.slug || tournament.id}`" class="block">
                <div class="flex items-center justify-between">
                  <div class="flex-1">
                    <h3 class="font-bold text-gray-800">{{ tournament.title }}</h3>
                    <div
                      v-html="tournament.description"
                      class="text-sm text-gray-500 line-clamp-2 prose prose-sm max-w-none"
                    ></div>
                  </div>
                  <div
                    :class="[
                      'px-3 py-1 rounded-full text-xs font-bold',
                      tournament.status === 'registration' ? 'bg-green-100 text-green-600' :
                      tournament.status === 'ongoing' ? 'bg-yellow-100 text-yellow-600' :
                      'bg-red-100 text-red-600'
                    ]"
                  >
                    {{ getStatusLabel(tournament.status) }}
                  </div>
                </div>
              </NuxtLink>
            </div>
          </div>
        </div>

        <!-- Recent Transactions -->
        <div class="bg-white rounded-2xl shadow-lg p-6">
          <div class="flex justify-between items-center mb-4">
            <h2 class="text-xl font-bold text-gray-800">آخرین تراکنش‌ها</h2>
            <NuxtLink to="/wallet" class="text-purple-600 hover:text-purple-700 text-sm font-bold">
              مشاهده همه →
            </NuxtLink>
          </div>

          <div v-if="loadingTransactions" class="flex justify-center py-8">
            <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
          </div>

          <div v-else-if="recentTransactions.length === 0" class="text-center py-8 text-gray-500">
            <div class="text-6xl mb-4">💰</div>
            <p>هنوز تراکنشی ثبت نشده است</p>
          </div>

          <div v-else class="space-y-3">
            <div
              v-for="transaction in recentTransactions"
              :key="transaction.id"
              class="bg-gray-50 rounded-xl p-4 flex items-center justify-between"
            >
              <div class="flex items-center gap-3">
                <div
                  :class="[
                    'w-10 h-10 rounded-full flex items-center justify-center',
                    getTransactionColor(transaction.transaction_type)
                  ]"
                >
                  {{ getTransactionIcon(transaction.transaction_type) }}
                </div>
                <div>
                  <div class="font-bold text-gray-800">
                    {{ getTransactionLabel(transaction.transaction_type) }}
                  </div>
                  <div class="text-xs text-gray-500">
                    {{ formatDate(transaction.created_at) }}
                  </div>
                </div>
              </div>
              <div
                :class="[
                  'text-lg font-bold',
                  transaction.transaction_type === 'deposit' || transaction.transaction_type === 'prize' || transaction.transaction_type === 'refund'
                    ? 'text-green-600'
                    : 'text-red-600'
                ]"
              >
                {{ transaction.transaction_type === 'withdrawal' || transaction.transaction_type === 'tournament_fee' ? '-' : '+' }}
                {{ formatPrice(transaction.amount) }}
              </div>
            </div>
          </div>
        </div>
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useTournamentStore } from '~/stores/tournament'
import { useWalletStore } from '~/stores/wallet'

definePageMeta({
  middleware: 'auth'
})

const authStore = useAuthStore()
const tournamentStore = useTournamentStore()
const walletStore = useWalletStore()
const router = useRouter()

// State
const isLoading = ref(true)
const refreshing = ref(false)
const loadingTournaments = ref(false)
const loadingTransactions = ref(false)
const myTournaments = ref<any[]>([])
const recentTransactions = ref<any[]>([])

// Get user data
const user = computed(() => authStore.user)

// Fetch profile on mount
onMounted(async () => {
  try {
    isLoading.value = true

    console.log('[Dashboard] Starting mount, has user:', !!authStore.user)

    // فقط اگه user نداریم، fetch کن
    // چون بعد از login موفق، user قبلاً توی store هست
    if (!authStore.user) {
      console.log('[Dashboard] No user found, fetching profile...')
      await authStore.fetchProfile()
    } else {
      console.log('[Dashboard] User already loaded:', authStore.user.username)
      // داده‌های user رو داریم، فقط wallet balance رو update کن
      if (authStore.user.wallet_balance === undefined || authStore.user.wallet_balance === null) {
        console.log('[Dashboard] Refreshing user data for wallet balance...')
        await authStore.fetchProfile().catch(err => {
          console.warn('[Dashboard] Failed to refresh profile, using cached data:', err)
        })
      }
    }
  } catch (error) {
    console.error('[Dashboard] Error loading profile:', error)
    // اگه خطا گرفتیم ولی user داریم، ادامه بده
    // اگه user نداریم، middleware به login redirect میکنه
  } finally {
    isLoading.value = false
    console.log('[Dashboard] Loading complete')

    // بارگذاری تورنومنت‌ها و تراکنش‌ها
    loadDashboardData()
  }
})

// بارگذاری داده‌های داشبورد
const loadDashboardData = async () => {
  // بارگذاری تورنومنت‌ها
  try {
    loadingTournaments.value = true
    await tournamentStore.fetchTournaments()
    // فیلتر تورنومنت‌هایی که کاربر در اونها شرکت کرده
    // (این باید از API جداگانه‌ای بیاد، ولی فعلاً همه رو نشون میدیم)
    myTournaments.value = tournamentStore.tournaments
  } catch (error) {
    console.error('[Dashboard] Error loading tournaments:', error)
    myTournaments.value = []
  } finally {
    loadingTournaments.value = false
  }

  // بارگذاری تراکنش‌ها
  try {
    loadingTransactions.value = true
    await walletStore.fetchTransactions({ limit: 5 })
    recentTransactions.value = walletStore.transactions
  } catch (error) {
    console.error('[Dashboard] Error loading transactions:', error)
    recentTransactions.value = []
  } finally {
    loadingTransactions.value = false
  }

  // بارگذاری موجودی wallet
  try {
    await walletStore.fetchBalance()
  } catch (error) {
    console.error('[Dashboard] Error loading wallet balance:', error)
  }
}

// Check if should refresh data (هر 5 دقیقه)
const shouldRefreshData = () => {
  if (process.client) {
    const lastFetch = localStorage.getItem('lastProfileFetch')
    if (!lastFetch) return true

    const fiveMinutes = 5 * 60 * 1000
    return Date.now() - parseInt(lastFetch) > fiveMinutes
  }
  return true
}

// Manual refresh
const refreshProfile = async () => {
  refreshing.value = true
  await authStore.fetchProfile()
  await loadDashboardData()

  if (process.client) {
    localStorage.setItem('lastProfileFetch', Date.now().toString())
  }

  refreshing.value = false
}

// Logout
const handleLogout = async () => {
  if (confirm('آیا مطمئن هستید که میخواهید خارج شوید؟')) {
    await authStore.logout()
  }
}

// Format price
const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fa-IR').format(price) + ' تومان'
}

// Format date
const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fa-IR', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  })
}

// Get status label
const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    draft: 'پیش‌نویس',
    registration: 'ثبت‌نام',
    ongoing: 'در حال برگزاری',
    finished: 'پایان یافته'
  }
  return labels[status] || status
}

// Get transaction label
const getTransactionLabel = (type: string) => {
  const labels: Record<string, string> = {
    deposit: 'واریز',
    withdrawal: 'برداشت',
    tournament_fee: 'شرکت در تورنومنت',
    prize: 'جایزه',
    refund: 'بازگشت وجه'
  }
  return labels[type] || type
}

// Get transaction icon
const getTransactionIcon = (type: string) => {
  const icons: Record<string, string> = {
    deposit: '💰',
    withdrawal: '💸',
    tournament_fee: '🎮',
    prize: '🏆',
    refund: '↩️'
  }
  return icons[type] || '📝'
}

// Get transaction color
const getTransactionColor = (type: string) => {
  const colors: Record<string, string> = {
    deposit: 'bg-green-100 text-green-600',
    withdrawal: 'bg-red-100 text-red-600',
    tournament_fee: 'bg-purple-100 text-purple-600',
    prize: 'bg-yellow-100 text-yellow-600',
    refund: 'bg-blue-100 text-blue-600'
  }
  return colors[type] || 'bg-gray-100 text-gray-600'
}

// SEO
useHead({
  title: 'داشبورد - ایران تورنومنت'
})
</script>