<template>
  <div class="min-h-screen bg-gray-50">
    <header class="bg-white shadow-sm">
      <div class="container mx-auto px-4 py-4">
        <div class="flex items-center gap-4">
          <NuxtLink to="/dashboard" class="text-gray-600 hover:text-gray-800">
            ← بازگشت
          </NuxtLink>
          <h1 class="text-2xl font-bold text-gray-800">ویرایش پروفایل</h1>
        </div>
      </div>
    </header>

    <main class="container mx-auto px-4 py-8 max-w-2xl">
      <!-- Messages -->
      <div v-if="successMessage" class="bg-green-50 border-r-4 border-green-500 text-green-700 p-4 mb-6 rounded-lg">
        <p class="font-medium">{{ successMessage }}</p>
      </div>

      <div v-if="errorMessage" class="bg-red-50 border-r-4 border-red-500 text-red-700 p-4 mb-6 rounded-lg">
        <p class="font-medium">{{ errorMessage }}</p>
        <pre v-if="errors" class="text-xs mt-2">{{ JSON.stringify(errors, null, 2) }}</pre>
      </div>

      <!-- Profile Card -->
      <div class="bg-white rounded-2xl shadow-lg p-6">
        <h2 class="text-xl font-bold text-gray-800 mb-6">اطلاعات کاربری</h2>

        <form @submit.prevent="handleSubmit" class="space-y-5">
          <!-- Username (readonly) -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">نام کاربری</label>
            <input
              :value="user?.username"
              type="text"
              disabled
              class="w-full px-4 py-3 border border-gray-300 rounded-xl bg-gray-50 text-gray-500"
            >
          </div>

          <!-- First Name -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">نام</label>
            <input
              v-model="form.first_name"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500"
              placeholder="نام شما"
            >
          </div>

          <!-- Last Name -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">نام خانوادگی</label>
            <input
              v-model="form.last_name"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500"
              placeholder="نام خانوادگی شما"
            >
          </div>

          <!-- Phone -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">شماره موبایل</label>
            <input
              v-model="form.phone_number"
              type="tel"
              maxlength="11"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500"
              placeholder="09123456789"
            >
          </div>

          <!-- Clash Royale Tag -->
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-2">تگ کلش رویال</label>
            <input
              v-model="form.clash_royale_tag"
              type="text"
              class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500"
              placeholder="#ABC123"
            >
          </div>

          <!-- Buttons -->
          <div class="flex gap-4">
            <button
              type="submit"
              :disabled="loading"
              class="flex-1 bg-purple-600 text-white font-bold py-3 rounded-xl hover:bg-purple-700 disabled:opacity-50"
            >
              {{ loading ? 'در حال ذخیره...' : 'ذخیره تغییرات' }}
            </button>
            
            <NuxtLink
              to="/dashboard"
              class="px-6 py-3 border-2 border-gray-300 text-gray-700 font-bold rounded-xl hover:bg-gray-50 text-center"
            >
              لغو
            </NuxtLink>
          </div>
        </form>
      </div>
    </main>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  middleware: 'auth'
})

const authStore = useAuthStore()
const user = computed(() => authStore.user)

const loading = ref(false)
const successMessage = ref('')
const errorMessage = ref('')
const errors = ref<any>(null)

const form = ref({
  first_name: '',
  last_name: '',
  phone_number: '',
  clash_royale_tag: ''
})

// Load current data
onMounted(() => {
  if (user.value) {
    form.value = {
      first_name: user.value.first_name || '',
      last_name: user.value.last_name || '',
      phone_number: user.value.phone_number || '',
      clash_royale_tag: user.value.clash_royale_tag || ''
    }
  }
})

// Handle submit
const handleSubmit = async () => {
  loading.value = true
  errorMessage.value = ''
  successMessage.value = ''
  errors.value = null

  console.log('Submitting form:', form.value) // Debug

  try {
    const { apiFetch } = useApi()
    
    const response = await apiFetch('/auth/profile/update/', {
      method: 'PATCH',
      body: form.value
    })

    console.log('Response:', response) // Debug

    // Update store
    if (response.user) {
      authStore.updateUser(response.user)
    }

    successMessage.value = response.message || 'پروفایل با موفقیت بروزرسانی شد!'
    
    window.scrollTo({ top: 0, behavior: 'smooth' })
  } catch (error: any) {
    console.error('Error:', error) // Debug
    
    errorMessage.value = error.data?.message || error.message || 'خطا در بروزرسانی پروفایل'
    errors.value = error.data
  } finally {
    loading.value = false
  }
}

useHead({
  title: 'ویرایش پروفایل - ایران تورنومنت'
})
</script>