export default defineNuxtConfig({
  compatibilityDate: '2025-07-15',
  devtools: { enabled: true },
  modules: [
    'nuxt-auth-utils',
    'vuetify-nuxt-module',
    '@pinia/nuxt',
    '@nuxtjs/color-mode',
  ],
  colorMode: {
    preference: 'light',
  },
  app: {
    pageTransition: { name: 'page', mode: 'out-in' },
  },
})