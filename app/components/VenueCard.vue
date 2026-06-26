<template>
  <v-card rounded="xl" elevation="2" class="venue-card" hover>
    <v-img
      :src="venue.image"
      :alt="venue.name"
      height="180"
      cover
      class="rounded-t-xl"
    >
      <template #placeholder>
        <div class="d-flex align-center justify-center fill-height bg-grey-lighten-2">
          <v-icon size="40" color="grey">mdi-image-outline</v-icon>
        </div>
      </template>
      <div class="d-flex pa-3" style="position: absolute; top: 0; right: 0;">
        <v-chip color="primary" size="x-small" class="font-weight-bold">
          From ${{ (venue.pricePerDay / 1000).toFixed(0) }}k/day
        </v-chip>
      </div>
    </v-img>

    <v-card-item class="pb-0">
      <v-card-title class="text-subtitle-1 font-weight-bold px-0 pt-2 pb-1">
        {{ venue.name }}
      </v-card-title>
      <div class="d-flex align-center ga-2 mb-1 px-0">
        <v-icon size="16" color="grey">mdi-hotel</v-icon>
        <span class="text-caption text-grey font-weight-medium">{{ venue.hotel }}</span>
        <v-icon size="14" color="grey-lighten-1">mdi-map-marker</v-icon>
        <span class="text-caption text-grey">{{ venue.location }}</span>
      </div>
    </v-card-item>

    <v-card-text class="px-4 pb-1 pt-1">
      <div class="d-flex align-center ga-4 mb-2">
        <div class="d-flex align-center ga-1">
          <v-icon size="16" color="primary">mdi-star</v-icon>
          <span class="text-caption font-weight-medium">{{ venue.rating }}</span>
          <span class="text-caption text-grey">({{ venue.reviewCount }})</span>
        </div>
        <div class="d-flex align-center ga-1">
          <v-icon size="14" color="grey">mdi-account-group</v-icon>
          <span class="text-caption text-grey">Up to {{ venue.capacity }}</span>
        </div>
      </div>

      <div class="d-flex flex-wrap ga-1 mb-2">
        <v-chip
          v-for="amenity in venue.amenities"
          :key="amenity"
          size="x-small"
          variant="tonal"
          color="secondary"
          label
          class="text-caption"
        >
          <v-icon start size="12">mdi-check</v-icon>
          {{ amenity }}
        </v-chip>
      </div>
    </v-card-text>

    <v-divider class="mx-4" />

    <v-card-actions class="pa-4 pt-3">
      <div class="d-flex align-center w-100">
        <div>
          <span class="text-h6 font-weight-bold" style="color: rgb(var(--v-theme-navy));">${{ venue.pricePerDay.toLocaleString() }}</span>
          <span class="text-caption text-grey"> / day</span>
        </div>
        <v-spacer />
        <v-btn color="primary" rounded="lg" size="small" class="text-none px-4" variant="flat">
          Check Availability
        </v-btn>
      </div>
    </v-card-actions>
  </v-card>
</template>

<script setup lang="ts">
import type { Venue } from '~/types'

defineProps<{
  venue: Venue
}>()
</script>

<style scoped>
.venue-card {
  transition: transform 0.25s, box-shadow 0.25s;
}

.venue-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1) !important;
}
</style>
