<template>
  <div v-if="workshop">
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" :to="'/manage/workshops'" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">Edit: {{ workshop.title }}</h1>
      <v-spacer />
      <v-btn variant="outlined" :loading="savingDraft" @click="handleSave('draft')">Save as draft</v-btn>
      <v-btn color="primary" :loading="savingPublish" @click="handleSave('published')">Publish workshop</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-row dense>
          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="primary" class="me-2">mdi-clipboard-text</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Workshop details</v-card-title>
                    <v-card-subtitle>Name, description, and dates</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-4">
                <v-text-field v-model="form.title" label="Workshop title *" :rules="required" variant="outlined" density="comfortable" hide-details="auto" @update:model-value="updateSummary" />
                <v-textarea v-model="form.description" label="Description" variant="outlined" density="comfortable" rows="3" hide-details />
                <v-row>
                  <v-col cols="6">
                    <v-text-field v-model="form.date_start" label="Start date *" type="date" :rules="required" variant="outlined" density="comfortable" hide-details="auto" @update:model-value="updateSummary" />
                  </v-col>
                  <v-col cols="6">
                    <v-text-field v-model="form.date_end" label="End date *" type="date" :rules="required" variant="outlined" density="comfortable" hide-details="auto" @update:model-value="updateSummary" />
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="warning" class="me-2">mdi-door-open</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Conference room</v-card-title>
                    <v-card-subtitle>Optional — assign later if venue is unconfirmed</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text>
                <v-radio-group v-model="form.conference_room_id" hide-details @update:model-value="updateSummary">
                  <v-row>
                    <v-col v-for="r in rooms ?? []" :key="r.id" cols="6">
                      <v-sheet
                        border
                        rounded="lg"
                        :class="['pa-3 room-option', { selected: form.conference_room_id === r.id }]"
                        @click="form.conference_room_id = r.id; updateSummary()"
                      >
                        <v-radio :value="r.id" class="position-absolute opacity-0" style="pointer-events:none" />
                        <div class="d-flex justify-space-between align-start mb-1">
                          <div class="text-caption text-medium-emphasis font-family-mono">
                            <v-icon size="14" class="me-1">mdi-hotel</v-icon>
                            {{ r.venue_name }}
                          </div>
                          <v-chip size="x-small" color="success" variant="tonal">Available</v-chip>
                        </div>
                        <div class="text-body-2 font-weight-bold">{{ r.name }}</div>
                        <div class="text-caption text-medium-emphasis">
                          <v-icon size="14" class="me-1">mdi-account-group</v-icon>
                          {{ r.capacity }} pax
                          <span v-if="r.floor"> · {{ r.floor }}</span>
                        </div>
                      </v-sheet>
                    </v-col>
                  </v-row>
                  <v-sheet
                    border
                    rounded="lg"
                    :class="['pa-3 mt-2 d-flex align-center room-option', { selected: !form.conference_room_id }]"
                    @click="form.conference_room_id = null; updateSummary()"
                  >
                    <v-radio :value="null" class="position-absolute opacity-0" style="pointer-events:none" />
                    <v-icon class="me-2">mdi-calendar-blank</v-icon>
                    <span class="text-body-2 text-medium-emphasis">Decide later — no room assigned yet</span>
                  </v-sheet>
                </v-radio-group>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="purple" class="me-2">mdi-book-open-variant</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Programs</v-card-title>
                    <v-card-subtitle>Add one or more programs to run in this workshop</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-3">
                <div v-for="(prog, i) in programs" :key="prog._key" class="program-item">
                  <div
                    class="d-flex align-center ga-2 pa-3 bg-grey-lighten-4 rounded-t cursor-pointer"
                    @click="prog._open = !prog._open"
                  >
                    <v-avatar size="22" color="primary" class="text-body-2 font-weight-bold">
                      {{ i + 1 }}
                    </v-avatar>
                    <div class="flex-grow-1">
                      <div class="text-body-2 font-weight-medium">{{ prog.name || 'New program' }}</div>
                      <div class="text-caption text-medium-emphasis">{{ prog.trainer_name || 'No trainer assigned' }}</div>
                    </div>
                    <v-btn icon variant="text" size="x-small" color="medium-emphasis" @click.stop="removeProgram(prog._key)">
                      <v-icon size="16">mdi-close</v-icon>
                    </v-btn>
                  </div>
                  <v-expand-transition>
                    <div v-show="prog._open" class="border-t pa-3 d-flex flex-column ga-3">
                      <v-select
                        v-model="prog.name"
                        :items="PROGRAM_OPTIONS"
                        label="Program"
                        variant="outlined"
                        density="comfortable"
                        hide-details
                        @update:model-value="updateSummary"
                      />
                      <v-select
                        v-model="prog.trainer_name"
                        :items="TRAINER_OPTIONS"
                        label="Trainer for this program"
                        hint="Overrides lead trainer"
                        persistent-hint
                        variant="outlined"
                        density="comfortable"
                        hide-details
                        clearable
                        @update:model-value="updateSummary"
                      />
                      <v-row>
                        <v-col cols="6">
                          <v-select
                            v-model="prog.schedule"
                            :items="SCHEDULE_OPTIONS"
                            label="Schedule time"
                            variant="outlined"
                            density="comfortable"
                            hide-details
                          />
                        </v-col>
                        <v-col cols="6">
                          <v-select
                            v-model="prog.start_day"
                            :items="DAY_OPTIONS"
                            label="Starting day"
                            variant="outlined"
                            density="comfortable"
                            hide-details
                          />
                        </v-col>
                      </v-row>
                    </div>
                  </v-expand-transition>
                </div>

                <v-btn
                  variant="outlined"
                  color="primary"
                  dashed
                  class="border-dashed"
                  prepend-icon="mdi-plus"
                  @click="addProgram"
                >
                  Add program
                </v-btn>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="success" class="me-2">mdi-account-tie</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Trainer & facilitator</v-card-title>
                    <v-card-subtitle>Assign the people running this workshop</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-4">
                <v-row>
                  <v-col cols="6">
                    <v-select
                      v-model="form.facilitator_id"
                      :items="TRAINER_OPTIONS"
                      label="Lead trainer *"
                      variant="outlined"
                      density="comfortable"
                      hide-details
                      :rules="required"
                      @update:model-value="updateSummary"
                    />
                  </v-col>
                  <v-col cols="6">
                    <v-select
                      v-model="form.facilitator_assistant"
                      :items="FACILITATOR_OPTIONS"
                      label="Facilitator"
                      hint="Optional"
                      persistent-hint
                      variant="outlined"
                      density="comfortable"
                      hide-details
                      clearable
                      @update:model-value="updateSummary"
                    />
                  </v-col>
                </v-row>
                <v-alert type="info" variant="tonal" density="compact" text="Trainers assigned to individual programs override this for their sessions." />
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="error" class="me-2">mdi-domain</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Client & enrollment</v-card-title>
                    <v-card-subtitle>Who's attending and how they enroll</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-4">
                <v-select
                  v-model="form.client_id"
                  :items="companyOptions"
                  label="Client company"
                  hint="Leave blank for open enrollment"
                  persistent-hint
                  variant="outlined"
                  density="comfortable"
                  hide-details
                  clearable
                  @update:model-value="updateSummary"
                />

                <div>
                  <div class="text-body-2 font-weight-medium mb-2">Enrollment type *</div>
                  <v-btn-toggle v-model="form.enrollment_type" mandatory color="primary" density="comfortable" variant="outlined" divided>
                    <v-btn value="company" size="small">Company-sponsored</v-btn>
                    <v-btn value="self" size="small">Self-enrolled</v-btn>
                    <v-btn value="mixed" size="small">Mixed</v-btn>
                  </v-btn-toggle>
                </div>

                <v-row>
                  <v-col cols="6">
                    <v-text-field
                      v-model.number="form.max_capacity"
                      label="Max capacity"
                      type="number"
                      variant="outlined"
                      density="comfortable"
                      hide-details
                      min="1"
                      max="200"
                      @update:model-value="updateSummary"
                    >
                      <template #append-inner>
                        <v-btn icon variant="text" size="x-small" @click="stepCapacity(-1)">
                          <v-icon>mdi-minus</v-icon>
                        </v-btn>
                        <v-btn icon variant="text" size="x-small" @click="stepCapacity(1)">
                          <v-icon>mdi-plus</v-icon>
                        </v-btn>
                      </template>
                    </v-text-field>
                  </v-col>
                  <v-col cols="6">
                    <v-select
                      v-model="form.payment"
                      :items="PAYMENT_OPTIONS"
                      label="Payment required"
                      variant="outlined"
                      density="comfortable"
                      hide-details
                    />
                  </v-col>
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
      </v-col>

      <v-col cols="12" md="4">
        <div class="d-flex flex-column ga-3" style="position:sticky;top:80px">
          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <v-card-title class="text-body-2 font-weight-bold">Status</v-card-title>
            </v-card-item>
            <v-divider />
            <v-card-text class="d-flex flex-column ga-2">
              <v-sheet
                v-for="s in STATUS_OPTIONS"
                :key="s.value"
                border
                rounded="lg"
                :class="['pa-2 d-flex align-center ga-2', { selected: status === s.value }]"
                style="cursor:pointer"
                @click="status = s.value"
              >
                <div :style="{ width: 9, height: 9, borderRadius: '50%', background: s.dot, flexShrink: 0 }" />
                <div>
                  <div class="text-body-2 font-weight-medium">{{ s.label }}</div>
                  <div class="text-caption text-medium-emphasis">{{ s.sub }}</div>
                </div>
              </v-sheet>
            </v-card-text>
          </v-card>

          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <v-card-title class="text-body-2 font-weight-bold">Workshop summary</v-card-title>
            </v-card-item>
            <v-divider />
            <v-list density="compact">
              <v-list-item title="Title">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.title }">{{ summary.title || 'Not set' }}</span>
                </template>
              </v-list-item>
              <v-divider />
              <v-list-item title="Dates">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.dates }">{{ summary.dates || 'Not set' }}</span>
                </template>
              </v-list-item>
              <v-list-item title="Duration">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.duration }">{{ summary.duration || '—' }}</span>
                </template>
              </v-list-item>
              <v-divider />
              <v-list-item title="Venue">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.room }">{{ summary.room || 'No room assigned' }}</span>
                </template>
              </v-list-item>
              <v-divider />
              <v-list-item title="Trainer">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.trainer }">{{ summary.trainer || 'Not assigned' }}</span>
                </template>
              </v-list-item>
              <v-list-item title="Facilitator">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.facilitator }">{{ summary.facilitator || 'Not assigned' }}</span>
                </template>
              </v-list-item>
              <v-divider />
              <v-list-item title="Client">
                <template #subtitle>
                  <span :class="{ 'text-medium-emphasis': !summary.client }">{{ summary.client || 'Open enrollment' }}</span>
                </template>
              </v-list-item>
              <v-list-item title="Capacity">
                <template #subtitle>{{ summary.capacity }}</template>
              </v-list-item>
              <v-divider />
              <v-list-item title="Programs">
                <template #subtitle>
                  <div v-if="summary.programs.length === 0" class="text-medium-emphasis">No programs added</div>
                  <div v-else class="d-flex flex-column ga-1 mt-1">
                    <div v-for="p in summary.programs" :key="p.key" class="d-flex align-center ga-2 bg-grey-lighten-4 rounded pa-2">
                      <div :style="{ width:8, height:8, borderRadius:'50%', background:'var(--v-theme-primary)', flexShrink:0 }" />
                      <div>
                        <div class="text-caption font-weight-medium">{{ p.name || 'New program' }}</div>
                        <div class="text-caption text-medium-emphasis">{{ p.trainer || '—' }}</div>
                      </div>
                    </div>
                  </div>
                </template>
              </v-list-item>
            </v-list>
          </v-card>

          <div class="d-flex flex-column ga-2">
            <v-btn color="primary" size="large" :loading="savingPublish" block @click="handleSave('published')">Publish workshop</v-btn>
            <v-btn variant="outlined" size="large" :loading="savingDraft" block @click="handleSave('draft')">Save as draft</v-btn>
          </div>
        </div>
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
    <p class="text-grey">Workshop not found.</p>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const route = useRoute()
