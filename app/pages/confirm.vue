<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { user, updatePassword } = useAuth()
const router = useRouter()

const password = ref('')
const confirmPassword = ref('')
const errorMsg = ref('')
const loading = ref(false)

const ready = computed(() => user.value !== null)

async function handleSetPassword() {
  if (password.value !== confirmPassword.value) {
    errorMsg.value = "Passwords don't match"
    return
  }
  if (password.value.length < 8) {
    errorMsg.value = 'Password must be at least 8 characters'
    return
  }

  loading.value = true
  errorMsg.value = ''
  try {
    await updatePassword(password.value)
    await router.push('/manage')
  } catch (err: any) {
    errorMsg.value = err?.message || 'Failed to set password.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <v-container class="d-flex align-center justify-center" style="height: 100vh">
    <v-card width="400" class="pa-6" rounded="lg" elevation="4">
      <div v-if="!ready" class="text-center py-6">
        <v-progress-circular indeterminate color="primary" size="48" />
        <p class="mt-4 text-medium-emphasis">Verifying your email...</p>
      </div>

      <div v-else class="text-center py-6">
        <v-icon size="64" color="success" class="mb-4">mdi-email-check-outline</v-icon>
        <h2 class="mb-1">Email confirmed!</h2>
        <p class="text-medium-emphasis mb-6">Set your password to continue.</p>

        <v-alert v-if="errorMsg" type="error" density="compact" class="mb-4">{{ errorMsg }}</v-alert>

        <v-text-field
          v-model="password"
          label="Password"
          type="password"
          variant="outlined"
          density="comfortable"
          class="mb-3"
          autocomplete="new-password"
        />
        <v-text-field
          v-model="confirmPassword"
          label="Confirm password"
          type="password"
          variant="outlined"
          density="comfortable"
          class="mb-4"
          autocomplete="new-password"
        />

        <v-btn block color="primary" size="large" :loading="loading" @click="handleSetPassword">
          Set Password
        </v-btn>
      </div>
    </v-card>
  </v-container>
</template>
