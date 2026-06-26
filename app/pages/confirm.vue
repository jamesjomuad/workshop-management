<!-- pages/confirm.vue -->
<script setup>
const supabase = useSupabaseClient()
const user = useSupabaseUser()
const password = ref('')
const confirmPassword = ref('')
const errorMsg = ref('')
const loading = ref(false)

async function setPassword() {
  if (password.value !== confirmPassword.value) {
    errorMsg.value = "Passwords don't match"
    return
  }

  loading.value = true
  const { error } = await supabase.auth.updateUser({
    password: password.value
  })
  loading.value = false

  if (error) {
    errorMsg.value = error.message
    return
  }

  navigateTo('/dashboard')
}
</script>

<template>
  <v-container class="d-flex align-center justify-center" style="height: 100vh">
    <v-card width="400" class="pa-6" rounded="lg" elevation="4">
      <h2 class="mb-4">Welcome! Set your password</h2>
      <p class="mb-4 text-medium-emphasis">{{ user?.email }}</p>

      <v-alert v-if="errorMsg" type="error" dense class="mb-4">{{ errorMsg }}</v-alert>

      <v-text-field v-model="password" label="New password" type="password" />
      <v-text-field v-model="confirmPassword" label="Confirm password" type="password" />

      <v-btn block color="primary" :loading="loading" @click="setPassword">
        Set Password & Continue
      </v-btn>
    </v-card>
  </v-container>
</template>