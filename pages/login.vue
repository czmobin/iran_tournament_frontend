<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-600 via-blue-600 to-indigo-700 flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <!-- Logo & Title -->
      <div class="text-center mb-6 md:mb-8">
        <h1 class="text-3xl md:text-4xl font-black text-white mb-2">
          🏆 ایران تورنومنت
        </h1>
        <p class="text-sm md:text-base text-white/80">ورود به حساب کاربری</p>
      </div>

      <!-- Login Card -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-2xl p-6 md:p-8">
        <h2 class="text-xl md:text-2xl font-bold text-gray-800 mb-4 md:mb-6 text-center">
          خوش آمدید!
        </h2>

        <!-- Error Message -->
        <div 
          v-if="errorMessage" 
          class="bg-red-50 border-r-4 border-red-500 text-red-700 p-3 md:p-4 mb-4 md:mb-6 rounded-lg text-sm md:text-base"
        >
          <p class="font-medium">{{ errorMessage }}</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleLogin" class="space-y-4 md:space-y-5">
          <!-- Username -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نام کاربری یا ایمیل
            </label>
            <input
              v-model="username"
              type="text"
              required
              autofocus
              class="w-full px-4 py-3 md:py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition text-base"
              placeholder="نام کاربری خود را وارد کنید"
            >
          </div>

          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              رمز عبور
            </label>
            <div class="relative">
              <input
                v-model="password"
                :type="showPassword ? 'text' : 'password'"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition text-base"
                placeholder="رمز عبور خود را وارد کنید"
              >
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700 p-2"
              >
                {{ showPassword ? '👁️' : '👁️‍🗨️' }}
              </button>
            </div>
          </div>

          <!-- Remember & Forgot -->
          <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
            <label class="flex items-center">
              <input
                v-model="rememberMe"
                type="checkbox"
                class="rounded border-gray-300 text-purple-600 focus:ring-purple-500"
              >
              <span class="mr-2 text-sm text-gray-600">مرا به خاطر بسپار</span>
            </label>
            
            <NuxtLink to="/forgot-password" class="text-sm text-purple-600 hover:text-purple-700 font-medium">
              فراموشی رمز عبور؟
            </NuxtLink>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold py-3 md:py-4 rounded-xl hover:from-purple-700 hover:to-indigo-700 transition transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed text-base md:text-lg"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin h-5 w-5 ml-3" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              در حال ورود...
            </span>
            <span v-else>ورود به حساب</span>
          </button>
        </form>

        <!-- Divider -->
        <div class="relative my-6">
          <div class="absolute inset-0 flex items-center">
            <div class="w-full border-t border-gray-300"></div>
          </div>
          <div class="relative flex justify-center text-sm">
            <span class="px-4 bg-white text-gray-500">یا</span>
          </div>
        </div>

        <!-- Register Link -->
        <div class="text-center">
          <p class="text-sm md:text-base text-gray-600">
            حساب کاربری ندارید؟
            <NuxtLink to="/register" class="text-purple-600 font-bold hover:text-purple-700">
              ثبت‌نام کنید
            </NuxtLink>
          </p>
        </div>
      </div>

      <!-- Back to Home -->
      <div class="text-center mt-4 md:mt-6">
        <NuxtLink to="/" class="text-white/80 hover:text-white text-sm md:text-base">
          ← بازگشت به صفحه اصلی
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
  middleware: 'guest'
})

const authStore = useAuthStore()
const router = useRouter()

const username = ref('')
const password = ref('')
const rememberMe = ref(false)
const loading = ref(false)
const showPassword = ref(false)
const errorMessage = ref('')

const handleLogin = async () => {
  loading.value = true
  errorMessage.value = ''

  const result = await authStore.login(username.value, password.value)

  loading.value = false

  if (result.success) {
    setTimeout(() => {
      router.push('/dashboard')
    }, 500)
  } else {
    errorMessage.value = result.message
  }
}

useHead({
  title: 'ورود - ایران تورنومنت',
  meta: [
    { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=5' }
  ]
})
</script>