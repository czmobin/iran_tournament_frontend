<template>
  <div class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed mobile-bg md:desktop-bg flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <!-- Logo & Title -->
      <div class="text-center mb-8">
        <h1 class="text-4xl font-black text-white mb-2">
          🏆 ایران تورنومنت
        </h1>
        <p class="text-white/80">ثبت‌نام در پلتفرم تورنومنت</p>
      </div>

      <!-- Register Card -->
      <div class="bg-white rounded-3xl shadow-2xl p-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">
          ساخت حساب کاربری
        </h2>

        <!-- Error Message -->
        <div 
          v-if="errorMessage" 
          class="bg-red-50 border-r-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg"
        >
          <p class="font-medium">{{ errorMessage }}</p>
        </div>

        <!-- Success Message -->
        <div 
          v-if="successMessage" 
          class="bg-green-50 border-r-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg"
        >
          <p class="font-medium">{{ successMessage }}</p>
        </div>

        <!-- Form -->
        <form @submit.prevent="handleRegister" class="space-y-4">
          <!-- Username -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              نام کاربری *
            </label>
            <input
              v-model="form.username"
              type="text"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="username"
              :class="{ 'border-red-500': errors.username }"
            >
            <p v-if="errors.username" class="text-red-500 text-sm mt-1">
              {{ errors.username[0] }}
            </p>
          </div>

          <!-- Email -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              ایمیل *
            </label>
            <input
              v-model="form.email"
              type="email"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="example@email.com"
              :class="{ 'border-red-500': errors.email }"
            >
            <p v-if="errors.email" class="text-red-500 text-sm mt-1">
              {{ errors.email[0] }}
            </p>
          </div>

          <!-- First Name & Last Name -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام
              </label>
              <input
                v-model="form.first_name"
                type="text"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="علی"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام خانوادگی
              </label>
              <input
                v-model="form.last_name"
                type="text"
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="احمدی"
              >
            </div>
          </div>

          <!-- Phone Number -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              شماره موبایل
            </label>
            <input
              v-model="form.phone_number"
              type="tel"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="09123456789"
              maxlength="11"
              :class="{ 'border-red-500': errors.phone_number }"
            >
            <p v-if="errors.phone_number" class="text-red-500 text-sm mt-1">
              {{ errors.phone_number[0] }}
            </p>
          </div>

          <!-- Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              رمز عبور *
            </label>
            <div class="relative">
              <input
                v-model="form.password"
                :type="showPassword ? 'text' : 'password'"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="حداقل 8 کاراکتر"
                :class="{ 'border-red-500': errors.password }"
              >
              <button
                type="button"
                @click="showPassword = !showPassword"
                class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-700"
              >
                {{ showPassword ? '👁️' : '👁️‍🗨️' }}
              </button>
            </div>
            <p v-if="errors.password" class="text-red-500 text-sm mt-1">
              {{ errors.password[0] }}
            </p>
          </div>

          <!-- Confirm Password -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              تکرار رمز عبور *
            </label>
            <input
              v-model="form.password2"
              :type="showPassword ? 'text' : 'password'"
              required
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="تکرار رمز عبور"
            >
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="loading"
            class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold py-4 rounded-xl hover:from-purple-700 hover:to-indigo-700 transition transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin h-5 w-5 ml-3" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              در حال ثبت‌نام...
            </span>
            <span v-else>ثبت‌نام</span>
          </button>
        </form>

        <!-- Login Link -->
        <div class="mt-6 text-center">
          <p class="text-gray-600">
            قبلاً ثبت‌نام کرده‌اید؟
            <NuxtLink to="/login" class="text-purple-600 font-bold hover:text-purple-700">
              وارد شوید
            </NuxtLink>
          </p>
        </div>
      </div>

      <!-- Terms -->
      <p class="text-center text-white/60 text-sm mt-6">
        با ثبت‌نام، 
        <NuxtLink to="/terms" class="underline hover:text-white">
          قوانین و مقررات
        </NuxtLink>
        را می‌پذیرید
      </p>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false, // بدون layout
  middleware: 'guest' // فقط برای کاربران مهمان
})

const authStore = useAuthStore()
const router = useRouter()

// Form data
const form = ref({
  username: '',
  email: '',
  password: '',
  password2: '',
  first_name: '',
  last_name: '',
  phone_number: ''
})

// State
const loading = ref(false)
const showPassword = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const errors = ref<any>({})

// Handle Register
const handleRegister = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  errors.value = {}

  const result = await authStore.register(form.value)

  loading.value = false

  if (result.success) {
    successMessage.value = result.message
    
    // Redirect after 1 second
    setTimeout(() => {
      router.push('/dashboard')
    }, 1000)
  } else {
    errorMessage.value = result.message
    errors.value = result.errors || {}
  }
}

// SEO
useHead({
  title: 'ثبت‌نام - ایران تورنومنت',
  meta: [
    { name: 'description', content: 'ثبت‌نام در پلتفرم تورنومنت کلش رویال' }
  ]
})
</script>

<style scoped>
.mobile-bg {
  background-image: url('/mobile_index.png');
}

@media (min-width: 768px) {
  .desktop-bg {
    background-image: url('/desktop_index.png');
  }
}
</style>