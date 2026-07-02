<template>
  <div v-if="venue">
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" :to="'/manage/venues'" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold ma-0">Edit: {{ venue.name }}</h1>
      <v-spacer />
      <v-btn variant="outlined" :to="'/manage/venues'">Cancel</v-btn>
      <v-btn color="primary" :loading="saving" @click="handleSave">Save changes</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8" lg="7">
        <v-card variant="outlined" rounded="lg">
          <v-card-item>
            <template #prepend>
              <v-icon color="warning" class="me-2">mdi-office-building</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Venue details</v-card-title>
                <v-card-subtitle>Name and type</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text>
            <v-form ref="formRef" @submit.prevent="handleSave" class="d-flex flex-column ga-4">
              <v-text-field v-model="form.name" label="Venue name *" name="name" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />

              <v-select
                v-model="form.type"
                :items="VENUE_TYPES"
                item-title="label"
                item-value="value"
                label="Venue type *"
                name="type"
                :rules="required"
                variant="outlined"
                density="comfortable"
                hide-details="auto"
              />

              <v-textarea v-model="form.notes" label="Notes" name="notes" hint="Parking info, load-in instructions, etc." persistent-hint variant="outlined" density="comfortable" rows="2" hide-details />

              <v-switch v-model="form.is_active" label="Active" color="primary" density="comfortable" hide-details inset />
            </v-form>
          </v-card-text>
        </v-card>

        <v-card variant="outlined" rounded="lg" class="mt-4">
          <v-card-item>
            <template #prepend>
              <v-icon color="info" class="me-2">mdi-map-marker</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Location</v-card-title>
                <v-card-subtitle>Address and geographic details</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text class="d-flex flex-column ga-4">
            <v-text-field v-model="form.address" label="Street address" name="address" variant="outlined" density="comfortable" hide-details />

            <v-row>
              <v-col cols="6">
                <v-text-field v-model="form.city" label="City" name="city" variant="outlined" density="comfortable" hide-details />
              </v-col>
              <v-col cols="6">
                <v-text-field v-model="form.province" label="Province / Region" name="province" variant="outlined" density="comfortable" hide-details />
              </v-col>
            </v-row>

            <v-row>
              <v-col cols="6">
                <v-text-field v-model="form.country" label="Country" name="country" variant="outlined" density="comfortable" hide-details />
              </v-col>
              <v-col cols="6">
                <v-text-field v-model="form.postal_code" label="Postal code" name="postal_code" variant="outlined" density="comfortable" hide-details />
              </v-col>
            </v-row>

            <v-row>
              <v-col cols="6">
                <v-text-field v-model.number="form.latitude" label="Latitude" name="latitude" type="number" step="any" variant="outlined" density="comfortable" hide-details />
              </v-col>
              <v-col cols="6">
                <v-text-field v-model.number="form.longitude" label="Longitude" name="longitude" type="number" step="any" variant="outlined" density="comfortable" hide-details />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>

        <v-card variant="outlined" rounded="lg" class="mt-4">
          <v-card-item>
            <template #prepend>
              <v-icon color="success" class="me-2">mdi-phone</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Contact person</v-card-title>
                <v-card-subtitle>Hotel coordinator or venue contact</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text class="d-flex flex-column ga-4">
            <v-text-field v-model="form.contact_person" label="Contact person" name="contact_person" variant="outlined" density="comfortable" hide-details />
            <v-row>
              <v-col cols="6">
                <v-text-field v-model="form.contact_phone" label="Phone" name="contact_phone" variant="outlined" density="comfortable" hide-details />
              </v-col>
              <v-col cols="6">
                <v-text-field v-model="form.contact_email" label="Email" name="contact_email" type="email" variant="outlined" density="comfortable" hide-details />
              </v-col>
            </v-row>
          </v-card-text>
        </v-card>

        <v-alert v-if="error" type="error" density="compact" variant="tonal" class="mt-4">{{ error }}</v-alert>
      </v-col>
    </v-row>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
  <div v-else-if="loading" class="text-center py-10">
    <v-progress-circular indeterminate color="primary" />
  </div>
  <div v-else class="text-center py-10">
    <p class="text-grey">Venue not found.</p>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

import type { Venue } from '~/types'

const route = useRoute()
const router = useRouter()
const { data: venues, refresh } = useFetch<Venue[]>('/api/admin/rooms')

const venue = computed(() => venues.value?.find(r => r.id === route.params.id))
const loading = computed(() => !venues.value)

const VENUE_TYPES = [
  { label: 'Hotel', value: 'hotel' },
  { label: 'Convention Center', value: 'convention_center' },
  { label: 'Office', value: 'office' },
  { label: 'Other', value: 'other' },
]

const form = reactive({
  name: '',
  type: 'hotel',
  address: '',
  city: '',
  province: '',
  country: 'Philippines',
  postal_code: '',
  latitude: null as number | null,
  longitude: null as number | null,
  contact_person: '',
  contact_phone: '',
  contact_email: '',
  notes: '',
  is_active: true,
})
const saving = ref(false)
const error = ref('')
const formRef = ref<VForm>()

const required = [(v: string | number) => !!v || 'Required']

watch(venue, (r) => {
  if (r) {
    form.name = r.name
    form.type = r.type
    form.address = r.address ?? ''
    form.city = r.city ?? ''
    form.province = r.province ?? ''
    form.country = r.country ?? 'Philippines'
    form.postal_code = r.postal_code ?? ''
    form.latitude = r.latitude
    form.longitude = r.longitude
    form.contact_person = r.contact_person ?? ''
    form.contact_phone = r.contact_phone ?? ''
    form.contact_email = r.contact_email ?? ''
    form.notes = r.notes ?? ''
    form.is_active = r.is_active
  }
}, { immediate: true })

async function handleSave() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  saving.value = true
  error.value = ''
  try {
    await $fetch(`/api/admin/rooms/${route.params.id}`, {
      method: 'PUT',
      body: {
        name: form.name,
        type: form.type,
        address: form.address || null,
        city: form.city || null,
        province: form.province || null,
        country: form.country || null,
        postal_code: form.postal_code || null,
        latitude: form.latitude,
        longitude: form.longitude,
        contact_person: form.contact_person || null,
        contact_phone: form.contact_phone || null,
        contact_email: form.contact_email || null,
        notes: form.notes || null,
        is_active: form.is_active,
      },
    })
    await refresh()
    snackbar.value = { show: true, text: 'Venue updated successfully', color: 'success' }
    setTimeout(() => router.push('/manage/venues'), 1000)
  } catch (err: any) {
    error.value = err.message
  } finally {
    saving.value = false
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>
