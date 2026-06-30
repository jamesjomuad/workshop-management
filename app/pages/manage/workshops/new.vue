<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" :to="'/manage/workshops'" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">New Workshop</h1>
      <v-spacer />
      <v-btn variant="outlined" :loading="savingDraft" @click="save('draft')">Save as draft</v-btn>
      <v-btn color="primary" :loading="savingPublish" @click="save('published')">Publish workshop</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-form ref="formRef">
        <v-row density="comfortable">
          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="primary" class="me-2">mdi-clipboard-text</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Workshop details</v-card-title>
                    <v-card-subtitle>Name and description</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-4">
                <v-text-field v-model="form.title" name="title" label="Workshop title *" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
                <v-textarea v-model="form.description" name="description" label="Description" variant="outlined" density="comfortable" rows="3" hide-details />
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="teal" class="me-2">mdi-calendar-range</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Schedules</v-card-title>
                    <v-card-subtitle>One or more date ranges for this workshop</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-2">
                <div v-for="(r, i) in form.dateRanges" :key="i" class="d-flex align-center ga-2">
                  <v-date-input v-model="r.start" :name="'date_start_' + i" label="Start date *" :min="today" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
                  <v-icon class="flex-shrink-0">mdi-chevron-right</v-icon>
                  <v-date-input v-model="r.end" :name="'date_end_' + i" label="End date *" :min="r.start || today" :rules="[...required, v => !r.start || !v || v >= r.start || 'End must be after start']" variant="outlined" density="comfortable" hide-details="auto" />
                  <v-btn v-if="form.dateRanges.length > 1" icon variant="text" size="small" color="error" @click="removeRange(i)">
                    <v-icon>mdi-close</v-icon>
                  </v-btn>
                </div>
                <v-btn variant="outlined" size="small" color="primary" prepend-icon="mdi-plus" class="align-self-start" @click="addRange">
                  Add date range
                </v-btn>
              </v-card-text>
            </v-card>
          </v-col>

          <v-col cols="12">
            <v-card variant="outlined" rounded="lg">
              <v-card-item>
                <template #prepend>
                  <v-icon color="warning" class="me-2">mdi-door-open</v-icon>
                  <div>
                    <v-card-title class="text-body-1 font-weight-bold">Venue</v-card-title>
                    <v-card-subtitle>Optional — assign later if venue is unconfirmed</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text>
                <v-autocomplete
                  v-model="form.conference_room_id"
                  :items="venues ?? []"
                  item-title="name"
                  item-value="id"
                  label="Search or select venue"
                  variant="outlined"
                  density="comfortable"
                  hide-details
                  clearable
                  placeholder="Type to search..."
                  :menu-props="{ maxHeight: '400px' }"
                >
                  <template #item="{ props, item }">
                    <v-list-item
                      v-bind="props"
                      :title="item.name"
                      :subtitle="item.venue_name + (item.capacity ? ' · ' + item.capacity + ' pax' : '')"
                    >
                      <template #prepend>
                        <v-icon size="18" color="warning" class="me-2">mdi-door-open</v-icon>
                      </template>
                    </v-list-item>
                  </template>
                  <template #selection="{ item }">
                    <div class="d-flex align-center ga-2">
                      <v-icon size="18" color="warning">mdi-door-open</v-icon>
                      <span class="font-weight-medium">{{ item.name }}</span>
                      <span class="text-caption text-medium-emphasis ms-1">— {{ item.venue_name }}</span>
                    </div>
                  </template>
                  <template #no-data>
                    <v-list-item title="No venues found" />
                  </template>
                </v-autocomplete>
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
                      <div class="text-caption text-medium-emphasis">{{ users?.find(u => u.id === prog.trainer_id)?.name || 'No trainer assigned' }}</div>
                    </div>
                    <v-btn icon variant="text" size="x-small" color="medium-emphasis" @click.stop="removeProgram(prog._key)">
                      <v-icon size="16">mdi-close</v-icon>
                    </v-btn>
                  </div>
                  <v-expand-transition>
                    <div v-show="prog._open" class="border-t pa-3 d-flex flex-column ga-3">
                      <v-select
                        v-model="prog.name"
                        name="program_name"
                        :items="PROGRAM_OPTIONS"
                        label="Program"
                        variant="outlined"
                        density="comfortable"
                        hide-details
                      />
                      <v-autocomplete
                        v-model="prog.trainer_id"
                        name="program_trainer"
                        :items="userOptions"
                        item-title="title"
                        item-value="value"
                        label="Trainer for this program"
                        hint="Overrides lead trainer"
                        persistent-hint
                        variant="outlined"
                        density="comfortable"
                        hide-details
                        clearable
                        placeholder="Type to search..."
                        :menu-props="{ maxHeight: '400px' }"
                      >
                        <template #item="{ props, item }">
                          <v-list-item
                            v-bind="props"
                            :title="item.title"
                            :subtitle="item.role"
                          >
                            <template #prepend>
                              <v-icon size="18" color="purple" class="me-2">mdi-account-school</v-icon>
                            </template>
                          </v-list-item>
                        </template>
                        <template #selection="{ item }">
                          <div class="d-flex align-center ga-2">
                            <v-icon size="18" color="purple">mdi-account-school</v-icon>
                            <span class="font-weight-medium">{{ item.title }}</span>
                            <span class="text-caption text-medium-emphasis ms-1">— {{ item.role }}</span>
                          </div>
                        </template>
                        <template #no-data>
                          <v-list-item title="No users found" />
                        </template>
                      </v-autocomplete>
                      <v-row>
                        <v-col cols="6">
                          <v-select
                            v-model="prog.schedule"
                            name="program_schedule"
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
                            name="program_start_day"
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
                    <v-card-title class="text-body-1 font-weight-bold">Organizer & facilitator</v-card-title>
                    <v-card-subtitle>Assign the people running this workshop</v-card-subtitle>
                  </div>
                </template>
              </v-card-item>
              <v-divider />
              <v-card-text class="d-flex flex-column ga-4">
                <v-row>
                  <v-col cols="6">
                    <v-autocomplete
                      v-model="form.facilitator_id"
                      name="organizer"
                      :items="userOptions"
                      item-title="title"
                      item-value="value"
                      label="Organizer *"
                      variant="outlined"
                      density="comfortable"
                      hide-details
                      :rules="required"
                      clearable
                      placeholder="Type to search..."
                      :menu-props="{ maxHeight: '400px' }"
                    >
                      <template #item="{ props, item }">
                        <v-list-item
                          v-bind="props"
                          :title="item.title"
                          :subtitle="item.role"
                        >
                          <template #prepend>
                            <v-icon size="18" color="success" class="me-2">mdi-account-tie</v-icon>
                          </template>
                        </v-list-item>
                      </template>
                      <template #selection="{ item }">
                        <div class="d-flex align-center ga-2">
                          <v-icon size="18" color="success">mdi-account-tie</v-icon>
                          <span class="font-weight-medium">{{ item.title }}</span>
                          <span class="text-caption text-medium-emphasis ms-1">— {{ item.role }}</span>
                        </div>
                      </template>
                      <template #no-data>
                        <v-list-item title="No users found" />
                      </template>
                    </v-autocomplete>
                  </v-col>
                  <v-col cols="6">
                    <v-autocomplete
                      v-model="form.facilitator_assistant"
                      name="facilitator"
                      :items="userOptions"
                      item-title="title"
                      item-value="value"
                      label="Facilitator"
                      hint="Optional"
                      persistent-hint
                      variant="outlined"
                      density="comfortable"
                      hide-details
                      clearable
                      placeholder="Type to search..."
                      :menu-props="{ maxHeight: '400px' }"
                    >
                      <template #item="{ props, item }">
                        <v-list-item
                          v-bind="props"
                          :title="item.title"
                          :subtitle="item.role"
                        >
                          <template #prepend>
                            <v-icon size="18" color="teal" class="me-2">mdi-account</v-icon>
                          </template>
                        </v-list-item>
                      </template>
                      <template #selection="{ item }">
                        <div class="d-flex align-center ga-2">
                          <v-icon size="18" color="teal">mdi-account</v-icon>
                          <span class="font-weight-medium">{{ item.title }}</span>
                          <span class="text-caption text-medium-emphasis ms-1">— {{ item.role }}</span>
                        </div>
                      </template>
                      <template #no-data>
                        <v-list-item title="No users found" />
                      </template>
                    </v-autocomplete>
                  </v-col>
                </v-row>
                <v-alert type="info" variant="tonal" density="compact" text="Organizers assigned to individual programs override this selection for their sessions." />
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
                  name="client_company"
                  :items="companyOptions"
                  label="Client company"
                  hint="Leave blank for open enrollment"
                  persistent-hint
                  variant="outlined"
                  density="comfortable"
                  hide-details
                  clearable
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
                </v-row>
              </v-card-text>
            </v-card>
          </v-col>
        </v-row>
        </v-form>
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
              <v-list-item title="Organizer">
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
            <v-btn color="primary" size="large" :loading="savingPublish" block @click="save('published')">Publish workshop</v-btn>
            <v-btn variant="outlined" size="large" :loading="savingDraft" block @click="save('draft')">Save as draft</v-btn>
          </div>
        </div>
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
const { venues, companies, createWorkshop } = useAdminWorkshops()
const { users } = useUsers()

