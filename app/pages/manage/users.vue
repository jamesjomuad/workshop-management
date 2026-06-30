<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Users</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ users?.length ?? 0 }} users</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus" @click="openDialog">Add User</v-btn>
    </div>

    <v-card variant="outlined" rounded="lg">
      <v-card-title class="d-flex align-center">
        <v-text-field
          v-model="search"
          prepend-inner-icon="mdi-magnify"
          label="Search users..."
          variant="outlined"
          density="comfortable"
          hide-details
          clearable
          class="ms-auto"
          style="max-width: 300px"
        />
      </v-card-title>
      <v-data-table
        :headers="headers"
        :items="users ?? []"
        :search="search"
        :loading="pending"
        item-value="id"
        density="comfortable"
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
          <div class="d-flex ga-1">
            <v-btn icon variant="text" size="small" @click="editUser(item)">
              <v-icon size="18">mdi-pencil</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" color="error" @click="deleteUser(item)">
              <v-icon size="18">mdi-delete</v-icon>
            </v-btn>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <v-dialog v-model="dialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Invite User</v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <v-form ref="formRef" @submit.prevent="handleInvite">
            <v-text-field
              v-model="email"
              label="Email address"
              type="email"
              variant="outlined"
              density="comfortable"
              hide-details="auto"
              :rules="emailRules"
              autofocus
            />
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="dialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="sending" @click="handleInvite">Send Invite</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">{{ snackbar.text }}</v-snackbar>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { users, pending, inviteUser } = useUsers()
const search = ref('')

const dialog = ref(false)
const sending = ref(false)
const email = ref('')
const formRef = ref()
const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Enter a valid email',
]
const snackbar = ref({ show: false, text: '', color: 'success' })

function openDialog() {
  email.value = ''
  dialog.value = true
  nextTick(() => formRef.value?.resetValidation())
}

async function handleInvite() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return
  sending.value = true
  try {
    await inviteUser(email.value)
    snackbar.value = { show: true, text: 'Invitation sent', color: 'success' }
    dialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    sending.value = false
  }
}

const headers = [
  { title: 'Name', key: 'name', sortable: true },
  { title: 'Email', key: 'email', sortable: true },
  { title: 'Role', key: 'role', sortable: false },
  { title: 'Status', key: 'status', sortable: false },
  { title: 'Joined', key: 'joinedAt', sortable: false },
  { title: '', key: 'actions', sortable: false, width: 96 },
]

function editUser(user: User) {
  console.log('Edit user:', user)
}

function deleteUser(user: User) {
  console.log('Delete user:', user)
}
</script>