const router = useRouter()
const { workshops, rooms, companies, updateWorkshop } = useAdminWorkshops()

const workshop = computed(() => workshops.value?.find(w => w.id === route.params.id))
const loading = computed(() => !workshops.value)

const form = reactive({
  title: '',
  description: '',
  date_start: '',
  date_end: '',
  conference_room_id: null as string | null,
  client_id: null as string | null,
  facilitator_id: null as string | null,
  facilitator_assistant: null as string | null,
  enrollment_type: 'company',
  max_capacity: 20,
  payment: 'Required — Paid enrollment',
})
const status = ref('draft')
const savingDraft = ref(false)
const savingPublish = ref(false)
const formRef = ref<VForm>()

const required = [(v: any) => !!v || 'Required']

const companyOptions = computed(() =>
  (companies.value ?? []).map(c => ({ title: c.name, value: c.id }))
)

const selectedRoom = computed(() =>
  rooms.value?.find(r => r.id === form.conference_room_id)
)

const STATUS_OPTIONS = [
  { value: 'draft', label: 'Draft', sub: 'Not visible to trainees', dot: '#98A2B3' },
  { value: 'published', label: 'Published', sub: 'Open for enrollment', dot: '#2563EB' },
  { value: 'upcoming', label: 'Upcoming', sub: 'Confirmed, enrollment closed', dot: '#D97706' },
]
const PROGRAM_OPTIONS = ['PM Fundamentals', 'Safety & Compliance', 'Leadership Essentials', 'HR Fundamentals', 'Digital Literacy', 'Risk Management', 'Custom (new program)']
const TRAINER_OPTIONS = ['Maria Santos', 'Rico Cruz', 'Ana Reyes', 'Liza Ocampo']
const FACILITATOR_OPTIONS = ['Rico Dela Cruz', 'Jen Valdez', 'Mark Tan']
const SCHEDULE_OPTIONS = ['Morning (08:00–12:00)', 'Afternoon (13:00–17:00)', 'Full day (08:00–17:00)', 'Custom']
const DAY_OPTIONS = ['Day 1', 'Day 2', 'Day 3']
const PAYMENT_OPTIONS = ['Required — Paid enrollment', 'Waived — No payment needed', 'Per arrangement']

