<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" to="/manage/contacts" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">Edit Contact</h1>
      <v-spacer />
      <v-btn color="primary" :loading="saving" @click="save">Save changes</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-form ref="formRef">
          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <template #prepend>
                <v-icon color="primary" class="me-2">mdi-account</v-icon>
                <div>
                  <v-card-title class="text-body-1 font-weight-bold">Contact details</v-card-title>
                  <v-card-subtitle>Name, company, and contact information</v-card-subtitle>
                </div>
              </template>
            </v-card-item>
            <v-divider />
            <v-card-text class="d-flex flex-column ga-4">
              <v-autocomplete
                v-model="form.company_id"
                :items="companies ?? []"
                item-title="name"
                item-value="id"
                label="Company"
                variant="outlined"
                density="comfortable"
                hide-details
                clearable
              />
              <v-row dense>
                <v-col cols="6">
                  <v-text-field
                    v-model="form.first_name"
                    name="first_name"
                    label="First name *"
                    :rules="required"
                    variant="outlined"
                    density="comfortable"
                    hide-details="auto"
                  />
                </v-col>
                <v-col cols="6">
                  <v-text-field
                    v-model="form.last_name"
                    name="last_name"
                    label="Last name *"
                    :rules="required"
                    variant="outlined"
                    density="comfortable"
                    hide-details="auto"
                  />
                </v-col>
              </v-row>
              <v-text-field
                v-model="form.email"
                name="email"
                label="Email"
                type="email"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-text-field
                v-model="form.phone"
                name="phone"
                label="Phone"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-text-field
                v-model="form.position"
                name="position"
                label="Position / Job title"
                variant="outlined"
                density="comfortable"
                hide-details
              />
              <v-textarea
                v-model="form.notes"
                name="notes"
                label="Notes"
                variant="outlined"
                density="comfortable"
                rows="2"
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
                <span :class="{ 'text-medium-emphasis': !form.first_name }">{{ fullName || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Company">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.company_id }">{{ companyName || 'None' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Email">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.email }">{{ form.email || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Phone">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.phone }">{{ form.phone || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Position">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.position }">{{ form.position || 'Not set' }}</span>
              </template>
            </v-list-item>
          </v-list>
        </v-card>

        <v-btn color="primary" size="large" :loading="saving" block @click="save">
          Save changes
        </v-btn>
      </v-col>
    </v-row>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script setup lang="ts">
import type { Contact } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const router = useRouter()
const route = useRoute()
const { companies } = useCompanies()
const { updateContact } = useContacts()

const contact = ref<Contact | null>(null)
const form = reactive({
  company_id: null as string | null,
  first_name: '',
  last_name: '',
  email: '',
  phone: '',
  position: '',
  notes: '',
})

const saving = ref(false)
const formRef = ref<VForm>()
const loading = ref(true)

const required = [(v: any) => !!v || 'Required']

const fullName = computed(() => [form.first_name, form.last_name].filter(Boolean).join(' ') || '')
const companyName = computed(() => companies.value?.find(c => c.id === form.company_id)?.name || '')

async function loadContact() {
  loading.value = true
  try {
    const supabase = useSupabaseClient()
    const { data, error } = await supabase
      .from('contacts')
      .select('*')
      .eq('id', route.params.id)
      .single()
    if (error) throw error
    contact.value = data
    form.company_id = data.company_id
    form.first_name = data.first_name
    form.last_name = data.last_name
    form.email = data.email ?? ''
    form.phone = data.phone ?? ''
    form.position = data.position ?? ''
    form.notes = data.notes ?? ''
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
    router.push('/manage/contacts')
  } finally {
    loading.value = false
  }
}

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
      company_id: form.company_id || null,
      first_name: form.first_name,
      last_name: form.last_name,
      email: form.email || null,
      phone: form.phone || null,
      position: form.position || null,
      notes: form.notes || null,
    }

    await updateContact(route.params.id as string, payload)
    snackbar.value = { show: true, text: 'Contact updated!', color: 'success' }
    setTimeout(() => router.push('/manage/contacts'), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    saving.value = false
  }
}

onMounted(loadContact)

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>
