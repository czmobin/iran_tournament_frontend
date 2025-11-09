import { defineStore } from 'pinia'

export interface Transaction {
  id: number
  user: number
  transaction_type: 'deposit' | 'withdrawal' | 'tournament_fee' | 'prize' | 'refund'
  amount: number
  balance_after: number
  description: string
  status: 'pending' | 'completed' | 'failed' | 'cancelled'
  created_at: string
  updated_at: string
}

export interface WalletBalance {
  balance: number
  total_deposits: number
  total_withdrawals: number
  total_tournament_fees: number
  total_prizes: number
}

export const useWalletStore = defineStore('wallet', {
  state: () => ({
    balance: 0,
    transactions: [] as Transaction[],
    isLoading: false,
    error: null as string | null,
  }),

  getters: {
    // فیلتر تراکنش‌ها بر اساس نوع
    depositTransactions: (state) =>
      state.transactions.filter(t => t.transaction_type === 'deposit'),

    withdrawalTransactions: (state) =>
      state.transactions.filter(t => t.transaction_type === 'withdrawal'),

    tournamentTransactions: (state) =>
      state.transactions.filter(t => t.transaction_type === 'tournament_fee' || t.transaction_type === 'prize'),

    // فرمت موجودی
    formattedBalance: (state) =>
      new Intl.NumberFormat('fa-IR').format(state.balance) + ' تومان',
  },

  actions: {
    // دریافت موجودی کیف پول
    async fetchBalance() {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const response = await apiFetch('/wallet/balance/')
        this.balance = response.balance

        // به‌روزرسانی موجودی در auth store
        const authStore = useAuthStore()
        if (authStore.user) {
          authStore.user.wallet_balance = response.balance
          authStore.saveToStorage()
        }

        return { success: true, balance: response.balance }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت موجودی'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // دریافت تاریخچه تراکنش‌ها
    async fetchTransactions(filters?: { type?: string; limit?: number }) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        let url = '/wallet/transactions/'
        const params = new URLSearchParams()

        if (filters?.type) params.append('type', filters.type)
        if (filters?.limit) params.append('limit', filters.limit.toString())

        if (params.toString()) {
          url += `?${params.toString()}`
        }

        const response = await apiFetch(url)
        this.transactions = response.results || response

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت تراکنش‌ها'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // شارژ کیف پول
    async topUp(amount: number, gateway: string = 'zarinpal') {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const response = await apiFetch('/wallet/topup/', {
          method: 'POST',
          body: { amount, gateway }
        })

        // اگر لینک پرداخت داریم، کاربر رو redirect کن
        if (response.payment_url) {
          window.location.href = response.payment_url
          return { success: true, redirecting: true }
        }

        return { success: true, message: response.message || 'درخواست شارژ با موفقیت ثبت شد' }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در شارژ کیف پول'
        return {
          success: false,
          message: this.error,
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },

    // درخواست برداشت
    async requestWithdrawal(amount: number, bank_account?: string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const response = await apiFetch('/wallet/withdraw/', {
          method: 'POST',
          body: { amount, bank_account }
        })

        // به‌روزرسانی موجودی
        await this.fetchBalance()

        return { success: true, message: response.message || 'درخواست برداشت با موفقیت ثبت شد' }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در درخواست برداشت'
        return {
          success: false,
          message: this.error,
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },

    // بررسی وضعیت پرداخت (برای callback پرداخت)
    async verifyPayment(authority: string, status: string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const response = await apiFetch('/wallet/verify-payment/', {
          method: 'POST',
          body: { authority, status }
        })

        // به‌روزرسانی موجودی
        await this.fetchBalance()
        await this.fetchTransactions({ limit: 10 })

        return {
          success: true,
          verified: response.verified,
          message: response.message
        }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در تایید پرداخت'
        return {
          success: false,
          message: this.error
        }
      } finally {
        this.isLoading = false
      }
    },

    // پاک کردن خطا
    clearError() {
      this.error = null
    }
  }
})
