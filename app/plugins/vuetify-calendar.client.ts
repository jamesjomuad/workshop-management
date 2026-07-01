import { VCalendar } from 'vuetify/components/VCalendar'
import { VDatePicker } from 'vuetify/components/VDatePicker'
import { VTimePicker } from 'vuetify/components/VTimePicker'

export default defineNuxtPlugin((nuxtApp) => {
  nuxtApp.vueApp.component('VCalendar', VCalendar)
  nuxtApp.vueApp.component('VDatePicker', VDatePicker)
  nuxtApp.vueApp.component('VTimePicker', VTimePicker)
})
