<template>
  <footer class="landing-footer">
    <v-divider />
    <v-container class="py-8 py-md-10">
      <v-row>
        <v-col cols="12" md="4" class="mb-6 mb-md-0">
          <div class="d-flex align-center ga-2 mb-3">
            <v-icon color="primary" size="28">mdi-domain</v-icon>
            <span class="text-h6 font-weight-bold">VenueBook</span>
          </div>
          <p class="text-body-2 text-medium-emphasis mb-4" style="max-width: 280px;">
            The leading platform for booking hotel conference rooms, meeting spaces, and workshop venues. Trusted by event planners and hotels worldwide.
          </p>
          <div class="d-flex ga-2">
            <v-btn
              v-for="social in socials"
              :key="social.icon"
              :icon="social.icon"
              variant="text"
              density="compact"
              size="small"
              :href="social.href"
              color="grey"
            />
          </div>
        </v-col>
        <v-col cols="6" md="2" v-for="group in footerLinks" :key="group.title">
          <div class="text-subtitle-2 font-weight-bold mb-3" style="color: rgb(var(--v-theme-navy));">{{ group.title }}</div>
          <div class="d-flex flex-column ga-2">
            <a v-for="link in group.links" :key="link.label" :href="link.href" class="footer-link">
              {{ link.label }}
            </a>
          </div>
        </v-col>
        <v-col cols="12" md="4">
          <div class="text-subtitle-2 font-weight-bold mb-3" style="color: rgb(var(--v-theme-navy));">Stay Updated</div>
          <p class="text-body-2 text-medium-emphasis mb-3">Get venue recommendations and industry insights delivered weekly.</p>
          <v-form @submit.prevent>
            <v-text-field
              v-model="email"
              placeholder="Enter your email"
              variant="outlined"
              density="compact"
              hide-details
              append-inner-icon="mdi-send"
              @click:append-inner="subscribe"
              class="newsletter-input"
            />
          </v-form>
        </v-col>
      </v-row>
      <v-divider class="my-6" />
      <div class="d-flex flex-wrap align-center justify-center justify-sm-space-between ga-2">
        <span class="text-caption text-medium-emphasis">&copy; {{ new Date().getFullYear() }} VenueBook. All rights reserved.</span>
        <div class="d-flex ga-4">
          <a href="#" class="text-caption footer-link">Privacy Policy</a>
          <a href="#" class="text-caption footer-link">Terms of Service</a>
        </div>
      </div>
    </v-container>
  </footer>
</template>

<script setup lang="ts">
const email = ref('')

const socials = [
  { icon: 'mdi-linkedin', href: '#' },
  { icon: 'mdi-twitter', href: '#' },
  { icon: 'mdi-facebook', href: '#' },
  { icon: 'mdi-instagram', href: '#' },
]

const footerLinks = [
  {
    title: 'Venues',
    links: [
      { label: 'Browse All Venues', href: '#venues' },
      { label: 'Event Types', href: '#event-types' },
      { label: 'Popular Cities', href: '#' },
      { label: 'Case Studies', href: '#' },
    ],
  },
  {
    title: 'For Hotels',
    links: [
      { label: 'List Your Venue', href: '#hotel-cta' },
      { label: 'Host Dashboard', href: '#' },
      { label: 'Pricing', href: '#' },
      { label: 'Success Stories', href: '#' },
    ],
  },
  {
    title: 'Support',
    links: [
      { label: 'Help Center', href: '#' },
      { label: 'Contact Us', href: '#' },
      { label: 'About Us', href: '#' },
      { label: 'FAQ', href: '#' },
    ],
  },
]

function subscribe() {
  if (email.value) {
    console.log('Subscribed:', email.value)
    email.value = ''
  }
}
</script>

<style scoped>
.landing-footer {
  background: rgb(var(--v-theme-surface));
}

.footer-link {
  color: rgba(var(--v-theme-on-surface), 0.6);
  text-decoration: none;
  font-size: 0.85rem;
  transition: color 0.2s;
}

.footer-link:hover {
  color: rgb(var(--v-theme-primary));
}

.newsletter-input {
  max-width: 320px;
}
</style>
