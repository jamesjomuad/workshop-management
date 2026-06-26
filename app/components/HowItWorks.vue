<template>
  <section id="how-it-works" class="py-12 py-md-16">
    <v-container>
      <div class="text-center mb-10">
        <h2 class="text-h4 font-weight-bold mb-2" style="color: rgb(var(--v-theme-navy));">How It Works</h2>
        <p class="text-body-1 text-medium-emphasis">Book your ideal venue in three simple steps</p>
      </div>
      <v-row>
        <v-col v-for="(step, i) in steps" :key="i" cols="12" md="4">
          <div class="step-card text-center pa-6">
            <div class="step-icon-wrapper mb-4">
              <div class="step-icon">
                <v-icon size="36" color="primary">{{ step.icon }}</v-icon>
              </div>
              <div class="step-number">{{ i + 1 }}</div>
            </div>
            <h3 class="text-h6 font-weight-bold mb-2">{{ step.title }}</h3>
            <p class="text-body-2 text-medium-emphasis">{{ step.description }}</p>
          </div>
        </v-col>
      </v-row>
    </v-container>
  </section>
</template>

<script setup lang="ts">
const steps = [
  {
    icon: 'mdi-calendar-search',
    title: 'Search by Date & Capacity',
    description: 'Enter your event date, guest count, and requirements. Browse real-time availability across hundreds of hotel venues.',
  },
  {
    icon: 'mdi-compare-horizontal',
    title: 'Compare Venues',
    description: 'Side-by-side comparison of amenities, pricing, capacity, and reviews. Filter by location, budget, and event type.',
  },
  {
    icon: 'mdi-check-decagram',
    title: 'Book & Get Instant Confirmation',
    description: 'Secure your booking with instant confirmation. Modify or cancel up to 48 hours before — no hidden fees.',
  },
]

</script>

<style scoped>
.step-card {
  transition: transform 0.25s;
}

.step-card:hover {
  transform: translateY(-4px);
}

.step-icon-wrapper {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.step-icon {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  background: rgba(var(--v-theme-primary), 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}

.step-number {
  position: absolute;
  top: -4px;
  right: -4px;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  background: rgb(var(--v-theme-primary));
  color: white;
  font-size: 0.8rem;
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
