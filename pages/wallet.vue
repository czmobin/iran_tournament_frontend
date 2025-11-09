<template>
  <div class="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-purple-50">
    <!-- Hero Section -->
    <div class="bg-gradient-to-r from-green-600 via-emerald-600 to-teal-600 text-white py-6 md:py-10 px-4 mb-6 md:mb-8 relative overflow-hidden">
      <!-- Background Pattern -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 right-0 w-48 h-48 bg-white rounded-full translate-x-1/4 -translate-y-1/4"></div>
        <div class="absolute bottom-0 left-0 w-64 h-64 bg-white rounded-full -translate-x-1/4 translate-y-1/4"></div>
      </div>

      <div class="container mx-auto relative z-10 text-center">
        <div class="text-5xl md:text-6xl mb-3 md:mb-4 animate-bounce">💰</div>
        <h1 class="text-2xl md:text-4xl font-black mb-2">
          کیف پول شما
        </h1>
        <p class="text-sm md:text-base text-white/90">مدیریت موجودی و تراکنش‌های مالی</p>
      </div>
    </div>

    <div class="container mx-auto px-4 pb-12">
      <!-- Balance Card -->
      <div class="bg-gradient-to-r from-purple-600 via-pink-600 to-rose-600 rounded-2xl md:rounded-3xl shadow-2xl p-6 md:p-8 mb-6 md:mb-8 text-white relative overflow-hidden">
        <!-- Decorative Elements -->
        <div class="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -translate-y-1/2 translate-x-1/2"></div>
        <div class="absolute bottom-0 left-0 w-24 h-24 bg-white/10 rounded-full translate-y-1/2 -translate-x-1/2"></div>

        <div class="relative z-10">
          <div class="flex items-center gap-2 mb-2">
            <div class="text-xl md:text-2xl">💵</div>
            <div class="text-base md:text-lg opacity-90">موجودی حساب</div>
          </div>

          <div class="text-4xl md:text-6xl font-black mb-6 md:mb-8">
            {{ walletStore.formattedBalance }}
          </div>

          <div class="grid grid-cols-2 gap-3 md:gap-4">
            <button
              @click="showTopUpModal = true"
              class="bg-white text-purple-600 font-bold py-3 md:py-4 px-4 md:px-6 rounded-xl md:rounded-2xl hover:bg-gray-100 transition-all shadow-lg active:scale-95 text-sm md:text-base"
            >
              <span class="text-lg md:text-xl mr-1">➕</span>
              شارژ کیف پول
            </button>

            <button
              @click="showWithdrawModal = true"
              :disabled="walletStore.balance === 0"
              class="bg-white/20 backdrop-blur text-white font-bold py-3 md:py-4 px-4 md:px-6 rounded-xl md:rounded-2xl hover:bg-white/30 transition-all border-2 border-white/50 disabled:opacity-50 disabled:cursor-not-allowed active:scale-95 text-sm md:text-base"
            >
              <span class="text-lg md:text-xl mr-1">💸</span>
              برداشت
            </button>
          </div>
        </div>
      </div>

      <!-- Transactions -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-xl overflow-hidden">
        <div class="p-4 md:p-6 border-b">
          <div class="flex items-center justify-between mb-4">
            <div class="flex items-center gap-2">
              <div class="text-xl md:text-2xl">📊</div>
              <h2 class="text-lg md:text-2xl font-bold text-gray-800">تاریخچه تراکنش‌ها</h2>
            </div>

            <button
              @click="loadTransactions"
              class="px-3 md:px-4 py-2 bg-gradient-to-r from-purple-600 to-pink-600 text-white rounded-lg md:rounded-xl hover:from-purple-700 hover:to-pink-700 transition-all text-xs md:text-sm font-bold shadow-lg active:scale-95"
            >
              🔄 <span class="hidden sm:inline">بروزرسانی</span>
            </button>
          </div>

          <!-- Filter Tabs - Mobile Optimized -->
          <div class="grid grid-cols-2 md:flex md:flex-wrap gap-2">
            <button
              v-for="filter in transactionFilters"
              :key="filter.value"
              @click="selectedFilter = filter.value"
              :class="[
                'px-3 md:px-4 py-2 md:py-2.5 rounded-lg md:rounded-xl font-bold transition-all text-xs md:text-sm shadow-sm',
                selectedFilter === filter.value
                  ? 'bg-gradient-to-r from-purple-600 to-pink-600 text-white shadow-md scale-105'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200 active:scale-95'
              ]"
            >
              {{ filter.label }}
            </button>
          </div>
        </div>

        <!-- Loading State -->
        <div v-if="walletStore.isLoading" class="flex justify-center items-center py-12">
          <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600"></div>
        </div>

        <!-- Empty State -->
        <div v-else-if="filteredTransactions.length === 0" class="text-center py-12 text-gray-500">
          <div class="text-6xl mb-4">📝</div>
          <p>هنوز تراکنشی ثبت نشده است</p>
        </div>

        <!-- Transactions List -->
        <div v-else class="divide-y">
          <div
            v-for="transaction in filteredTransactions"
            :key="transaction.id"
            class="p-6 hover:bg-gray-50 transition"
          >
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-4">
                <!-- Icon -->
                <div
                  :class="[
                    'w-12 h-12 rounded-full flex items-center justify-center text-2xl',
                    getTransactionColor(transaction.transaction_type).bg
                  ]"
                >
                  {{ getTransactionIcon(transaction.transaction_type) }}
                </div>

                <!-- Info -->
                <div>
                  <div class="font-bold text-gray-800">
                    {{ getTransactionTypeLabel(transaction.transaction_type) }}
                  </div>
                  <div class="text-sm text-gray-500">{{ transaction.description }}</div>
                  <div class="text-xs text-gray-400 mt-1">
                    {{ formatDate(transaction.created_at) }}
                  </div>
                </div>
              </div>

              <!-- Amount & Status -->
              <div class="text-left">
                <div
                  :class="[
                    'text-2xl font-black',
                    getTransactionColor(transaction.transaction_type).text
                  ]"
                >
                  {{ transaction.transaction_type === 'withdrawal' || transaction.transaction_type === 'tournament_fee' ? '-' : '+' }}
                  {{ formatPrice(transaction.amount) }}
                </div>

                <div
                  :class="[
                    'text-xs font-bold mt-1',
                    getStatusColor(transaction.status)
                  ]"
                >
                  {{ getStatusLabel(transaction.status) }}
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Top Up Modal -->
    <div
      v-if="showTopUpModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-end md:items-center justify-center z-50 p-0 md:p-4"
      @click.self="showTopUpModal = false"
    >
      <div class="bg-white rounded-t-3xl md:rounded-3xl p-6 md:p-8 max-w-md w-full shadow-2xl animate-slide-up md:animate-none">
        <!-- Handle (Mobile) -->
        <div class="flex justify-center mb-4 md:hidden">
          <div class="w-12 h-1.5 bg-gray-300 rounded-full"></div>
        </div>

        <div class="flex items-center gap-3 mb-6">
          <div class="text-3xl md:text-4xl">💳</div>
          <h3 class="text-xl md:text-2xl font-bold text-gray-800">شارژ کیف پول</h3>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2 text-sm md:text-base">مبلغ (تومان)</label>
          <input
            v-model.number="topUpAmount"
            type="number"
            step="10000"
            min="10000"
            class="w-full px-4 py-3 md:py-4 border-2 border-gray-300 rounded-xl md:rounded-2xl focus:border-purple-600 focus:outline-none text-base md:text-lg"
            placeholder="مثال: 100000"
          />

          <!-- Quick Amount Buttons -->
          <div class="grid grid-cols-3 gap-2 mt-4">
            <button
              v-for="amount in [50000, 100000, 200000, 500000, 1000000, 2000000]"
              :key="amount"
              @click="topUpAmount = amount"
              class="px-2 md:px-4 py-2 md:py-2.5 bg-gradient-to-r from-purple-50 to-pink-50 hover:from-purple-100 hover:to-pink-100 text-purple-700 rounded-lg md:rounded-xl font-bold transition-all text-xs md:text-sm shadow-sm active:scale-95"
            >
              {{ formatPrice(amount) }}
            </button>
          </div>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2 text-sm md:text-base">درگاه پرداخت</label>
          <select
            v-model="selectedGateway"
            class="w-full px-4 py-3 md:py-4 border-2 border-gray-300 rounded-xl md:rounded-2xl focus:border-purple-600 focus:outline-none text-sm md:text-base"
          >
            <option value="zarinpal">💳 زرین‌پال</option>
            <option value="idpay">💰 آیدی‌پی</option>
            <option value="nextpay">🔷 نکست‌پی</option>
            <option value="zibal">⚡ زیبال</option>
          </select>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <button
            @click="showTopUpModal = false"
            class="bg-gray-100 text-gray-700 font-bold py-3 md:py-4 rounded-xl md:rounded-2xl hover:bg-gray-200 transition-all active:scale-95 text-sm md:text-base"
          >
            انصراف
          </button>

          <button
            @click="handleTopUp"
            :disabled="topUpAmount < 10000 || walletStore.isLoading"
            class="bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-3 md:py-4 rounded-xl md:rounded-2xl hover:from-purple-700 hover:to-pink-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg active:scale-95 text-sm md:text-base"
          >
            {{ walletStore.isLoading ? '⏳ در حال پردازش...' : '✅ پرداخت' }}
          </button>
        </div>
      </div>
    </div>

    <!-- Withdraw Modal -->
    <div
      v-if="showWithdrawModal"
      class="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-end md:items-center justify-center z-50 p-0 md:p-4"
      @click.self="showWithdrawModal = false"
    >
      <div class="bg-white rounded-t-3xl md:rounded-3xl p-6 md:p-8 max-w-md w-full shadow-2xl animate-slide-up md:animate-none">
        <!-- Handle (Mobile) -->
        <div class="flex justify-center mb-4 md:hidden">
          <div class="w-12 h-1.5 bg-gray-300 rounded-full"></div>
        </div>

        <div class="flex items-center gap-3 mb-6">
          <div class="text-3xl md:text-4xl">💸</div>
          <h3 class="text-xl md:text-2xl font-bold text-gray-800">درخواست برداشت</h3>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2 text-sm md:text-base">مبلغ (تومان)</label>
          <input
            v-model.number="withdrawAmount"
            type="number"
            step="10000"
            min="10000"
            :max="walletStore.balance"
            class="w-full px-4 py-3 md:py-4 border-2 border-gray-300 rounded-xl md:rounded-2xl focus:border-purple-600 focus:outline-none text-base md:text-lg"
            placeholder="مثال: 100000"
          />
          <div class="text-xs md:text-sm text-gray-500 mt-2 flex items-center gap-1">
            <span>💰</span>
            <span>حداکثر: {{ walletStore.formattedBalance }}</span>
          </div>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2 text-sm md:text-base">شماره کارت یا شبا</label>
          <input
            v-model="bankAccount"
            type="text"
            class="w-full px-4 py-3 md:py-4 border-2 border-gray-300 rounded-xl md:rounded-2xl focus:border-purple-600 focus:outline-none text-sm md:text-base"
            placeholder="مثال: 6037-9971-XXXX-XXXX"
          />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <button
            @click="showWithdrawModal = false"
            class="bg-gray-100 text-gray-700 font-bold py-3 md:py-4 rounded-xl md:rounded-2xl hover:bg-gray-200 transition-all active:scale-95 text-sm md:text-base"
          >
            انصراف
          </button>

          <button
            @click="handleWithdraw"
            :disabled="withdrawAmount < 10000 || withdrawAmount > walletStore.balance || walletStore.isLoading"
            class="bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-3 md:py-4 rounded-xl md:rounded-2xl hover:from-purple-700 hover:to-pink-700 transition-all disabled:opacity-50 disabled:cursor-not-allowed shadow-lg active:scale-95 text-sm md:text-base"
          >
            {{ walletStore.isLoading ? '⏳ در حال ثبت...' : '✅ ثبت درخواست' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useWalletStore } from '~/stores/wallet'

definePageMeta({
  layout: 'default',
  middleware: 'auth'
})

const walletStore = useWalletStore()

const showTopUpModal = ref(false)
const showWithdrawModal = ref(false)
const topUpAmount = ref(100000)
const withdrawAmount = ref(0)
const bankAccount = ref('')
const selectedGateway = ref('zarinpal')
const selectedFilter = ref('all')

const transactionFilters = [
  { label: 'همه', value: 'all' },
  { label: 'واریز', value: 'deposit' },
  { label: 'برداشت', value: 'withdrawal' },
  { label: 'تورنومنت', value: 'tournament' }
]

const filteredTransactions = computed(() => {
  switch (selectedFilter.value) {
    case 'deposit':
      return walletStore.depositTransactions
    case 'withdrawal':
      return walletStore.withdrawalTransactions
    case 'tournament':
      return walletStore.tournamentTransactions
    default:
      return walletStore.transactions
  }
})

const getTransactionTypeLabel = (type: string) => {
  const labels: Record<string, string> = {
    deposit: 'واریز به حساب',
    withdrawal: 'برداشت از حساب',
    tournament_fee: 'شرکت در تورنومنت',
    prize: 'دریافت جایزه',
    refund: 'بازگشت وجه'
  }
  return labels[type] || type
}

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

const getTransactionColor = (type: string) => {
  const colors: Record<string, { bg: string; text: string }> = {
    deposit: { bg: 'bg-green-100', text: 'text-green-600' },
    withdrawal: { bg: 'bg-red-100', text: 'text-red-600' },
    tournament_fee: { bg: 'bg-purple-100', text: 'text-purple-600' },
    prize: { bg: 'bg-yellow-100', text: 'text-yellow-600' },
    refund: { bg: 'bg-blue-100', text: 'text-blue-600' }
  }
  return colors[type] || { bg: 'bg-gray-100', text: 'text-gray-600' }
}

const getStatusLabel = (status: string) => {
  const labels: Record<string, string> = {
    pending: 'در انتظار',
    completed: 'تکمیل شده',
    failed: 'ناموفق',
    cancelled: 'لغو شده'
  }
  return labels[status] || status
}

const getStatusColor = (status: string) => {
  const colors: Record<string, string> = {
    pending: 'text-yellow-600',
    completed: 'text-green-600',
    failed: 'text-red-600',
    cancelled: 'text-gray-600'
  }
  return colors[status] || 'text-gray-600'
}

const formatPrice = (price: number) => {
  return new Intl.NumberFormat('fa-IR').format(price)
}

const formatDate = (date: string) => {
  return new Date(date).toLocaleDateString('fa-IR', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

const loadTransactions = async () => {
  await walletStore.fetchBalance()
  await walletStore.fetchTransactions()
}

const handleTopUp = async () => {
  const result = await walletStore.topUp(topUpAmount.value, selectedGateway.value)

  if (result.success && !result.redirecting) {
    alert('✅ ' + result.message)
    showTopUpModal.value = false
    await loadTransactions()
  } else if (!result.success) {
    alert('❌ ' + result.message)
  }
  // اگر redirecting باشه، کاربر به درگاه پرداخت منتقل میشه
}

const handleWithdraw = async () => {
  const result = await walletStore.requestWithdrawal(withdrawAmount.value, bankAccount.value)

  if (result.success) {
    alert('✅ ' + result.message)
    showWithdrawModal.value = false
    withdrawAmount.value = 0
    bankAccount.value = ''
    await loadTransactions()
  } else {
    alert('❌ ' + result.message)
  }
}

// بارگذاری اولیه
onMounted(() => {
  loadTransactions()
})
</script>
