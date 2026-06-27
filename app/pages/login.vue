<template>
  <v-row no-gutters class="fill-height">
    <v-col cols="12" md="5" class="brand-panel position-relative overflow-hidden d-none d-md-flex flex-column align-center justify-center pa-8">
      <div class="brand-shapes" aria-hidden="true">
        <div class="shape shape-1" />
        <div class="shape shape-2" />
        <div class="shape shape-3" />
        <div class="shape shape-4" />
      </div>
      <div class="brand-content text-center position-relative">
        <div class="d-flex align-center justify-center mb-4">
          <v-icon size="52" color="white">mdi-view-dashboard-outline</v-icon>
        </div>
        <h1 class="text-h3 font-weight-bold text-white mb-3">AdminPro</h1>
        <p class="text-body-1 text-white text-medium-emphasis" style="max-width: 340px;">
          Powerful analytics &amp; management dashboard for your growing business.
        </p>
      </div>
      <div class="position-relative mt-auto">
        <p class="text-caption text-white text-medium-emphasis">&copy; 2026 AdminPro. All rights reserved.</p>
      </div>
    </v-col>

    <v-col cols="12" md="7" class="d-flex align-center justify-center form-panel pa-4 pa-md-8">
      <div :class="['form-wrapper', 'w-100', { visible: showForm }]" style="max-width: 420px;">
        <div class="text-center text-md-start mb-6">
          <h1 class="text-h4 font-weight-bold mb-1">Welcome back</h1>
          <p class="text-body-2 text-grey">Sign in to your account to continue</p>
        </div>

        <v-form ref="formRef" @submit.prevent="handleLogin">
          <v-text-field
            v-model="email"
            label="Email address"
            type="email"
            prepend-inner-icon="mdi-email-outline"
            :rules="emailRules"
            variant="outlined"
            density="comfortable"
            class="mb-2"
            autocomplete="email"
          />

          <v-text-field
            v-model="password"
            label="Password"
            :type="showPassword ? 'text' : 'password'"
            prepend-inner-icon="mdi-lock-outline"
            :append-inner-icon="showPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="showPassword = !showPassword"
            :rules="requiredRules"
            variant="outlined"
            density="comfortable"
            class="mb-2"
            autocomplete="current-password"
          />

          <div class="d-flex align-center justify-end mb-4">
            <a
              href="#"
              class="text-caption text-primary font-weight-medium text-decoration-none"
              @click.prevent="handleForgotPassword"
              :disabled="resetting"
            >{{ resetting ? 'Sending...' : 'Forgot password?' }}</a>
          </div>

          <v-alert v-if="success" type="success" density="compact" dismissible class="mb-4" @click:close="success = ''">
            {{ success }}
          </v-alert>

          <v-alert v-if="error" type="error" density="compact" dismissible class="mb-4" @click:close="error = ''">
            {{ error }}
          </v-alert>

          <v-btn
            type="submit"
            color="primary"
            size="large"
            block
            rounded="lg"
            :loading="loading"
            class="submit-btn"
          >
            Sign In
          </v-btn>
        </v-form>

        <p class="text-center text-body-2 text-grey mt-6">
          Don't have an account?
          <NuxtLink to="/signup" class="text-primary font-weight-medium text-decoration-none">Sign up</NuxtLink>
        </p>
      </div>
    </v-col>
  </v-row>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'default' })

const { user, login, resetPassword } = useAuth()

const email = ref('')
const password = ref('')
const error = ref('')
const success = ref('')
const loading = ref(false)
const resetting = ref(false)
const showPassword = ref(false)
const showForm = ref(true)
const formRef = ref<VForm>()

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Enter a valid email',
]
const requiredRules = [(v: string) => !!v || 'Password is required']

if (user.value) {
  await navigateTo('/manage')
}

async function handleLogin() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  loading.value = true
  error.value = ''
  success.value = ''
  try {
    await login({ email: email.value, password: password.value })
    await navigateTo('/manage')
  } catch (err: any) {
    error.value = err?.message || 'Invalid email or password. Please try again.'
  } finally {
    loading.value = false
  }
}

async function handleForgotPassword() {
  if (!email.value) {
    error.value = 'Enter your email address first.'
    return
  }

  resetting.value = true
  error.value = ''
  success.value = ''
  try {
    await resetPassword(email.value)
    success.value = 'Check your email for a password reset link.'
  } catch (err: any) {
    error.value = err?.message || 'Failed to send reset email.'
  } finally {
    resetting.value = false
  }
}
</script>

<style scoped>
.fill-height {
  min-height: 100vh;
}

.brand-panel {
  background: linear-gradient(135deg, #F59E0B 0%, #D97706 50%, #B45309 100%);
}

.form-panel {
  background: rgb(var(--v-theme-surface));
}

.form-wrapper {
  opacity: 0;
  transform: translateY(20px);
  transition: opacity 0.5s ease, transform 0.5s ease;
}

.form-wrapper.visible {
  opacity: 1;
  transform: translateY(0);
}

.submit-btn {
  transition: transform 0.2s, box-shadow 0.2s;
}

.submit-btn:hover:not(:disabled) {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(var(--v-theme-primary), 0.4);
}

.brand-shapes {
  position: absolute;
  inset: 0;
  overflow: hidden;
  pointer-events: none;
}

.shape {
  position: absolute;
  border-radius: 50%;
  opacity: 0.1;
  background: white;
}

.shape-1 {
  width: 500px;
  height: 500px;
  top: -150px;
  right: -100px;
  animation: float 12s ease-in-out infinite;
}

.shape-2 {
  width: 300px;
  height: 300px;
  bottom: -80px;
  left: -80px;
  animation: float 16s ease-in-out infinite reverse;
}

.shape-3 {
  width: 200px;
  height: 200px;
  top: 40%;
  left: 15%;
  background: none;
  border: 2px solid rgba(255, 255, 255, 0.15);
  animation: float 10s ease-in-out infinite 2s;
}

.shape-4 {
  width: 120px;
  height: 120px;
  top: 20%;
  right: 20%;
  background: none;
  border: 2px solid rgba(255, 255, 255, 0.12);
  border-radius: 20px;
  transform: rotate(45deg);
  animation: float 14s ease-in-out infinite 1s;
}

@keyframes float {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  33% { transform: translateY(-20px) rotate(1deg); }
  66% { transform: translateY(10px) rotate(-1deg); }
}

:deep(.v-field--variant-outlined .v-field__outline__start) {
  border-radius: 12px 0 0 12px;
}

:deep(.v-field--variant-outlined .v-field__outline__end) {
  border-radius: 0 12px 12px 0;
}
</style>