let progKey = 0
interface ProgramItem {
  _key: number
  _open: boolean
  name: string
  trainer_name: string | null
  schedule: string
  start_day: string
}
const programs = ref<ProgramItem[]>([])

function addProgram() {
  progKey++
  programs.value.push({ _key: progKey, _open: true, name: '', trainer_name: null, schedule: 'Morning (08:00–12:00)', start_day: 'Day 1' })
  updateSummary()
}

function removeProgram(key: number) {
  programs.value = programs.value.filter(p => p._key !== key)
  updateSummary()
}

function stepCapacity(delta: number) {
  form.max_capacity = Math.max(1, Math.min(200, (form.max_capacity || 0) + delta))
  updateSummary()
}

const summary = computed(() => {
  const title = form.title
  const dates = form.date_start && form.date_end ? `${fmt(form.date_start)} – ${fmt(form.date_end)}` : null

  let duration = '—'
  if (form.date_start && form.date_end) {
    const s = new Date(form.date_start)
    const e = new Date(form.date_end)
    const days = Math.round((e.getTime() - s.getTime()) / 86400000) + 1
    if (days > 0) duration = `${days} day${days > 1 ? 's' : ''}`
  }

  const room = selectedRoom.value ? `${selectedRoom.value.name} · ${selectedRoom.value.venue_name}` : null
  const trainer = form.facilitator_id || null
  const facilitator = form.facilitator_assistant || null

  const client = form.client_id
    ? companies.value?.find(c => c.id === form.client_id)?.name ?? null
    : null

  const cap = `${form.max_capacity} participants`
  const progSummary = programs.value.map(p => ({ key: p._key, name: p.name, trainer: p.trainer_name || form.facilitator_id || '—' }))

  return { title, dates, duration, room, trainer, facilitator, client, capacity: cap, programs: progSummary }
})

