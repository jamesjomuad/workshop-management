<template>
  <v-container class="fill-height d-flex align-center justify-center">
    <v-card class="pa-6" width="400" elevation="4" rounded="lg">
      <v-card-title class="text-h5 text-center mb-4">Sign In</v-card-title>
      <v-card-text>
        <v-form ref="formRef" @submit.prevent="handleLogin">
          <v-text-field
            v-model="email"
            label="Email"
            type="email"
            prepend-inner-icon="mdi-email"
            :rules="emailRules"
            required
          />
          <v-text-field
            v-model="password"
            label="Password"
            type="password"
            prepend-inner-icon="mdi-lock"
            :rules="requiredRules"
            required
          />
          <v-alert v-if="error" type="error" density="compact" class="mb-3">{{ error }}</v-alert>
          <v-btn type="submit" color="primary" block :loading="loading">Sign In</v-btn>
        </v-form>
      </v-card-text>
      <v-card-text class="text-caption text-center text-grey">
        Demo: admin@example.com / password
      </v-card-text>
    </v-card>
  </v-container>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { login, loggedIn } = useAuth()
const router = useRouter()

const email = ref('')
const password = ref('')
const error = ref('')
const loading = ref(false)
const formRef = ref()

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Email must be valid',
]
const requiredRules = [(v: string) => !!v || 'Required']

if (loggedIn.value) {
  await router.push('/dashboard')
}

async function handleLogin() {
  const { valid } = await formRef.value?.validate()
  if (!valid) return

  loading.value = true
  error.value = ''
  try {
    await login({ email: email.value, password: password.value })
    await router.push('/dashboard')
  } catch {
    error.value = 'Invalid email or password'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.fill-height {
  min-height: 100vh;
}
</style>
