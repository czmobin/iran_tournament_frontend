<template>
  <div class="min-h-screen bg-cover bg-center bg-no-repeat bg-fixed mobile-bg md:desktop-bg flex items-center justify-center p-4">
    <div class="max-w-md w-full">
      <div class="text-center mb-8">
        <h1 class="text-4xl font-black text-white mb-2">
          🔐 بازیابی رمز عبور
        </h1>
        <p class="text-white/80">لینک بازیابی به ایمیل شما ارسال می‌شود</p>
      </div>

      <div class="bg-white rounded-3xl shadow-2xl p-8">
        <div v-if="!submitted">
          <h2 class="text-2xl font-bold text-gray-800 mb-6 text-center">
            فراموشی رمز عبور
          </h2>

          <form @submit.prevent="handleSubmit" class="space-y-5">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-2">
                ایمیل
              </label>
              <input
                v-model="email"
                type="email"
                required
                class="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-transparent transition"
                placeholder="example@email.com"
              >
            </div>

            <button
              type="submit"
              :disabled="loading"
              class="w-full bg-gradient-to-r from-purple-600 to-indigo-600 text-white font-bold py-4 rounded-xl hover:from-purple-700 hover:to-indigo-700 transition disabled:opacity-50"
            >
              <span v-if="loading">در حال ارسال...</span>
              <span v-else>ارسال لینک بازیابی</span>
            </button>
          </form>
        </div>

        <div v-else class="text-center">
          <div class="text-green-600 text-6xl mb-4">✅</div>
          <h3 class="text-xl font-bold text-gray-800 mb-2">ارسال شد!</h3>
          <p class="text-gray-600 mb-6">
            لینک بازیابی رمز عبور به ایمیل شما ارسال شد.
          </p>
          <NuxtLink 
            to="/login"
            class="inline-block bg-purple-600 text-white px-6 py-3 rounded-xl font-bold hover:bg-purple-700 transition"
          >
            بازگشت به ورود
          </NuxtLink>
        </div>

        <div class="mt-6 text-center">
          <NuxtLink to="/login" class="text-purple-600 hover:text-purple-700 font-medium">
            ← بازگشت به ورود
          </NuxtLink>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({
  layout: false,
  middleware: 'guest'
})

const email = ref('')
const loading = ref(false)
const submitted = ref(false)

const handleSubmit = async () => {
  loading.value = true
  
  // Simulate API call
  await new Promise(resolve => setTimeout(resolve, 1000))
  
  submitted.value = true
  loading.value = false
}

useHead({
  title: 'فراموشی رمز عبور - ایران تورنومنت'
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