const form = reactive({
  title: '',
  description: '',
  dateRanges: [{ start: '', end: '' }],
  conference_room_id: null as string | null,
  client_id: null as string | null,
  facilitator_id: null as string | null,
  facilitator_assistant: null as string | null,
  enrollment_type: 'company',
  max_capacity: 20,
})
const status = ref('draft')
const savingDraft = ref(false)
const savingPublish = ref(false)
const formRef = ref<VForm>()

const required = [(v: any) => !!v || 'Required']
const today = new Date().toISOString().split('T')[0]

const companyOptions = computed(() =>
  (companies.value ?? []).map(c => ({ title: c.name, value: c.id }))
)

const selectedRoom = computed(() =>
  venues.value?.find(r => r.id === form.conference_room_id)
)

const STATUS_OPTIONS = [
  { value: 'draft', label: 'Draft', sub: 'Not visible to trainees', dot: '#98A2B3' },
  { value: 'published', label: 'Published', sub: 'Open for enrollment', dot: '#2563EB' },
  { value: 'upcoming', label: 'Upcoming', sub: 'Confirmed, enrollment closed', dot: '#D97706' },
]
const PROGRAM_OPTIONS = ['PM Fundamentals', 'Safety & Compliance', 'Leadership Essentials', 'HR Fundamentals', 'Digital Literacy', 'Risk Management', 'Custom (new program)']
const userOptions = computed(() => (users.value ?? []).map(u => ({ title: u.name, value: u.id, role: u.role })))
const SCHEDULE_OPTIONS = ['Morning (08:00–12:00)', 'Afternoon (13:00–17:00)', 'Full day (08:00–17:00)', 'Custom']
const DAY_OPTIONS = ['Day 1', 'Day 2', 'Day 3']

