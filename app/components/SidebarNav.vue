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
</template>

<script setup lang="ts">
const items = [
  { title: 'Dashboard', icon: 'mdi-view-dashboard', to: '/dashboard' },
  { title: 'Users', icon: 'mdi-account-group', to: '/users' },
  { title: 'Settings', icon: 'mdi-cog', to: '/settings' },
]
</script>
