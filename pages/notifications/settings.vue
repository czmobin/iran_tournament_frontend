<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 to-blue-50 py-8">
    <div class="container mx-auto px-4 max-w-4xl">
      <!-- Header -->
      <div class="bg-white rounded-2xl shadow-lg p-6 mb-6">
        <div class="flex items-center gap-4">
          <button
            @click="router.back()"
            class="text-gray-600 hover:text-gray-900 transition"
          >
            <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          <div>
            <h1 class="text-3xl font-black text-gray-900 mb-2">
              ⚙️ تنظیمات اعلان‌ها
            </h1>
            <p class="text-gray-600">
              شخصی‌سازی نحوه دریافت اعلان‌ها
            </p>
          </div>
        </div>
      </div>

      <!-- Loading State -->
      <div v-if="notificationStore.isLoadingPreferences" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="animate-spin rounded-full h-12 w-12 border-t-4 border-b-4 border-purple-600 mx-auto mb-4"></div>
        <p class="text-gray-600">در حال بارگذاری تنظیمات...</p>
      </div>

      <!-- Error State -->
      <div v-else-if="notificationStore.preferencesError && !notificationStore.preferences" class="bg-white rounded-2xl shadow-lg p-12 text-center">
        <div class="text-red-500 text-6xl mb-4">❌</div>
        <h3 class="text-xl font-bold text-gray-900 mb-2">خطا در بارگذاری تنظیمات</h3>
        <p class="text-gray-600 mb-6">{{ notificationStore.preferencesError }}</p>
        <button
          @click="fetchPreferences"
          class="bg-purple-600 hover:bg-purple-700 text-white px-6 py-3 rounded-lg transition font-bold"
        >
          تلاش مجدد
        </button>
      </div>

      <!-- Settings Form -->
      <div v-else-if="localPreferences" class="space-y-6">
        <!-- Success Message -->
        <div
          v-if="showSuccessMessage"
          class="bg-green-50 border-2 border-green-500 rounded-xl p-4 flex items-center gap-3 animate-slide-down"
        >
          <div class="text-green-600 text-2xl">✅</div>
          <p class="text-green-700 font-bold">تنظیمات با موفقیت ذخیره شد</p>
        </div>

        <!-- Delivery Channels -->
        <div class="bg-white rounded-2xl shadow-lg p-6">
          <h2 class="text-xl font-black text-gray-900 mb-4 flex items-center gap-2">
            📨 روش‌های ارسال
          </h2>
          <p class="text-gray-600 mb-6 text-sm">
            انتخاب کنید که از چه طریقی اعلان‌ها را دریافت کنید
          </p>

          <div class="space-y-4">
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">📧</div>
                <div>
                  <h3 class="font-bold text-gray-900">ایمیل</h3>
                  <p class="text-sm text-gray-600">دریافت اعلان از طریق ایمیل</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.email_enabled"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">📱</div>
                <div>
                  <h3 class="font-bold text-gray-900">پیامک</h3>
                  <p class="text-sm text-gray-600">دریافت اعلان از طریق پیامک</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.sms_enabled"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">🔔</div>
                <div>
                  <h3 class="font-bold text-gray-900">اعلان‌های داخل برنامه</h3>
                  <p class="text-sm text-gray-600">نمایش اعلان در وب‌سایت</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.push_enabled"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>
          </div>
        </div>

        <!-- Notification Types -->
        <div class="bg-white rounded-2xl shadow-lg p-6">
          <h2 class="text-xl font-black text-gray-900 mb-4 flex items-center gap-2">
            📋 انواع اعلان‌ها
          </h2>
          <p class="text-gray-600 mb-6 text-sm">
            انتخاب کنید کدام رویدادها برای شما اعلان ارسال شود
          </p>

          <div class="space-y-4">
            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">🏁</div>
                <div>
                  <h3 class="font-bold text-gray-900">شروع تورنومنت</h3>
                  <p class="text-sm text-gray-600">زمانی که تورنومنت شروع می‌شود</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.tournament_start"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">📝</div>
                <div>
                  <h3 class="font-bold text-gray-900">تایید ثبت‌نام</h3>
                  <p class="text-sm text-gray-600">تایید ثبت‌نام در تورنومنت</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.tournament_registration"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">⏰</div>
                <div>
                  <h3 class="font-bold text-gray-900">یادآوری مسابقه</h3>
                  <p class="text-sm text-gray-600">یادآوری زمان مسابقات</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.match_reminder"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">🏆</div>
                <div>
                  <h3 class="font-bold text-gray-900">توزیع جوایز</h3>
                  <p class="text-sm text-gray-600">زمانی که جایزه به حسابتان واریز می‌شود</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.prize_distribution"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">💰</div>
                <div>
                  <h3 class="font-bold text-gray-900">تکمیل برداشت</h3>
                  <p class="text-sm text-gray-600">تایید برداشت از کیف پول</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.withdrawal_completion"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>

            <div class="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
              <div class="flex items-center gap-3">
                <div class="text-2xl">📊</div>
                <div>
                  <h3 class="font-bold text-gray-900">به‌روزرسانی رتبه‌بندی</h3>
                  <p class="text-sm text-gray-600">تغییر در رتبه‌بندی شما</p>
                </div>
              </div>
              <label class="relative inline-flex items-center cursor-pointer">
                <input
                  type="checkbox"
                  v-model="localPreferences.ranking_update"
                  @change="handlePreferenceChange"
                  class="sr-only peer"
                >
                <div class="w-14 h-7 bg-gray-300 peer-focus:outline-none peer-focus:ring-4 peer-focus:ring-purple-300 rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:right-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-6 after:w-6 after:transition-all peer-checked:bg-purple-600"></div>
              </label>
            </div>
          </div>
        </div>

        <!-- Save Button -->
        <div class="bg-white rounded-2xl shadow-lg p-6">
          <button
            @click="savePreferences"
            :disabled="!hasChanges || isSaving"
            class="w-full bg-gradient-to-r from-purple-600 to-pink-600 hover:from-purple-700 hover:to-pink-700 text-white py-4 rounded-xl transition font-bold text-lg disabled:opacity-50 disabled:cursor-not-allowed"
          >
            {{ isSaving ? '⏳ در حال ذخیره...' : '💾 ذخیره تنظیمات' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { NotificationPreference } from '~/stores/notifications'

definePageMeta({
  middleware: 'auth'
})

const notificationStore = useNotificationsStore()
const router = useRouter()

const localPreferences = ref<NotificationPreference | null>(null)
const originalPreferences = ref<NotificationPreference | null>(null)
const hasChanges = ref(false)
const isSaving = ref(false)
const showSuccessMessage = ref(false)

// Fetch preferences on mount
const fetchPreferences = async () => {
  const result = await notificationStore.fetchPreferences()
  if (result.success && notificationStore.preferences) {
    localPreferences.value = { ...notificationStore.preferences }
    originalPreferences.value = { ...notificationStore.preferences }
  }
}

// Handle preference change
const handlePreferenceChange = () => {
  if (!localPreferences.value || !originalPreferences.value) return

  hasChanges.value = JSON.stringify(localPreferences.value) !== JSON.stringify(originalPreferences.value)
}

// Save preferences
const savePreferences = async () => {
  if (!localPreferences.value || !hasChanges.value) return

  isSaving.value = true
  showSuccessMessage.value = false

  const result = await notificationStore.updatePreferences(localPreferences.value)

  if (result.success) {
    originalPreferences.value = { ...localPreferences.value }
    hasChanges.value = false
    showSuccessMessage.value = true

    // Hide success message after 3 seconds
    setTimeout(() => {
      showSuccessMessage.value = false
    }, 3000)
  }

  isSaving.value = false
}

// Initialize
onMounted(() => {
  fetchPreferences()
})
</script>

<style scoped>
@keyframes slideDown {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.animate-slide-down {
  animation: slideDown 0.3s ease-out;
}
</style>
