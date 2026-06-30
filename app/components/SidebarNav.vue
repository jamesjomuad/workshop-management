<template>
  <v-list nav density="compact">
    <v-list-subheader v-if="!rail" class="text-uppercase text-caption font-weight-bold">
      Main
    </v-list-subheader>
    <v-list-item
      v-for="item in Main"
      :key="item.to"
      :to="item.to"
      :prepend-icon="item.icon"
      :title="item.title"
      :value="item.to"
      color="primary"
      exact
    />
    <v-list-subheader v-if="!rail" class="text-uppercase text-caption font-weight-bold">
      Settings
    </v-list-subheader>
    <v-list-item
      v-for="item in Settings"
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

const Main = [
  { title: 'Dashboard', icon: 'mdi-view-dashboard', to: '/manage' },
  { title: 'Workshops', icon: 'mdi-calendar-text', to: '/manage/workshops' },
  { title: 'Programs', icon: 'mdi-book-open-variant', to: '/manage/programs' },
  { title: 'Enrollments', icon: 'mdi-account-check', to: '/manage/enrollments' },
  { title: 'Venues', icon: 'mdi-door-open', to: '/manage/venues' },
  { title: 'Contacts', icon: 'mdi-contacts', to: '/manage/contacts' },
]

const Settings = [
  { title: 'Users', icon: 'mdi-account-group', to: '/manage/users' },
  { title: 'Settings', icon: 'mdi-cog', to: '/manage/settings' },
]

async function handleLogout() {
  await logout()
}
</script>