function updateSummary() {}

function fmt(d: string) {
  if (!d) return ''
  const dt = new Date(d + 'T00:00:00')
  return dt.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

function validate() {
  return form.title && form.date_start && form.date_end && form.facilitator_id
}

async function handleSave(publishStatus: string) {
  if (!validate()) {
    snackbar.value = { show: true, text: 'Please fill in required fields (title, dates, trainer)', color: 'error' }
    return
  }

  const loading = publishStatus === 'published' ? savingPublish : savingDraft
  loading.value = true
  try {
    await updateWorkshop(route.params.id as string, {
      title: form.title,
      description: form.description || null,
      date_start: form.date_start,
      date_end: form.date_end,
      conference_room_id: form.conference_room_id,
      client_id: form.client_id,
      status: publishStatus as any,
    })
    snackbar.value = { show: true, text: publishStatus === 'published' ? 'Workshop published!' : 'Workshop saved as draft.', color: 'success' }
    setTimeout(() => router.push('/manage/workshops'), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    loading.value = false
  }
}

watch(workshop, (w) => {
  if (w) {
    form.title = w.title
    form.description = w.description ?? ''
    form.date_start = w.date_start
    form.date_end = w.date_end
    form.conference_room_id = w.conference_room_id
    form.client_id = w.client_id
    status.value = w.status
  }
}, { immediate: true })

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>

<style scoped>
.room-option { cursor: pointer; transition: border-color 0.15s, background 0.12s; }
.room-option:hover { border-color: rgb(var(--v-theme-primary)) !important; background: rgb(var(--v-theme-primary-lighten-5)); }
.room-option.selected { border-color: rgb(var(--v-theme-primary)) !important; background: rgb(var(--v-theme-primary-lighten-5)); }
.border-dashed { border-style: dashed !important; }
.cursor-pointer { cursor: pointer; }
.border-t { border-top: 1px solid rgba(0,0,0,0.12); }
.font-family-mono { font-family: 'DM Mono', 'SF Mono', 'Cascadia Code', monospace; }
</style>
