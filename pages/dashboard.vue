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
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
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
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: 'auth'
})

const authStore = useAuthStore()
const router = useRouter()

// State
const isLoading = ref(true)
const refreshing = ref(false)

// Get user data
const user = computed(() => authStore.user)

// Fetch profile on mount
onMounted(async () => {
  isLoading.value = true
  
  // اگه user نداریم یا داده‌ها قدیمی هستن، از سرور بگیر
  if (!authStore.user || shouldRefreshData()) {
    await authStore.fetchProfile()
  }
  
  isLoading.value = false
})

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

// SEO
useHead({
  title: 'داشبورد - ایران تورنومنت'
})
</script>