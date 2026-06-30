<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Users</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ users?.length ?? 0 }} users</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus" @click="openInviteDialog">Add User</v-btn>
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
        <template #item.role="{ item }">
          <v-chip :color="roleChipColor(item.role)" size="x-small" variant="tonal">
            {{ item.role }}
          </v-chip>
        </template>
        <template #item.status="{ item }">
          <v-chip
            :color="item.status === 'active' ? 'success' : 'grey'"
            size="x-small"
            variant="tonal"
          >
            {{ item.status }}
          </v-chip>
        </template>
        <template #item.actions="{ item }">
          <div class="d-flex ga-1">
            <v-btn icon variant="text" size="small" @click="openEditDialog(item)">
              <v-icon size="18">mdi-pencil</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" color="primary" @click="openResetPasswordDialog(item)">
              <v-icon size="18">mdi-key-variant</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" color="error" @click="openDeleteDialog(item)">
              <v-icon size="18">mdi-delete</v-icon>
            </v-btn>
          </div>
        </template>
      </v-data-table>
    </v-card>

    <!-- Invite Dialog -->
    <v-dialog v-model="inviteDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Invite User</v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <v-form ref="inviteFormRef" @submit.prevent="handleInvite">
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
          <v-btn variant="outlined" @click="inviteDialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="sending" @click="handleInvite">Send Invite</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Edit Dialog -->
    <v-dialog v-model="editDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Edit User</v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <v-form ref="editFormRef">
            <v-text-field
              v-model="editForm.name"
              label="Full name"
              variant="outlined"
              density="comfortable"
              hide-details="auto"
              class="mb-3"
            />
            <v-select
              v-model="editForm.role"
              :items="roleOptions"
              label="Role"
              variant="outlined"
              density="comfortable"
              hide-details="auto"
            />
          </v-form>
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="editDialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="updating" @click="handleUpdate">Save</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Reset Password Confirmation -->
    <v-dialog v-model="resetDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Reset Password</v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <p class="text-body-2">
            Send a password reset email to <strong>{{ resetTarget?.email }}</strong>?
          </p>
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="resetDialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="resetting" @click="handleResetPassword">Send</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <!-- Delete Confirmation -->
    <v-dialog v-model="deleteDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Deactivate User</v-card-title>
        <v-divider />
        <v-card-text class="pt-4">
          <p class="text-body-2">
            Are you sure you want to deactivate <strong>{{ deleteTarget?.name }}</strong>?
            They will no longer be able to log in.
          </p>
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="deleteDialog = false">Cancel</v-btn>
          <v-btn color="error" :loading="deleting" @click="handleDelete">Deactivate</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">{{ snackbar.text }}</v-snackbar>
  </div>
</template>

<script setup lang="ts">
import type { User } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { users, pending, inviteUser, updateUser, deleteUser, resetPassword } = useUsers()
const search = ref('')

// Invite
const inviteDialog = ref(false)
const sending = ref(false)
const email = ref('')
const inviteFormRef = ref()
const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Enter a valid email',
]

// Edit
const editDialog = ref(false)
const updating = ref(false)
const editFormRef = ref()
const editForm = reactive({ name: '', role: '' })
const editTarget = ref<User | null>(null)

// Delete
const deleteDialog = ref(false)
const deleting = ref(false)
const deleteTarget = ref<User | null>(null)

// Reset password
const resetDialog = ref(false)
const resetting = ref(false)
const resetTarget = ref<User | null>(null)

const snackbar = ref({ show: false, text: '', color: 'success' })

const roleOptions = ['admin', 'staff', 'trainer', 'facilitator', 'trainee', 'client', 'organizer']

function roleChipColor(role: string) {
  const map: Record<string, string> = {
    admin: 'error',
    staff: 'warning',
    trainer: 'primary',
    facilitator: 'info',
    trainee: 'success',
    client: 'grey',
    organizer: 'indigo',
  }
  return map[role] || 'grey'
}

// ---- Invite ----
function openInviteDialog() {
  email.value = ''
  inviteDialog.value = true
  nextTick(() => inviteFormRef.value?.resetValidation())
}

async function handleInvite() {
  const { valid } = await inviteFormRef.value?.validate() ?? { valid: false }
  if (!valid) return
  sending.value = true
  try {
    await inviteUser(email.value)
    snackbar.value = { show: true, text: 'Invitation sent', color: 'success' }
    inviteDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    sending.value = false
  }
}

// ---- Edit ----
function openEditDialog(user: User) {
  editTarget.value = user
  editForm.name = user.name
  editForm.role = user.role
  editDialog.value = true
  nextTick(() => editFormRef.value?.resetValidation())
}

async function handleUpdate() {
  if (!editTarget.value) return
  updating.value = true
  try {
    await updateUser(editTarget.value.id, {
      name: editForm.name,
      role: editForm.role,
    })
    snackbar.value = { show: true, text: 'User updated', color: 'success' }
    editDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    updating.value = false
  }
}

// ---- Delete ----
function openDeleteDialog(user: User) {
  deleteTarget.value = user
  deleteDialog.value = true
}

async function handleDelete() {
  if (!deleteTarget.value) return
  deleting.value = true
  try {
    await deleteUser(deleteTarget.value.id)
    snackbar.value = { show: true, text: 'User deactivated', color: 'success' }
    deleteDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    deleting.value = false
  }
}

// ---- Reset Password ----
function openResetPasswordDialog(user: User) {
  resetTarget.value = user
  resetDialog.value = true
}

async function handleResetPassword() {
  if (!resetTarget.value) return
  resetting.value = true
  try {
    await resetPassword(resetTarget.value.id)
    snackbar.value = { show: true, text: `Password reset email sent to ${resetTarget.value.email}`, color: 'success' }
    resetDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    resetting.value = false
  }
}

const headers = [
  { title: 'Name', key: 'name', sortable: true },
  { title: 'Email', key: 'email', sortable: true },
  { title: 'Role', key: 'role', sortable: false },
  { title: 'Status', key: 'status', sortable: false },
  { title: 'Joined', key: 'joinedAt', sortable: false },
  { title: '', key: 'actions', sortable: false, width: 128 },
]
</script>