let progKey = 0
interface ProgramItem {
  _key: number
  _open: boolean
  name: string
  trainer_id: string | null
  schedule: string
  start_day: string
}
const programs = ref<ProgramItem[]>([])

function addProgram() {
  progKey++
  programs.value.push({ _key: progKey, _open: true, name: '', trainer_id: null, schedule: 'Morning (08:00–12:00)', start_day: 'Day 1' })
}

function removeProgram(key: number) {
  programs.value = programs.value.filter(p => p._key !== key)
}

function stepCapacity(delta: number) {
  form.max_capacity = Math.max(1, Math.min(200, (form.max_capacity || 0) + delta))
}

function addRange() {
  form.dateRanges.push({ start: '', end: '' })
}

function removeRange(i: number) {
  form.dateRanges.splice(i, 1)
}

const summary = computed(() => {
  const title = form.title

  const filled = form.dateRanges.filter(r => r.start && r.end)
  const dates = filled.length > 0 ? filled.map(r => `${fmt(r.start)} – ${fmt(r.end)}`).join(', ') : null

  let duration = '—'
  if (filled.length > 0) {
    const totalDays = filled.reduce((sum, r) => {
      const s = new Date(r.start)
      const e = new Date(r.end)
      if (e < s) return sum
      return sum + Math.round((e.getTime() - s.getTime()) / 86400000) + 1
    }, 0)
    if (totalDays > 0) duration = `${totalDays} day${totalDays > 1 ? 's' : ''}`
  }

  const room = selectedRoom.value ? `${selectedRoom.value.name} · ${selectedRoom.value.venue_name}` : null
  const trainer = users.value?.find(u => u.id === form.facilitator_id)?.name || null
  const facilitator = users.value?.find(u => u.id === form.facilitator_assistant)?.name || null

  const client = form.client_id
    ? companies.value?.find(c => c.id === form.client_id)?.name ?? null
    : null

  const cap = `${form.max_capacity} participants`
  const progSummary = programs.value.map(p => ({ key: p._key, name: p.name, trainer: users.value?.find(u => u.id === p.trainer_id)?.name || '—' }))

  return { title, dates, duration, room, trainer, facilitator, client, capacity: cap, programs: progSummary }
})

function fmt(d: string) {
  if (!d) return ''
  const dt = new Date(d + 'T00:00:00')
  return dt.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

async function save(publishStatus: string) {
  status.value = publishStatus
  const loading = publishStatus === 'published' ? savingPublish : savingDraft
  loading.value = true
  try {
    if (!formRef.value) throw new Error('Form not found')
    const { valid } = await formRef.value.validate()
    if (!valid) {
      snackbar.value = { show: true, text: 'Please fix the highlighted errors', color: 'warning' }
      return
    }

    await createWorkshop({
      title: form.title,
      description: form.description || null,
      date_start: form.dateRanges.filter(r => r.start).map(r => r.start).sort()[0],
      date_end: form.dateRanges.filter(r => r.end).map(r => r.end).sort().slice(-1)[0],
      conference_room_id: form.conference_room_id,
      client_id: form.client_id,
      facilitator_id: form.facilitator_id,
      status: status.value as any,
    })
    snackbar.value = { show: true, text: status.value === 'published' ? 'Workshop published!' : 'Workshop saved as draft.', color: 'success' }
    setTimeout(() => router.push('/manage/workshops'), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    loading.value = false
  }
}

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
