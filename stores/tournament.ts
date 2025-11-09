import { defineStore } from 'pinia'

export interface Tournament {
  id: number
  title: string
  slug: string
  description: string
  game_type: string
  status: 'draft' | 'registration' | 'ongoing' | 'finished'
  entry_fee: number
  prize_pool: number
  max_participants: number
  current_participants: number
  start_date: string
  registration_deadline: string
  rules: string
  cover_image: string | null
  created_at: string
  updated_at: string
}

export interface TournamentParticipant {
  id: number
  user: {
    id: number
    username: string
    first_name: string
    last_name: string
    clash_royale_tag: string | null
  }
  tournament: number
  joined_at: string
  status: 'pending' | 'confirmed' | 'cancelled'
  payment_status: 'pending' | 'paid' | 'refunded'
}

export interface TournamentRanking {
  id: number
  tournament: number
  user: {
    id: number
    username: string
    first_name: string
    last_name: string
  }
  rank: number
  wins: number
  losses: number
  draws: number
  crowns_earned: number
  crowns_lost: number
  score: number
  updated_at: string
}

export const useTournamentStore = defineStore('tournament', {
  state: () => ({
    tournaments: [] as Tournament[],
    currentTournament: null as Tournament | null,
    participants: [] as TournamentParticipant[],
    rankings: [] as TournamentRanking[],
    isLoading: false,
    error: null as string | null,
  }),

  getters: {
    // فیلتر تورنومنت‌ها بر اساس وضعیت
    openTournaments: (state) =>
      state.tournaments.filter(t => t.status === 'registration'),

    ongoingTournaments: (state) =>
      state.tournaments.filter(t => t.status === 'ongoing'),

    finishedTournaments: (state) =>
      state.tournaments.filter(t => t.status === 'finished'),

    // آیا کاربر در تورنومنت فعلی ثبت‌نام کرده؟
    isUserParticipant: (state) => {
      const authStore = useAuthStore()
      if (!authStore.user || !state.participants.length) return false

      return state.participants.some(
        p => p.user.id === authStore.user!.id && p.status === 'confirmed'
      )
    },
  },

  actions: {
    // دریافت لیست تورنومنت‌ها
    async fetchTournaments(filters?: { status?: string; game_type?: string }) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        let url = '/tournaments/'
        const params = new URLSearchParams()

        if (filters?.status) params.append('status', filters.status)
        if (filters?.game_type) params.append('game_type', filters.game_type)

        if (params.toString()) {
          url += `?${params.toString()}`
        }

        const response = await apiFetch(url)
        this.tournaments = response.results || response

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت تورنومنت‌ها'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // دریافت جزئیات یک تورنومنت
    async fetchTournamentDetails(id: number | string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        // اگر id یک عدد نیست (یعنی slug است)، آن را encode می‌کنیم
        const encodedId = typeof id === 'string' && isNaN(Number(id))
          ? encodeURIComponent(id)
          : id

        console.log('Fetching tournament details:', { id, encodedId })
        const response = await apiFetch(`/tournaments/${encodedId}/`)
        this.currentTournament = response

        return { success: true, data: response }
      } catch (error: any) {
        console.error('Error fetching tournament details:', error)
        this.error = error.data?.message || 'خطا در دریافت جزئیات تورنومنت'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // ثبت‌نام در تورنومنت
    async joinTournament(tournamentId: number | string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const encodedId = typeof tournamentId === 'string' && isNaN(Number(tournamentId))
          ? encodeURIComponent(tournamentId)
          : tournamentId

        // بکند از endpoint register استفاده می‌کند نه join
        const response = await apiFetch(`/tournaments/${encodedId}/register/`, {
          method: 'POST'
        })

        // به‌روزرسانی تعداد شرکت‌کنندگان
        if (this.currentTournament) {
          this.currentTournament.current_participants += 1
        }

        return { success: true, message: response.message || 'با موفقیت ثبت‌نام شدید' }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در ثبت‌نام'
        return {
          success: false,
          message: this.error,
          errors: error.data
        }
      } finally {
        this.isLoading = false
      }
    },

    // دریافت لیست شرکت‌کنندگان
    async fetchParticipants(tournamentId: number | string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const encodedId = typeof tournamentId === 'string' && isNaN(Number(tournamentId))
          ? encodeURIComponent(tournamentId)
          : tournamentId

        const response = await apiFetch(`/tournaments/${encodedId}/participants/`)
        this.participants = response.results || response

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت شرکت‌کنندگان'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // دریافت رنکینگ تورنومنت
    async fetchRankings(tournamentId: number | string) {
      try {
        this.isLoading = true
        this.error = null
        const { apiFetch } = useApi()

        const encodedId = typeof tournamentId === 'string' && isNaN(Number(tournamentId))
          ? encodeURIComponent(tournamentId)
          : tournamentId

        // بکند از endpoint leaderboard استفاده می‌کند نه rankings
        const response = await apiFetch(`/tournaments/${encodedId}/leaderboard/`)
        this.rankings = response.results || response

        return { success: true }
      } catch (error: any) {
        this.error = error.data?.message || 'خطا در دریافت رنکینگ'
        return { success: false, message: this.error }
      } finally {
        this.isLoading = false
      }
    },

    // پاک کردن تورنومنت فعلی
    clearCurrentTournament() {
      this.currentTournament = null
      this.participants = []
      this.rankings = []
    },
  }
})
