<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" to="/manage/contacts" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">New Company</h1>
      <v-spacer />
      <v-btn color="primary" :loading="saving" @click="save">Create company</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-form ref="formRef">
          <!-- Core Identity -->
          <v-card variant="outlined" rounded="lg" class="mb-4">
            <v-card-item>
              <template #prepend>
                <v-icon color="primary" class="me-2">mdi-domain</v-icon>
                <div>
                  <v-card-title class="text-body-1 font-weight-bold">Core Identity</v-card-title>
                  <v-card-subtitle>Basic company information</v-card-subtitle>
                </div>
              </template>
            </v-card-item>
            <v-divider />
            <v-card-text class="d-flex flex-column ga-4">
              <v-text-field
                v-model="form.name"
                name="name"
                label="Company name *"
                :rules="required"
                variant="outlined"
                density="comfortable"
                hide-details="auto"
              />
              <v-text-field
                v-model="form.slug"
                name="slug"
                label="Slug (URL-friendly)"
                variant="outlined"
                density="comfortable"
                hide-details
                hint="Auto-generated from name if left empty"
              />
              <v-select
                v-model="form.status"
                :items="statusOptions"
                label="Status"
                variant="outlined"
                density="comfortable"
                hide-details
              />
            </v-card-text>
          </v-card>

          <!-- Contact Info -->
          <v-card variant="outlined" rounded="lg" class="mb-4">
            <v-card-item>
              <template #prepend>
                <v-icon color="secondary" class="me-2">mdi-phone</v-icon>
                <div>
                  <v-card-title class="text-body-1 font-weight-bold">Contact Info</v-card-title>
                  <v-card-subtitle>How to reach this company</v-card-subtitle>
                </div>
              </template>
            </v-card-item>
            <v-divider />
            <v-card-text class="d-flex flex-column ga-4">
              <v-text-field
                v-model="form.contact_email"
                name="email"
                label="Email"
                type="email"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-text-field
                v-model="form.contact_phone"
                name="phone"
                label="Phone"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-text-field
                v-model="form.website"
                name="website"
                label="Website"
                variant="outlined"
                density="comfortable"
                hide-details
                hint="https://..."
              />
              <v-textarea
                v-model="form.address"
                name="address"
                label="Address"
                variant="outlined"
                density="comfortable"
                hide-details
                rows="2"
              />
              <v-row dense>
                <v-col cols="6">
                  <v-text-field v-model="form.city" name="city" label="City" variant="outlined" density="comfortable" hide-details />
                </v-col>
                <v-col cols="6">
                  <v-text-field v-model="form.state" name="state" label="State / Province" variant="outlined" density="comfortable" hide-details />
                </v-col>
              </v-row>
              <v-row dense>
                <v-col cols="6">
                  <v-text-field v-model="form.country" name="country" label="Country" variant="outlined" density="comfortable" hide-details />
                </v-col>
                <v-col cols="6">
                  <v-text-field v-model="form.postal_code" name="postal_code" label="Postal code" variant="outlined" density="comfortable" hide-details />
                </v-col>
              </v-row>
            </v-card-text>
          </v-card>

          <!-- Business Details -->
          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <template #prepend>
                <v-icon color="teal" class="me-2">mdi-briefcase-outline</v-icon>
                <div>
                  <v-card-title class="text-body-1 font-weight-bold">Business Details</v-card-title>
                  <v-card-subtitle>Industry and registration information</v-card-subtitle>
                </div>
              </template>
            </v-card-item>
            <v-divider />
            <v-card-text class="d-flex flex-column ga-4">
              <v-text-field
                v-model="form.industry"
                name="industry"
                label="Industry"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-select
                v-model="form.size"
                :items="sizeOptions"
                label="Company size"
                variant="outlined"
                density="comfortable"
                hide-details
                clearable
              />
              <v-text-field
                v-model="form.registration_number"
                name="registration_number"
                label="Registration number"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-text-field
                v-model="form.tax_number"
                name="tax_number"
                label="Tax number (VAT / TIN)"
                variant="outlined"
                density="comfortable"
                hide-details
              />
            </v-card-text>
          </v-card>
        </v-form>
      </v-col>

      <v-col cols="12" md="4">
        <v-card variant="outlined" rounded="lg" class="mb-4">
          <v-card-item>
            <v-card-title class="text-body-2 font-weight-bold">Summary</v-card-title>
          </v-card-item>
          <v-divider />
          <v-list density="compact">
            <v-list-item title="Name">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.name }">{{ form.name || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Status">
              <template #subtitle>
                <v-chip size="x-small" variant="tonal" :color="form.status === 'active' ? 'success' : form.status === 'inactive' ? 'grey' : 'warning'">
                  {{ form.status }}
                </v-chip>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Industry">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.industry }">{{ form.industry || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Size">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.size }">{{ form.size || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Location">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.city }">{{ [form.city, form.country].filter(Boolean).join(', ') || 'Not set' }}</span>
              </template>
            </v-list-item>
          </v-list>
        </v-card>

        <v-btn color="primary" size="large" :loading="saving" block @click="save">
          Create company
        </v-btn>
      </v-col>
    </v-row>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const router = useRouter()
const { createCompany } = useCompanies()

const form = reactive({
  name: '',
  slug: '',
  status: 'active' as const,
  contact_email: '',
  contact_phone: '',
  website: '',
  address: '',
  city: '',
  state: '',
  country: '',
  postal_code: '',
  industry: '',
  size: null as string | null,
  registration_number: '',
  tax_number: '',
})

const statusOptions = ['active', 'inactive', 'suspended']
const sizeOptions = ['1-10', '11-50', '51-200', '200+']
const saving = ref(false)
const formRef = ref<VForm>()

const required = [(v: any) => !!v || 'Required']

async function save() {
  saving.value = true
  try {
    if (!formRef.value) throw new Error('Form not found')
    const { valid } = await formRef.value.validate()
    if (!valid) {
      snackbar.value = { show: true, text: 'Please fix the highlighted errors', color: 'warning' }
      return
    }

    const payload = {
      name: form.name,
      slug: form.slug || null,
      status: form.status,
      contact_email: form.contact_email || null,
      contact_phone: form.contact_phone || null,
      website: form.website || null,
      address: form.address || null,
      city: form.city || null,
      state: form.state || null,
      country: form.country || null,
      postal_code: form.postal_code || null,
      industry: form.industry || null,
      size: form.size || null,
      registration_number: form.registration_number || null,
      tax_number: form.tax_number || null,
    }

    await createCompany(payload)
    snackbar.value = { show: true, text: 'Company created!', color: 'success' }
    setTimeout(() => router.push('/manage/contacts'), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    saving.value = false
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>
