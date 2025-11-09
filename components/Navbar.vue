<template>
  <nav class="bg-gradient-to-r from-purple-600 via-pink-600 to-blue-600 shadow-lg sticky top-0 z-50">
    <div class="container mx-auto px-4">
      <div class="flex items-center justify-between h-16 md:h-20">
        <!-- Logo / Brand -->
        <NuxtLink to="/" class="flex items-center gap-2 md:gap-3 group">
          <div class="text-3xl md:text-4xl">🏆</div>
          <div>
            <h1 class="text-white font-black text-lg md:text-2xl group-hover:scale-105 transition-transform">
              ایران تورنومنت
            </h1>
            <p class="text-white/80 text-xs md:text-sm hidden sm:block">
              رقابت، پیروزی، افتخار
            </p>
          </div>
        </NuxtLink>

        <!-- Desktop Navigation -->
        <div class="hidden md:flex items-center gap-4">
          <NuxtLink
            to="/tournaments"
            class="text-white hover:bg-white/20 px-4 py-2 rounded-lg transition font-bold"
          >
            🎮 تورنومنت‌ها
          </NuxtLink>

          <template v-if="authStore.isAuthenticated">
            <NuxtLink
              to="/dashboard"
              class="text-white hover:bg-white/20 px-4 py-2 rounded-lg transition font-bold"
            >
              📊 داشبورد
            </NuxtLink>

            <NuxtLink
              to="/wallet"
              class="text-white hover:bg-white/20 px-4 py-2 rounded-lg transition font-bold"
            >
              💰 کیف پول
            </NuxtLink>

            <!-- Notification Bell -->
            <NotificationDropdown />

            <div class="relative" ref="profileMenuRef">
              <button
                @click="toggleProfileMenu"
                class="flex items-center gap-2 text-white hover:bg-white/20 px-4 py-2 rounded-lg transition font-bold"
              >
                <div class="w-8 h-8 bg-white/30 rounded-full flex items-center justify-center text-sm">
                  {{ userInitial }}
                </div>
                <span class="hidden lg:block">{{ authStore.userFullName || 'حساب کاربری' }}</span>
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
                </svg>
              </button>

              <!-- Dropdown Menu -->
              <div
                v-if="showProfileMenu"
                class="absolute left-0 mt-2 w-48 bg-white rounded-xl shadow-2xl py-2 border border-gray-200"
              >
                <NuxtLink
                  to="/profile"
                  @click="showProfileMenu = false"
                  class="block px-4 py-2 text-gray-700 hover:bg-purple-50 transition"
                >
                  👤 ویرایش پروفایل
                </NuxtLink>
                <button
                  @click="handleLogout"
                  class="w-full text-right px-4 py-2 text-red-600 hover:bg-red-50 transition"
                >
                  🚪 خروج
                </button>
              </div>
            </div>
          </template>

          <template v-else>
            <NuxtLink
              to="/login"
              class="text-white hover:bg-white/20 px-4 py-2 rounded-lg transition font-bold"
            >
              ورود
            </NuxtLink>
            <NuxtLink
              to="/register"
              class="bg-white text-purple-600 hover:bg-gray-100 px-6 py-2 rounded-lg transition font-bold shadow-lg"
            >
              ثبت‌نام
            </NuxtLink>
          </template>
        </div>

        <!-- Mobile Menu Button -->
        <button
          @click="toggleMobileMenu"
          class="md:hidden text-white p-2 hover:bg-white/20 rounded-lg transition"
        >
          <svg v-if="!showMobileMenu" class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
          <svg v-else class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Mobile Navigation Menu -->
      <div
        v-if="showMobileMenu"
        class="md:hidden pb-4 space-y-2 animate-slide-down"
      >
        <NuxtLink
          to="/tournaments"
          @click="showMobileMenu = false"
          class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
        >
          🎮 تورنومنت‌ها
        </NuxtLink>

        <template v-if="authStore.isAuthenticated">
          <NuxtLink
            to="/dashboard"
            @click="showMobileMenu = false"
            class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
          >
            📊 داشبورد
          </NuxtLink>

          <NuxtLink
            to="/wallet"
            @click="showMobileMenu = false"
            class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
          >
            💰 کیف پول
          </NuxtLink>

          <NuxtLink
            to="/notifications"
            @click="showMobileMenu = false"
            class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold relative"
          >
            🔔 اعلان‌ها
            <span
              v-if="notificationStore.unreadCount > 0"
              class="absolute top-2 left-2 bg-red-500 text-white text-xs font-bold rounded-full w-5 h-5 flex items-center justify-center"
            >
              {{ notificationStore.unreadCount > 9 ? '9+' : notificationStore.unreadCount }}
            </span>
          </NuxtLink>

          <NuxtLink
            to="/profile"
            @click="showMobileMenu = false"
            class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
          >
            👤 ویرایش پروفایل
          </NuxtLink>

          <button
            @click="handleLogout"
            class="w-full text-right text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
          >
            🚪 خروج
          </button>
        </template>

        <template v-else>
          <NuxtLink
            to="/login"
            @click="showMobileMenu = false"
            class="block text-white hover:bg-white/20 px-4 py-3 rounded-lg transition font-bold"
          >
            ورود
          </NuxtLink>
          <NuxtLink
            to="/register"
            @click="showMobileMenu = false"
            class="block bg-white text-purple-600 hover:bg-gray-100 px-4 py-3 rounded-lg transition font-bold text-center"
          >
            ثبت‌نام
          </NuxtLink>
        </template>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
const authStore = useAuthStore()
const notificationStore = useNotificationsStore()
const router = useRouter()

const showMobileMenu = ref(false)
const showProfileMenu = ref(false)
const profileMenuRef = ref<HTMLElement | null>(null)

const userInitial = computed(() => {
  if (!authStore.user) return '?'
  return (authStore.user.first_name?.charAt(0) || authStore.user.username?.charAt(0) || '?').toUpperCase()
})

const toggleMobileMenu = () => {
  showMobileMenu.value = !showMobileMenu.value
  showProfileMenu.value = false
}

const toggleProfileMenu = () => {
  showProfileMenu.value = !showProfileMenu.value
}

const handleLogout = async () => {
  showMobileMenu.value = false
  showProfileMenu.value = false
  await authStore.logout()
}

// Close dropdown when clicking outside
const handleClickOutside = (event: MouseEvent) => {
  if (profileMenuRef.value && !profileMenuRef.value.contains(event.target as Node)) {
    showProfileMenu.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})

// Close mobile menu when route changes
watch(() => router.currentRoute.value.path, () => {
  showMobileMenu.value = false
  showProfileMenu.value = false
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
  animation: slideDown 0.2s ease-out;
}
</style>
