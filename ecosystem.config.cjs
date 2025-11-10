module.exports = {
  apps: [
    {
      name: 'iran-tournament-frontend',
      port: 3000,
      exec_mode: 'cluster',
      instances: 'max', // یا تعداد دلخواه مثل 2
      script: './.output/server/index.mjs',
      env: {
        NODE_ENV: 'production',
        NUXT_HOST: '0.0.0.0',
        NUXT_PORT: 3000,
        NUXT_PUBLIC_API_BASE: process.env.API_BASE_URL || 'http://localhost:8000/api'
      }
    }
  ]
}
