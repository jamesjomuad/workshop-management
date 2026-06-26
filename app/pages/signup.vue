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
      <div v-if="success" class="form-wrapper w-100" style="max-width: 420px;">
        <div class="text-center">
          <v-icon size="64" color="success" class="mb-4">mdi-email-check-outline</v-icon>
          <h1 class="text-h4 font-weight-bold mb-2">Check your email</h1>
          <p class="text-body-2 text-grey mb-6">
            We sent a confirmation link to <strong>{{ email }}</strong>.<br>
            Click the link to activate your account.
          </p>
          <v-btn
            color="primary"
            size="large"
            block
            rounded="lg"
            variant="outlined"
            class="text-none"
            @click="navigateTo('/login')"
          >
            Back to Sign In
          </v-btn>
        </div>
      </div>

      <div v-else class="form-wrapper w-100" style="max-width: 420px;">
        <div class="text-center text-md-start mb-6">
          <h1 class="text-h4 font-weight-bold mb-1">Create an account</h1>
          <p class="text-body-2 text-grey">Get started with your free account</p>
        </div>

        <v-form ref="formRef" @submit.prevent="handleSignup">
          <v-text-field
            v-model="fullName"
            label="Full name"
            type="text"
            prepend-inner-icon="mdi-account-outline"
            :rules="nameRules"
            variant="outlined"
            density="comfortable"
            class="mb-2"
            autocomplete="name"
          />

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
            :rules="passwordRules"
            variant="outlined"
            density="comfortable"
            class="mb-1"
            autocomplete="new-password"
          />

          <div class="d-flex flex-wrap ga-2 mb-2">
            <v-chip
              v-for="rule in passwordHints"
              :key="rule.label"
              size="x-small"
              :color="rule.passed ? 'success' : 'default'"
              :variant="rule.passed ? 'tonal' : 'outlined'"
              label
              class="text-caption"
            >
              <v-icon start size="12">{{ rule.passed ? 'mdi-check-circle' : 'mdi-circle-outline' }}</v-icon>
              {{ rule.label }}
            </v-chip>
          </div>

          <v-text-field
            v-model="confirmPassword"
            label="Confirm password"
            :type="showConfirmPassword ? 'text' : 'password'"
            prepend-inner-icon="mdi-lock-outline"
            :append-inner-icon="showConfirmPassword ? 'mdi-eye-off' : 'mdi-eye'"
            @click:append-inner="showConfirmPassword = !showConfirmPassword"
            :rules="confirmRules"
            variant="outlined"
            density="comfortable"
            class="mb-2"
            autocomplete="new-password"
          />

          <v-checkbox
            v-model="agreedToTerms"
            :rules="[(v: boolean) => !!v || 'You must agree to continue']"
            density="compact"
            color="primary"
            class="mb-2"
            hide-details="auto"
          >
            <template #label>
              <span class="text-caption text-grey">
                I agree to the
                <a href="#" class="text-primary font-weight-medium text-decoration-none">Terms of Service</a>
                and
                <a href="#" class="text-primary font-weight-medium text-decoration-none">Privacy Policy</a>
              </span>
            </template>
          </v-checkbox>

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
            Create Account
          </v-btn>
        </v-form>

        <p class="text-center text-body-2 text-grey mt-6">
          Already have an account?
          <NuxtLink to="/login" class="text-primary font-weight-medium text-decoration-none">Log in</NuxtLink>
        </p>
      </div>
    </v-col>
  </v-row>
</template>

<script setup lang="ts">
import type { VForm } from 'vuetify/components'

definePageMeta({ layout: 'default' })

const { signUp, user } = useAuth()

const fullName = ref('')
const email = ref('')
const password = ref('')
const confirmPassword = ref('')
const agreedToTerms = ref(false)
const error = ref('')
const loading = ref(false)
const success = ref(false)
const showPassword = ref(false)
const showConfirmPassword = ref(false)
const formRef = ref<VForm>()

if (user.value) {
  await navigateTo('/dashboard')
}

const nameRules = [
  (v: string) => !!v?.trim() || 'Name is required',
  (v: string) => v?.trim().length >= 2 || 'Name must be at least 2 characters',
]

const emailRules = [
  (v: string) => !!v || 'Email is required',
  (v: string) => /.+@.+/.test(v) || 'Enter a valid email',
]

const passwordRules = [
  (v: string) => !!v || 'Password is required',
]

const passwordHints = computed(() => [
  { label: 'At least 8 characters', passed: password.value.length >= 8 },
  { label: 'Contains a number', passed: /\d/.test(password.value) },
  { label: 'Contains a letter', passed: /[a-zA-Z]/.test(password.value) },
])

const confirmRules = [
  (v: string) => !!v || 'Please confirm your password',
  (v: string) => v === password.value || 'Passwords do not match',
]

async function handleSignup() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  loading.value = true
  error.value = ''
  try {
    const data = await signUp(email.value, password.value, { full_name: fullName.value.trim() })
    if (data?.session) {
      await navigateTo('/dashboard')
    } else {
      success.value = true
    }
  } catch (err: any) {
    error.value = err?.message || 'Signup failed. Please try again.'
  } finally {
    loading.value = false
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
