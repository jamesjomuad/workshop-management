<template>
  <v-app>
    <header class="public-header">
      <v-container class="d-flex align-center">
        <div class="d-flex align-center ga-2 me-auto">
          <v-icon color="primary" size="28">mdi-domain</v-icon>
          <span class="text-h6 font-weight-bold">VenueBook</span>
        </div>
        <div class="d-none d-sm-flex align-center ga-6 me-6">
          <a v-for="link in navLinks" :key="link.label" :href="link.href" class="nav-link">{{ link.label }}</a>
        </div>
        <v-btn variant="outlined" color="primary" size="small" :to="loggedIn ? '/manage' : '/login'" class="text-none">
          {{ loggedIn ? 'Dashboard' : 'Sign In' }}
        </v-btn>
      </v-container>
    </header>
    <v-main class="landing-main">
      <slot />
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
const { loggedIn } = useAuth()

const navLinks = [
  { label: 'Venues', href: '#venues' },
  { label: 'Event Types', href: '#event-types' },
  { label: 'How It Works', href: '#how-it-works' },
  { label: 'For Hotels', href: '#hotel-cta' },
]
</script>

<style>
.public-header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 100;
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(12px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  height: 64px;
  display: flex;
  align-items: center;
}

.dark .public-header {
  background: rgba(18, 18, 18, 0.85);
  border-bottom-color: rgba(255, 255, 255, 0.06);
}

.nav-link {
  font-size: 0.9rem;
  color: rgb(var(--v-theme-on-surface));
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
  opacity: 0.75;
}

.nav-link:hover {
  opacity: 1;
  color: rgb(var(--v-theme-primary));
}

.landing-main {
  padding-top: 64px;
  background: rgb(var(--v-theme-surface));
}
</style>
