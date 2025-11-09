<template>
  <div class="min-h-screen bg-gray-50">
    <div class="container mx-auto px-4 py-12">
      <h1 class="text-4xl font-black text-gray-800 mb-8">
        کیف پول 💰
      </h1>

      <!-- Balance Card -->
      <div class="bg-gradient-to-r from-purple-600 to-pink-600 rounded-2xl shadow-xl p-8 mb-6 text-white">
        <div class="text-lg mb-2 opacity-90">موجودی حساب</div>
        <div class="text-5xl font-black mb-6">
          {{ walletStore.formattedBalance }}
        </div>

        <div class="flex flex-wrap gap-4">
          <button
            @click="showTopUpModal = true"
            class="flex-1 min-w-[150px] bg-white text-purple-600 font-bold py-3 px-6 rounded-xl hover:bg-gray-100 transition"
          >
            ➕ شارژ کیف پول
          </button>

          <button
            @click="showWithdrawModal = true"
            :disabled="walletStore.balance === 0"
            class="flex-1 min-w-[150px] bg-purple-700 text-white font-bold py-3 px-6 rounded-xl hover:bg-purple-800 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            💸 برداشت
          </button>
        </div>
      </div>

      <!-- Transactions -->
      <div class="bg-white rounded-2xl shadow-xl overflow-hidden">
        <div class="p-6 border-b">
          <div class="flex items-center justify-between mb-4">
            <h2 class="text-2xl font-bold text-gray-800">تاریخچه تراکنش‌ها</h2>

            <button
              @click="loadTransactions"
              class="px-4 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition text-sm font-bold"
            >
              🔄 بروزرسانی
            </button>
          </div>

          <!-- Filter Tabs -->
          <div class="flex gap-2 flex-wrap">
            <button
              v-for="filter in transactionFilters"
              :key="filter.value"
              @click="selectedFilter = filter.value"
              :class="[
                'px-4 py-2 rounded-lg font-bold transition-all text-sm',
                selectedFilter === filter.value
                  ? 'bg-purple-600 text-white'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
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
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="showTopUpModal = false"
    >
      <div class="bg-white rounded-2xl p-8 max-w-md w-full">
        <h3 class="text-2xl font-bold text-gray-800 mb-6">شارژ کیف پول</h3>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">مبلغ (تومان)</label>
          <input
            v-model.number="topUpAmount"
            type="number"
            step="10000"
            min="10000"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-purple-600 focus:outline-none text-lg"
            placeholder="مثال: 100000"
          />

          <!-- Quick Amount Buttons -->
          <div class="grid grid-cols-3 gap-2 mt-4">
            <button
              v-for="amount in [50000, 100000, 200000, 500000, 1000000, 2000000]"
              :key="amount"
              @click="topUpAmount = amount"
              class="px-4 py-2 bg-gray-100 hover:bg-purple-100 hover:text-purple-600 rounded-lg font-bold transition text-sm"
            >
              {{ formatPrice(amount) }}
            </button>
          </div>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">درگاه پرداخت</label>
          <select
            v-model="selectedGateway"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-purple-600 focus:outline-none"
          >
            <option value="zarinpal">زرین‌پال</option>
            <option value="idpay">آیدی‌پی</option>
            <option value="nextpay">نکست‌پی</option>
            <option value="zibal">زیبال</option>
          </select>
        </div>

        <div class="flex gap-4">
          <button
            @click="handleTopUp"
            :disabled="topUpAmount < 10000 || walletStore.isLoading"
            class="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-3 rounded-xl hover:from-purple-700 hover:to-pink-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ walletStore.isLoading ? 'در حال پردازش...' : 'پرداخت' }}
          </button>

          <button
            @click="showTopUpModal = false"
            class="flex-1 bg-gray-200 text-gray-700 font-bold py-3 rounded-xl hover:bg-gray-300 transition"
          >
            انصراف
          </button>
        </div>
      </div>
    </div>

    <!-- Withdraw Modal -->
    <div
      v-if="showWithdrawModal"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click.self="showWithdrawModal = false"
    >
      <div class="bg-white rounded-2xl p-8 max-w-md w-full">
        <h3 class="text-2xl font-bold text-gray-800 mb-6">درخواست برداشت</h3>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">مبلغ (تومان)</label>
          <input
            v-model.number="withdrawAmount"
            type="number"
            step="10000"
            min="10000"
            :max="walletStore.balance"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-purple-600 focus:outline-none text-lg"
            placeholder="مثال: 100000"
          />
          <div class="text-sm text-gray-500 mt-2">
            حداکثر: {{ walletStore.formattedBalance }}
          </div>
        </div>

        <div class="mb-6">
          <label class="block text-gray-700 font-bold mb-2">شماره کارت یا شبا</label>
          <input
            v-model="bankAccount"
            type="text"
            class="w-full px-4 py-3 border-2 border-gray-300 rounded-xl focus:border-purple-600 focus:outline-none"
            placeholder="مثال: 6037-9971-XXXX-XXXX"
          />
        </div>

        <div class="flex gap-4">
          <button
            @click="handleWithdraw"
            :disabled="withdrawAmount < 10000 || withdrawAmount > walletStore.balance || walletStore.isLoading"
            class="flex-1 bg-gradient-to-r from-purple-600 to-pink-600 text-white font-bold py-3 rounded-xl hover:from-purple-700 hover:to-pink-700 transition disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ walletStore.isLoading ? 'در حال ثبت...' : 'ثبت درخواست' }}
          </button>

          <button
            @click="showWithdrawModal = false"
            class="flex-1 bg-gray-200 text-gray-700 font-bold py-3 rounded-xl hover:bg-gray-300 transition"
          >
            انصراف
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
