<template>
  <v-app>
    <AppHeader :title="pageTitle" @toggle-drawer="drawer = !drawer" />
    <v-navigation-drawer
      v-model="drawer"
      :temporary="isMobile"
      :rail="rail && !isMobile"
      app
      z-index="1004"
      @click="rail = false"
    >
      <template #prepend>
        <v-list-item
          class="pa-4"
          title="Dashboard"
          subtitle="Workshop"
          prepend-icon="mdi-shield-crown"
        />
        <v-divider />
      </template>
      <SidebarNav :rail="rail && !isMobile" />
      <template #append>
        <v-divider />
        <v-list-item
          prepend-icon="mdi-chevron-left"
          title="Collapse"
          @click="rail = !rail"
        />
      </template>
    </v-navigation-drawer>
    <v-main>
      <v-container fluid class="pa-6">
        <slot />
      </v-container>
    </v-main>
  </v-app>
</template>

<script setup lang="ts">
const route = useRoute()

const drawer = ref(true)
const rail = ref(false)
const width = ref(typeof window !== 'undefined' ? window.innerWidth : 960)
const isMobile = computed(() => width.value < 960)

function onResize() {
  width.value = window.innerWidth
}
onMounted(() => window.addEventListener('resize', onResize))
onUnmounted(() => window.removeEventListener('resize', onResize))

const pageTitle = computed(() => {
  const map: Record<string, string> = {
    '/manage': 'Dashboard',
    '/manage/users': 'Users',
    '/manage/settings': 'Settings',
    '/manage/venues': 'Venues',
    '/manage/workshops': 'Workshops',
    '/manage/programs': 'Programs & Sessions',
    '/manage/enrollments': 'Enrollments & Attendance',
    '/manage/contacts': 'Contacts',
  }
  return map[route.path] || 'Admin'
})
</script>

<style>
.page-enter-active,
.page-leave-active {
  transition: opacity 0.2s ease;
}
.page-enter-from,
.page-leave-to {
  opacity: 0;
}
</style>
