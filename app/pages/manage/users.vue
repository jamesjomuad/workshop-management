<template>
  <div>
    <v-card elevation="2" rounded="lg">
      <v-card-title class="d-flex align-center">
        <span class="text-h6">Users</span>
        <v-spacer />
        <v-text-field
          v-model="search"
          prepend-inner-icon="mdi-magnify"
          label="Search"
          density="compact"
          hide-details
          class="ms-auto"
          style="max-width: 300px"
        />
      </v-card-title>
      <v-data-table
        :headers="headers"
        :items="users ?? []"
        :search="search"
        :loading="pending"
        :items-per-page="10"
        sortable
        class="pa-2"
      >
        <template #item.status="{ item }">
          <v-chip
            :color="item.status === 'active' ? 'success' : 'grey'"
            size="small"
            variant="tonal"
          >
            {{ item.status }}
          </v-chip>
        </template>
        <template #item.actions="{ item }">
          <v-icon class="me-2" color="primary" size="small" @click="editUser(item)">mdi-pencil</v-icon>
          <v-icon color="error" size="small" @click="deleteUser(item)">mdi-delete</v-icon>
        </template>
      </v-data-table>
    </v-card>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { users, pending } = useUsers()
const search = ref('')

const headers = [
  { title: 'Name', key: 'name', sortable: true },
  { title: 'Email', key: 'email', sortable: true },
  { title: 'Role', key: 'role', sortable: true },
  { title: 'Status', key: 'status', sortable: true },
  { title: 'Joined', key: 'joinedAt', sortable: true },
  { title: 'Actions', key: 'actions', sortable: false },
]

function editUser(user: User) {
  console.log('Edit user:', user)
}

function deleteUser(user: User) {
  console.log('Delete user:', user)
}
</script>
