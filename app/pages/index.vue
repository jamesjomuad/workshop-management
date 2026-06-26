<template>
  <div>
    <HeroSection />

    <v-container v-if="eventTypes.length" id="event-types">
      <AnimatedSection>
        <EventTypeGrid :event-types="eventTypes" @select="selectedEventType = $event" />
      </AnimatedSection>
    </v-container>

    <section class="bg-surface-alt">
      <v-container id="venues" class="py-12 py-md-16">
        <AnimatedSection>
          <div class="text-center mb-8">
            <h2 class="text-h4 font-weight-bold mb-2" style="color: rgb(var(--v-theme-navy));">Featured Venues</h2>
            <p class="text-body-1 text-medium-emphasis mb-6">Curated spaces for your next event</p>
            <v-text-field
              v-model="searchQuery"
              prepend-inner-icon="mdi-magnify"
              placeholder="Search by venue, hotel, or location..."
              variant="outlined"
              density="comfortable"
              hide-details
              rounded="lg"
              class="mx-auto"
              style="max-width: 480px;"
              clearable
            />
          </div>
          <v-row>
            <v-col v-for="v in filteredVenues" :key="v.id" cols="12" sm="6" lg="4">
              <VenueCard :venue="v" />
            </v-col>
          </v-row>
          <div v-if="!filteredVenues.length && !pending" class="text-center py-10">
            <v-icon size="48" color="grey-lighten-1" class="mb-3">mdi-file-search-outline</v-icon>
            <p class="text-body-1 text-grey">No venues match your search. Try a different term.</p>
          </div>
        </AnimatedSection>
      </v-container>
    </section>

    <section class="bg-surface-alt">
      <v-container>
        <AnimatedSection>
          <HowItWorks />
        </AnimatedSection>
      </v-container>
    </section>

    <v-container v-if="testimonials.length">
      <AnimatedSection>
        <TestimonialCarousel :testimonials="testimonials" />
      </AnimatedSection>
    </v-container>

    <AnimatedSection>
      <HotelCTA />
    </AnimatedSection>

    <AppFooter />
  </div>
</template>

<script setup lang="ts">
const { searchQuery, selectedEventType, filteredVenues, eventTypes, testimonials, pending } = useVenues()
</script>

<style>
.bg-surface-alt {
  background: rgba(var(--v-theme-navy), 0.02);
}
</style>
