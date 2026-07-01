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
      <v-col cols="12" md="8" lg="6">
        <v-card variant="outlined" rounded="lg">
          <v-card-item>
            <template #prepend>
              <v-icon color="warning" class="me-2">mdi-door-open</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Venue details</v-card-title>
                <v-card-subtitle>Name, venue, and capacity information</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text>
            <v-form ref="formRef" @submit.prevent="handleSave" class="d-flex flex-column ga-4">
            <v-text-field v-model="form.name" label="Hotel name *" name="name" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
            <v-text-field v-model="form.venue_name" label="Venue *" name="venue_name" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
            <v-text-field v-model="form.venue_address" label="Address" name="venue_address" variant="outlined" density="comfortable" hide-details />

            <v-row>
              <v-col cols="6">
                <v-text-field v-model.number="form.capacity" label="Capacity *" name="capacity" type="number" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
              </v-col>
              <v-col cols="6">
                <v-text-field v-model="form.floor" label="Floor" name="floor" variant="outlined" density="comfortable" hide-details />
              </v-col>
            </v-row>

            <v-textarea v-model="form.notes" label="Notes" name="notes" variant="outlined" density="comfortable" rows="3" hide-details />

            <v-alert v-if="error" type="error" density="compact" variant="tonal">{{ error }}</v-alert>
            </v-form>
          </v-card-text>
        </v-card>

        <v-card variant="outlined" rounded="lg" class="mt-4">
          <v-card-item>
            <template #prepend>
              <v-icon color="success" class="me-2">mdi-information</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Status</v-card-title>
                <v-card-subtitle>Availability</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text>
            <v-radio-group v-model="form.status" inline hide-details>
              <v-radio label="Available" value="available" color="success" />
              <v-radio label="Booked" value="booked" color="warning" />
              <v-radio label="In use" value="in_use" color="error" />
            </v-radio-group>
          </v-card-text>
        </v-card>
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

import type { ConferenceRoom } from '~/types'

const route = useRoute()
const router = useRouter()
const { data: venues, refresh } = useFetch<ConferenceRoom[]>('/api/admin/rooms')

const venue = computed(() => venues.value?.find(r => r.id === route.params.id))
const loading = computed(() => !venues.value)

const form = reactive({
  name: '',
  venue_name: '',
  venue_address: '',
  capacity: 50,
  floor: '',
  status: 'available',
  notes: '',
})
const saving = ref(false)
const error = ref('')
const formRef = ref<VForm>()

const required = [(v: string | number) => !!v || 'Required']

watch(venue, (r) => {
  if (r) {
    form.name = r.name
    form.venue_name = r.venue_name
    form.venue_address = r.venue_address ?? ''
    form.capacity = r.capacity
    form.floor = r.floor ?? ''
    form.status = r.status
    form.notes = r.notes ?? ''
  }
}, { immediate: true })

async function handleSave() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  saving.value = true
  error.value = ''
  try {
    const { error: err } = await useFetch(`/api/admin/rooms/${route.params.id}`, {
      method: 'PUT',
      body: {
        name: form.name,
        venue_name: form.venue_name,
        venue_address: form.venue_address || null,
        floor: form.floor || null,
        capacity: form.capacity,
        status: form.status as any,
        notes: form.notes || null,
      },
    })
    if (err.value) throw new Error(err.value.message)
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
