module.exports = {
  apps: [
    {
      name: 'iran-tournament-frontend',
      script: './.output/server/index.mjs',
      instances: 1,
      exec_mode: 'fork',
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'production',
        PORT: 3000,
        NUXT_HOST: '0.0.0.0',
        NUXT_PORT: 3000,
        NUXT_PUBLIC_API_BASE: process.env.API_BASE_URL || 'http://localhost:8020/api'
      },
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true
    }
  ]
}
