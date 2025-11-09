export default defineNuxtConfig({
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    '@vueuse/nuxt'
  ],
  
  devtools: { enabled: true },
  
  css: ['~/assets/css/main.css'],
  
  // مهم: غیرفعال کردن inline styles
  experimental: {
    inlineSSRStyles: false,
  },
  
  // Optimization
  nitro: {
    compressPublicAssets: true,
  },
  
  // Better hydration
  app: {
    head: {
      title: 'ایران تورنومنت',
      charset: 'utf-8',
      viewport: 'width=device-width, initial-scale=1, maximum-scale=5, user-scalable=yes',
      htmlAttrs: {
        dir: 'rtl',
        lang: 'fa'
      },
      link: [
        {
          rel: 'preconnect',
          href: 'https://cdn.jsdelivr.net'
        },
        {
          rel: 'dns-prefetch',
          href: 'https://cdn.jsdelivr.net'
        }
      ],
      // Prevent flash
      script: [
        {
          innerHTML: `
            (function() {
              const theme = localStorage.getItem('theme') || 'light';
              document.documentElement.classList.add('initial-load');
            })();
          `,
          type: 'text/javascript',
        }
      ]
    },
    
    // Page transitions
    pageTransition: {
      name: 'page',
      mode: 'out-in'
    }
  },
  
  runtimeConfig: {
    public: {
      apiBase: process.env.API_BASE_URL || 'http://localhost:8000/api'
    }
  }
})