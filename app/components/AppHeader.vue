<template>
  <v-app-bar flat>
    <v-app-bar-nav-icon @click="$emit('toggle-drawer')" />
    <v-app-bar-title>{{ title }}</v-app-bar-title>
    <v-spacer />
    <v-btn icon @click="toggleTheme">
      <v-icon>{{ themeIcon }}</v-icon>
    </v-btn>
    <v-btn icon>
      <v-icon>mdi-bell</v-icon>
      <v-badge dot color="error" />
    </v-btn>
    <v-menu>
      <template #activator="{ props }">
        <v-btn icon v-bind="props">
          <v-avatar color="primary" size="small">
            <v-icon color="white">mdi-account</v-icon>
          </v-avatar>
        </v-btn>
      </template>
      <v-list density="compact">
        <v-list-item title="Profile" prepend-icon="mdi-account-circle" />
        <v-list-item title="Logout" prepend-icon="mdi-logout" @click="handleLogout" />
      </v-list>
    </v-menu>
  </v-app-bar>
</template>

<script setup lang="ts">
defineProps<{ title: string }>()
defineEmits<{ 'toggle-drawer': [] }>()

const { logout } = useAuth()

const colorMode = useColorMode()
const isDark = computed(() => colorMode.value === 'dark')
const themeIcon = computed(() => isDark.value ? 'mdi-weather-sunny' : 'mdi-weather-night')

function toggleTheme() {
  colorMode.value = isDark.value ? 'light' : 'dark'
}

async function handleLogout() {
  await logout()
  await navigateTo('/login')
}
</script>
