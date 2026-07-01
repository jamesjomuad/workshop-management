import { VCalendar } from 'vuetify/components/VCalendar'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component('VCalendar', VCalendar)
})
