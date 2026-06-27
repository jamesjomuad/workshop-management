<template>
  <v-list nav density="compact">
    <v-list-item
      v-for="item in items"
      :key="item.to"
      :to="item.to"
      :prepend-icon="item.icon"
      :title="item.title"
      :value="item.to"
      color="primary"
      exact
    />
  </v-list>
  <template v-if="!rail">
    <v-divider class="mt-auto" />
    <v-list density="compact">
      <v-list-item
        prepend-icon="mdi-logout"
        title="Logout"
        color="error"
        @click="handleLogout"
      />
    </v-list>
  </template>
</template>

<script setup lang="ts">
defineProps<{ rail?: boolean }>()

const { logout } = useAuth()

const items = [
  { title: 'Dashboard', icon: 'mdi-view-dashboard', to: '/dashboard' },
  { title: 'Users', icon: 'mdi-account-group', to: '/dashboard/users' },
  { title: 'Settings', icon: 'mdi-cog', to: '/dashboard/settings' },
]

async function handleLogout() {
  await logout()
}
</script>
