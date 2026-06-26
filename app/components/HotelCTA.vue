<template>
  <section id="hotel-cta" class="py-12 py-md-16">
    <v-container>
      <v-card rounded="xl" elevation="0" class="hotel-cta-card pa-8 pa-md-12">
        <v-row align="center" justify="center">
          <v-col cols="12" md="8" class="text-center">
            <h2 class="text-h3 text-sm-h2 font-weight-bold text-white mb-3">
              List Your Venues &amp; Fill Empty Calendars
            </h2>
            <p class="text-body-1 text-white text-medium-emphasis mb-6" style="max-width: 600px; margin: 0 auto;">
              List your conference rooms and workshop spaces on our platform. Reach corporate clients actively searching for venues — we handle bookings, payments, and scheduling.
            </p>
            <div class="d-flex flex-wrap align-center justify-center ga-6 mb-6">
              <div class="text-center">
                <div class="text-h4 font-weight-bold text-white">30%</div>
                <div class="text-caption text-white text-medium-emphasis">Higher Occupancy</div>
              </div>
              <div class="text-center">
                <div class="text-h4 font-weight-bold text-white">500+</div>
                <div class="text-caption text-white text-medium-emphasis">Hotels Listed</div>
              </div>
              <div class="text-center">
                <div class="text-h4 font-weight-bold text-white">4.8★</div>
                <div class="text-caption text-white text-medium-emphasis">Host Satisfaction</div>
              </div>
            </div>
            <v-btn
              size="x-large"
              color="primary"
              rounded="lg"
              class="text-none px-8 hotel-cta-btn"
              variant="flat"
            >
              List Your Venue
              <v-icon end>mdi-arrow-right</v-icon>
            </v-btn>
            <p class="text-caption text-white text-medium-emphasis mt-3">No commitment required. List your first space for free.</p>
          </v-col>
        </v-row>
      </v-card>
    </v-container>
  </section>
</template>

<style scoped>
.hotel-cta-card {
  background: linear-gradient(135deg, rgb(var(--v-theme-navy)) 0%, #1a2a4a 50%, #0f1a30 100%);
  border: none;
}

.hotel-cta-btn {
  transition: transform 0.2s, box-shadow 0.2s;
}

.hotel-cta-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.2);
}
</style>
