export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    'vuetify-nuxt-module',
    '@pinia/nuxt',
    '@nuxtjs/color-mode',
    '@nuxtjs/supabase',
  ],
  vite: {
    resolve: {
      alias: {
        'cookie': 'cookie/dist/index.js'
      }
    }
  },
  colorMode: {
    preference: 'light',
  },
  vuetify: {
    vuetifyOptions: {
      theme: {
        themes: {
          light: {
            colors: {
              primary: '#F59E0B',
              secondary: '#0D9488',
              navy: '#1B2A4A',
              charcoal: '#2D3436',
            },
          },
          dark: {
            colors: {
              primary: '#FBBF24',
              secondary: '#2DD4BF',
              navy: '#0F172A',
              charcoal: '#1E1E1E',
            },
          },
        },
      },
    },
  },
  supabase: {
    redirectOptions: {
      login: '/login',
      callback: '/confirm',
      exclude: ['/', '/login', '/signup', '/about', '/venues/**', '/confirm', '/dashboard/**']
    },
    types: false
  },
  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
  },
})