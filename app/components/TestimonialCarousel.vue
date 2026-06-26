<template>
  <section class="py-12 py-md-16">
    <v-container>
      <div class="text-center mb-8">
        <h2 class="text-h4 font-weight-bold mb-2" style="color: rgb(var(--v-theme-navy));">Trusted by Event Planners &amp; Hotels</h2>
        <p class="text-body-1 text-medium-emphasis">Hear from professionals who use VenueBook every day</p>
      </div>
      <v-carousel
        :items="testimonials"
        hide-delimiter-background
        show-arrows="hover"
        cycle
        interval="5000"
        height="auto"
        class="testimonial-carousel"
      >
        <template #item="{ item }">
          <div class="pa-2 pa-md-6">
            <v-card rounded="xl" elevation="2" class="pa-6 pa-md-8 mx-auto" style="max-width: 640px;">
              <div class="d-flex align-center ga-1 mb-4">
                <v-icon v-for="n in 5" :key="n" size="18" :color="n <= item.raw.rating ? 'primary' : 'grey-lighten-2'">
                  mdi-star
                </v-icon>
              </div>
              <p class="text-body-1 mb-6" style="line-height: 1.7;">&ldquo;{{ item.raw.quote }}&rdquo;</p>
              <div class="d-flex align-center ga-3">
                <v-avatar size="44" :image="item.raw.avatar" />
                <div>
                  <div class="text-subtitle-2 font-weight-bold">{{ item.raw.name }}</div>
                  <div class="text-caption text-grey">{{ item.raw.title }}, {{ item.raw.company }}</div>
                </div>
              </div>
            </v-card>
          </div>
        </template>
      </v-carousel>
    </v-container>
  </section>
</template>

<script setup lang="ts">
import type { Testimonial } from '~/types'

defineProps<{
  testimonials: Testimonial[]
}>()
</script>

<style scoped>
.testimonial-carousel {
  box-shadow: none;
  background: transparent;
}

:deep(.v-carousel__controls) {
  background: transparent;
}

:deep(.v-carousel__controls__item) {
  margin: 0 2px;
}

:deep(.v-window__container) {
  min-height: 280px;
}
</style>
