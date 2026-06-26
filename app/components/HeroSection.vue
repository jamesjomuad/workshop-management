<template>
  <section class="hero-section">
    <div class="hero-bg-shapes" aria-hidden="true">
      <div class="bg-circle bg-circle-1" />
      <div class="bg-circle bg-circle-2" />
    </div>
    <v-container>
      <v-row align="center" class="py-10 py-md-16">
        <v-col cols="12" md="6" class="order-last order-md-first">
          <div class="hero-text">
            <v-chip color="secondary" variant="tonal" size="small" class="mb-4 font-weight-medium" label>
              <v-icon start size="14">mdi-check-decagram</v-icon>
              Trusted by 200+ hotels &amp; venues
            </v-chip>
            <h1 class="text-h3 text-sm-h2 font-weight-bold mb-4 lh-sm" style="color: rgb(var(--v-theme-navy));">
              Book Conference Venues &amp; Workshops, Instantly
            </h1>
            <p class="text-body-1 text-medium-emphasis mb-6" style="max-width: 480px;">
              Real-time availability across hotels and event spaces — no back-and-forth emails. Find, compare, and book in minutes.
            </p>
            <div class="d-flex flex-wrap ga-3">
              <v-btn
                size="large"
                color="primary"
                rounded="lg"
                class="text-none px-6"
                href="#venues"
                variant="flat"
              >
                Find a Venue
              </v-btn>
              <v-btn
                size="large"
                variant="outlined"
                rounded="lg"
                class="text-none px-6"
                href="#hotel-cta"
              >
                List Your Hotel
              </v-btn>
            </div>
            <div class="d-flex align-center mt-6 pt-2">
              <div class="d-flex" style="margin-right: -6px;">
                <v-avatar
                  v-for="(url, i) in sampleAvatars"
                  :key="i"
                  :image="url"
                  size="32"
                  class="border"
                  style="border-width: 2px !important; margin-right: -8px;"
                />
              </div>
              <span class="text-body-2 text-grey ms-3">
                <strong class="text-primary">1,200+</strong> events booked this year
              </span>
            </div>
          </div>
        </v-col>
        <v-col cols="12" md="6" class="order-first order-md-last mb-6 mb-md-0">
          <HeroCalendarWidget />
        </v-col>
      </v-row>
    </v-container>
  </section>
</template>

<script setup lang="ts">
const sampleAvatars = [
  'https://i.pravatar.cc/40?img=11',
  'https://i.pravatar.cc/40?img=12',
  'https://i.pravatar.cc/40?img=13',
  'https://i.pravatar.cc/40?img=14',
  'https://i.pravatar.cc/40?img=15',
]
</script>

<style scoped>
.hero-section {
  position: relative;
  overflow: hidden;
}

.hero-text {
  animation: fadeSlideUp 0.8s ease forwards;
}

.lh-sm {
  line-height: 1.15;
}

.hero-bg-shapes {
  position: absolute;
  inset: 0;
  pointer-events: none;
}

.bg-circle {
  position: absolute;
  border-radius: 50%;
}

.bg-circle-1 {
  width: 600px;
  height: 600px;
  top: -200px;
  right: -100px;
  background: radial-gradient(circle, rgba(245, 158, 11, 0.08) 0%, transparent 70%);
}

.bg-circle-2 {
  width: 400px;
  height: 400px;
  bottom: -100px;
  left: -50px;
  background: radial-gradient(circle, rgba(13, 148, 136, 0.06) 0%, transparent 70%);
}

@keyframes fadeSlideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}
</style>
