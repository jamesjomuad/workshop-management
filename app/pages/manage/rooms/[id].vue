<template>
  <div v-if="room">
    <div class="d-flex align-center mb-4">
      <v-btn icon variant="text" :to="'/manage/rooms'" class="me-2">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <h1 class="text-h4 font-weight-bold">Edit: {{ room.name }}</h1>
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
          <v-select v-model="form.status" :items="statusOptions" label="Status" variant="outlined" density="comfortable" class="mb-2" />
          <v-textarea v-model="form.notes" label="Notes" variant="outlined" density="comfortable" class="mb-4" rows="3" />

          <v-alert v-if="error" type="error" density="compact" class="mb-4">{{ error }}</v-alert>

          <div class="d-flex ga-2">
            <v-btn :to="'/manage/rooms'" variant="outlined">Cancel</v-btn>
            <v-btn type="submit" color="primary" :loading="saving">Save Changes</v-btn>
          </div>
        </v-form>
      </v-card-text>
    </v-card>
  </div>
  <div v-else-if="loading" class="text-center py-10">
    <v-progress-circular indeterminate color="primary" />
  </div>
  <div v-else class="text-center py-10">
    <p class="text-grey">Room not found.</p>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const route = useRoute()
const router = useRouter()
const { rooms, updateRoom } = useConferenceRooms()

const room = computed(() => rooms.value?.find(r => r.id === route.params.id))
const loading = computed(() => !rooms.value)

const form = reactive({
  name: '',
  venue_name: '',
  venue_address: '',
  capacity: 50,
  floor: '',
  status: 'available',
  notes: '',
})
const error = ref('')
const saving = ref(false)
const formRef = ref<VForm>()

const required = [(v: string | number) => !!v || 'Required']
const statusOptions = ['available', 'booked', 'in_use']

watch(room, (r) => {
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
    await updateRoom(route.params.id as string, {
      name: form.name,
      venue_name: form.venue_name,
      venue_address: form.venue_address || null,
      floor: form.floor || null,
      capacity: form.capacity,
      status: form.status as any,
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
