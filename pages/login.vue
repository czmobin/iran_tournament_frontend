<template>
  <div class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed mobile-bg md:desktop-bg flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <!-- Logo & Title -->
      <div class="text-center mb-6 md:mb-8">
        <h1 class="text-3xl md:text-4xl font-black text-white mb-2">
          🏆 ایران تورنومنت
        </h1>
        <p class="text-sm md:text-base text-white/80">ورود / ثبت‌نام</p>
      </div>

      <!-- Login Card -->
      <div class="bg-white rounded-2xl md:rounded-3xl shadow-2xl p-6 md:p-8">
        <h2 class="text-xl md:text-2xl font-bold text-gray-800 mb-4 md:mb-6 text-center">
          {{ otpSent ? 'تایید کد' : 'خوش آمدید!' }}
        </h2>

        <!-- Error Message -->
        <div
          v-if="errorMessage"
          class="bg-red-50 border-r-4 border-red-500 text-red-700 p-3 md:p-4 mb-4 md:mb-6 rounded-lg text-sm md:text-base"
        >
          <p class="font-medium">{{ errorMessage }}</p>
        </div>

        <!-- Success Message -->
        <div
          v-if="successMessage"
          class="bg-green-50 border-r-4 border-green-500 text-green-700 p-3 md:p-4 mb-4 md:mb-6 rounded-lg text-sm md:text-base"
        >
          <p class="font-medium">{{ successMessage }}</p>
        </div>

        <!-- Step 1: Phone Number -->
        <form v-if="!otpSent" @submit.prevent="handleSendOTP" class="space-y-4 md:space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              شماره موبایل
            </label>
            <input
              v-model="phoneNumber"
              type="tel"
              required
              autofocus
              maxlength="11"
              class="w-full px-4 py-3 md:py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition text-base text-center tracking-wider"
              placeholder="09123456789"
              pattern="09[0-9]{9}"
              @input="formatPhoneNumber"
            >
            <p class="text-xs text-gray-500 mt-1 text-center">
              کد تایید به این شماره ارسال می‌شود
            </p>
          </div>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="loading || !isValidPhone"
            class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold py-3 md:py-4 rounded-xl hover:from-purple-700 hover:to-indigo-700 transition transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed text-base md:text-lg"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin h-5 w-5 ml-3" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              در حال ارسال...
            </span>
            <span v-else>ارسال کد تایید</span>
          </button>
        </form>

        <!-- Step 2: OTP Verification -->
        <form v-else @submit.prevent="handleVerifyOTP" class="space-y-4 md:space-y-5">
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2 text-center">
              کد تایید ارسال شده به {{ phoneNumber }} را وارد کنید
            </label>
            <input
              v-model="otp"
              type="text"
              required
              autofocus
              maxlength="5"
              class="w-full px-4 py-4 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition text-2xl text-center tracking-widest font-bold"
              placeholder="-----"
              pattern="[0-9]{5}"
              inputmode="numeric"
            >
            <p class="text-xs text-gray-500 mt-2 text-center">
              کد 5 رقمی را وارد کنید
            </p>
          </div>

          <!-- Countdown Timer -->
          <div v-if="countdown > 0" class="text-center text-sm text-gray-600">
            {{ Math.floor(countdown / 60) }}:{{ String(countdown % 60).padStart(2, '0') }} تا ارسال مجدد
          </div>

          <!-- Resend Button -->
          <button
            v-if="countdown === 0"
            type="button"
            @click="handleResendOTP"
            class="w-full text-purple-600 hover:text-purple-700 font-medium text-sm"
          >
            ارسال مجدد کد
          </button>

          <!-- Submit Button -->
          <button
            type="submit"
            :disabled="loading || otp.length !== 5"
            class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold py-3 md:py-4 rounded-xl hover:from-purple-700 hover:to-indigo-700 transition transform hover:scale-[1.02] disabled:opacity-50 disabled:cursor-not-allowed text-base md:text-lg"
          >
            <span v-if="loading" class="flex items-center justify-center">
              <svg class="animate-spin h-5 w-5 ml-3" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              در حال تایید...
            </span>
            <span v-else>تایید و ورود</span>
          </button>

          <!-- Back Button -->
          <button
            type="button"
            @click="resetForm"
            class="w-full text-gray-600 hover:text-gray-700 font-medium text-sm"
          >
            ← تغییر شماره موبایل
          </button>
        </form>
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

// Form state
const phoneNumber = ref('')
const otp = ref('')
const otpSent = ref(false)
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const countdown = ref(0)
let countdownInterval: NodeJS.Timeout | null = null

// Validation
const isValidPhone = computed(() => {
  return /^09[0-9]{9}$/.test(phoneNumber.value)
})

// Format phone number input
const formatPhoneNumber = () => {
  phoneNumber.value = phoneNumber.value.replace(/[^0-9]/g, '')
}

// Start countdown timer
const startCountdown = () => {
  countdown.value = 120 // 2 minutes

  if (countdownInterval) {
    clearInterval(countdownInterval)
  }

  countdownInterval = setInterval(() => {
    countdown.value--
    if (countdown.value <= 0) {
      if (countdownInterval) {
        clearInterval(countdownInterval)
      }
    }
  }, 1000)
}

// Handle Send OTP
const handleSendOTP = async () => {
  if (!isValidPhone.value) {
    errorMessage.value = 'لطفا شماره موبایل معتبر وارد کنید'
    return
  }

  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  const result = await authStore.sendOTP(phoneNumber.value)

  if (result.success) {
    otpSent.value = true
    successMessage.value = result.message
    startCountdown()
  } else {
    errorMessage.value = result.message
  }

  loading.value = false
}

// Handle Resend OTP
const handleResendOTP = async () => {
  await handleSendOTP()
}

// Handle Verify OTP
const handleVerifyOTP = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''

  const result = await authStore.verifyOTP(phoneNumber.value, otp.value)

  if (result.success) {
    if (result.action === 'login') {
      // کاربر موجود - ورود موفق
      successMessage.value = result.message
      await nextTick()
      await navigateTo('/dashboard', { replace: true })
    } else if (result.action === 'register') {
      // کاربر جدید - هدایت به صفحه تکمیل ثبت‌نام
      await navigateTo({
        path: '/register',
        query: { phone: result.phoneNumber }
      }, { replace: true })
    }
  } else {
    errorMessage.value = result.message
  }

  loading.value = false
}

// Reset form
const resetForm = () => {
  otpSent.value = false
  otp.value = ''
  errorMessage.value = ''
  successMessage.value = ''
  countdown.value = 0
  if (countdownInterval) {
    clearInterval(countdownInterval)
  }
}

// Cleanup on unmount
onUnmounted(() => {
  if (countdownInterval) {
    clearInterval(countdownInterval)
  }
})

useHead({
  title: 'ورود - ایران تورنومنت',
  meta: [
    { name: 'viewport', content: 'width=device-width, initial-scale=1, maximum-scale=5' }
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
