<template>
  <div class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed mobile-bg md:desktop-bg flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <!-- Logo & Title -->
      <div class="text-center mb-8">
        <h1 class="text-4xl font-black text-white mb-2">
          🏆 ایران تورنومنت
        </h1>
        <p class="text-white/80">تکمیل اطلاعات ثبت‌نام</p>
      </div>

      <!-- Register Card -->
      <div class="bg-white rounded-3xl shadow-2xl p-8">
        <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">
          اطلاعات خود را تکمیل کنید
        </h2>

        <!-- Error Message -->
        <div
          v-if="errorMessage"
          class="bg-red-50 border-r-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg"
        >
          <p class="font-medium">{{ errorMessage }}</p>
          <ul v-if="Object.keys(errors).length > 0" class="mt-2 text-sm list-disc list-inside">
            <li v-for="(msgs, field) in errors" :key="field">
              <strong>{{ getFieldLabel(field) }}:</strong> {{ Array.isArray(msgs) ? msgs[0] : msgs }}
            </li>
          </ul>
        </div>

        <!-- Success Message -->
        <div
          v-if="successMessage"
          class="bg-green-50 border-r-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg"
        >
          <p class="font-medium">{{ successMessage }}</p>
        </div>

        <!-- Phone Number Display -->
        <div class="bg-purple-50 border border-purple-200 rounded-xl p-4 mb-6">
          <p class="text-sm text-gray-600 text-center">
            شماره موبایل تایید شده:
            <span class="font-bold text-purple-700">{{ phoneNumber }}</span>
          </p>
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
              autofocus
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="username"
              :class="{ 'border-red-500': errors.username }"
            >
            <p class="text-xs text-gray-500 mt-1">
              فقط حروف انگلیسی، اعداد و _ مجاز است
            </p>
          </div>

          <!-- First Name & Last Name -->
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام *
              </label>
              <input
                v-model="form.first_name"
                type="text"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="علی"
              >
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                نام خانوادگی *
              </label>
              <input
                v-model="form.last_name"
                type="text"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="احمدی"
              >
            </div>
          </div>

          <!-- Email (Optional) -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              ایمیل (اختیاری)
            </label>
            <input
              v-model="form.email"
              type="email"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="example@email.com"
              :class="{ 'border-red-500': errors.email }"
            >
          </div>

          <!-- Clash Royale Tag (Optional) -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">
              تگ کلش رویال (اختیاری)
            </label>
            <input
              v-model="form.clash_royale_tag"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
              placeholder="#ABC123"
              :class="{ 'border-red-500': errors.clash_royale_tag }"
            >
            <p class="text-xs text-gray-500 mt-1">
              تگ کلش رویال خود را با # وارد کنید
            </p>
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
            <span v-else>تکمیل ثبت‌نام</span>
          </button>
        </form>

        <!-- Back to Login -->
        <div class="mt-6 text-center">
          <NuxtLink to="/login" class="text-gray-600 hover:text-gray-700 text-sm">
            ← بازگشت به ورود
          </NuxtLink>
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
  layout: false,
  middleware: 'guest'
})

const authStore = useAuthStore()
const router = useRouter()
const route = useRoute()

// Get phone number from query params
const phoneNumber = ref(route.query.phone as string || '')

// Redirect if no phone number
onMounted(() => {
  if (!phoneNumber.value) {
    navigateTo('/login')
  }
})

// Form data
const form = ref({
  username: '',
  first_name: '',
  last_name: '',
  email: '',
  clash_royale_tag: ''
})

// State
const loading = ref(false)
const errorMessage = ref('')
const successMessage = ref('')
const errors = ref<any>({})

// Get field label in Persian
const getFieldLabel = (field: string): string => {
  const labels: { [key: string]: string } = {
    username: 'نام کاربری',
    first_name: 'نام',
    last_name: 'نام خانوادگی',
    email: 'ایمیل',
    clash_royale_tag: 'تگ کلش رویال',
    phone_number: 'شماره موبایل'
  }
  return labels[field] || field
}

// Handle Register
const handleRegister = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  errors.value = {}

  // Prepare data
  const data: any = {
    phone_number: phoneNumber.value,
    username: form.value.username,
    first_name: form.value.first_name,
    last_name: form.value.last_name
  }

  // Add optional fields if provided
  if (form.value.email) {
    data.email = form.value.email
  }
  if (form.value.clash_royale_tag) {
    data.clash_royale_tag = form.value.clash_royale_tag
  }

  const result = await authStore.completeRegistration(data)

  loading.value = false

  if (result.success) {
    successMessage.value = result.message

    // Redirect after 1 second
    setTimeout(() => {
      navigateTo('/dashboard', { replace: true })
    }, 1000)
  } else {
    errorMessage.value = result.message
    errors.value = result.errors || {}
  }
}

// SEO
useHead({
  title: 'تکمیل ثبت‌نام - ایران تورنومنت',
  meta: [
    { name: 'description', content: 'تکمیل اطلاعات ثبت‌نام در پلتفرم تورنومنت کلش رویال' }
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
