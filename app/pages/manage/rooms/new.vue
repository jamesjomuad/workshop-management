<template>
  <div>
    <div class="d-flex align-center mb-4">
      <v-btn icon variant="text" :to="'/manage/rooms'" class="me-2">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <h1 class="text-h4 font-weight-bold">New Conference Room</h1>
    </div>

    <v-card elevation="2" rounded="lg" max-width="640">
      <v-card-text>
        <v-form ref="formRef" @submit.prevent="handleSave">
          <v-text-field v-model="form.name" label="Room name *" :rules="required" variant="outlined" density="comfortable" class="mb-2" />
          <v-text-field v-model="form.venue_name" label="Venue name *" :rules="required" variant="outlined" density="comfortable" class="mb-2" />
          <v-text-field v-model="form.venue_address" label="Venue address" variant="outlined" density="comfortable" class="mb-2" />
          <v-row>
            <v-col cols="6">
              <v-text-field v-model.number="form.capacity" label="Capacity *" type="number" :rules="required" variant="outlined" density="comfortable" class="mb-2" />
            </v-col>
            <v-col cols="6">
              <v-text-field v-model="form.floor" label="Floor" variant="outlined" density="comfortable" class="mb-2" />
            </v-col>
          </v-row>
          <v-textarea v-model="form.notes" label="Notes" variant="outlined" density="comfortable" class="mb-4" rows="3" />

          <v-alert v-if="error" type="error" density="compact" class="mb-4">{{ error }}</v-alert>

          <div class="d-flex ga-2">
            <v-btn :to="'/manage/rooms'" variant="outlined">Cancel</v-btn>
            <v-btn type="submit" color="primary" :loading="saving">Save Room</v-btn>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const router = useRouter()
const { createRoom } = useConferenceRooms()

const form = reactive({
  name: '',
  venue_name: '',
  venue_address: '',
  capacity: 50,
  floor: '',
  notes: '',
})
const error = ref('')
const saving = ref(false)
const formRef = ref<VForm>()

const required = [(v: string | number) => !!v || 'Required']

async function handleSave() {
  const { valid } = await formRef.value?.validate() ?? { valid: false }
  if (!valid) return

  saving.value = true
  error.value = ''
  try {
    await createRoom({
      name: form.name,
      venue_name: form.venue_name,
      venue_address: form.venue_address || null,
      floor: form.floor || null,
      capacity: form.capacity,
      notes: form.notes || null,
    })
    await router.push('/manage/rooms')
  } catch (err: any) {
    error.value = err.message
  } finally {
    saving.value = false
  }
}
</script>
