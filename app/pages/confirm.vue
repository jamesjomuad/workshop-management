<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { user, updatePassword } = useAuth()
const route = useRoute()

const password = ref('')
const confirmPassword = ref('')
const errorMsg = ref('')
const loading = ref(false)
const ready = ref(false)
const isRecovery = ref(false)

watchEffect(() => {
  if (user.value) {
    const type = route.hash.match(/type=([^&]+)/)?.[1]
    isRecovery.value = type === 'recovery'
    ready.value = true
  }
})

async function handleSetPassword() {
  if (password.value !== confirmPassword.value) {
    errorMsg.value = "Passwords don't match"
    return
  }

  loading.value = true
  errorMsg.value = ''
  try {
    await updatePassword(password.value)
    await navigateTo('/dashboard')
  } catch (err: any) {
    errorMsg.value = err?.message || 'Failed to update password.'
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

      <div v-else-if="isRecovery">
        <h2 class="mb-4">Reset your password</h2>
        <p class="mb-4 text-medium-emphasis">{{ user?.email }}</p>

        <v-alert v-if="errorMsg" type="error" dense class="mb-4">{{ errorMsg }}</v-alert>

        <v-text-field v-model="password" label="New password" type="password" />
        <v-text-field v-model="confirmPassword" label="Confirm password" type="password" />

        <v-btn block color="primary" :loading="loading" @click="handleSetPassword">
          Update Password
        </v-btn>
      </div>

      <div v-else class="text-center py-6">
        <v-icon size="64" color="success" class="mb-4">mdi-email-check-outline</v-icon>
        <h2 class="mb-2">Email confirmed!</h2>
        <p class="text-medium-emphasis mb-6">Redirecting you to the dashboard...</p>
        <v-progress-circular indeterminate color="primary" size="24" />
      </div>
    </v-card>
  </v-container>
</template>