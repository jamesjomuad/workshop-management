<template>
  <div>
    <div class="d-flex align-center mb-4">
      <h1 class="text-h4 font-weight-bold">Calendar</h1>
      <v-spacer />
      <v-btn-toggle v-model="type" density="comfortable" variant="outlined" divided mandatory>
        <v-btn value="month" size="small"><v-icon start size="18">mdi-calendar-month</v-icon>Month</v-btn>
        <v-btn value="week" size="small"><v-icon start size="18">mdi-calendar-week</v-icon>Week</v-btn>
        <v-btn value="day" size="small"><v-icon start size="18">mdi-calendar-today</v-icon>Day</v-btn>
      </v-btn-toggle>
    </div>

    <v-card rounded="lg" variant="outlined">
      <v-sheet class="d-flex align-center pa-2">
        <v-btn icon variant="text" size="small" @click="calendar?.prev()">
          <v-icon>mdi-chevron-left</v-icon>
        </v-btn>
        <v-btn variant="text" size="small" class="me-2" @click="goToday">Today</v-btn>
        <v-btn icon variant="text" size="small" @click="calendar?.next()">
          <v-icon>mdi-chevron-right</v-icon>
        </v-btn>
        <div class="text-h6 font-weight-medium ms-2">{{ headerTitle }}</div>
        <v-spacer />
        <v-chip
          v-for="s in statusLegend"
          :key="s.status"
          size="small"
          variant="tonal"
          :color="s.color"
          class="me-1"
        >
          <template #prepend><v-icon size="10" :color="s.color">mdi-circle</v-icon></template>
          {{ s.label }}
        </v-chip>
      </v-sheet>
      <v-divider />
      <v-calendar
        ref="calendar"
        v-model="today"
        :type="type"
        :events="events"
        :event-color="getEventColor"
        event-overlap-mode="column"
        :weekdays="weekdays"
        height="650"
        @click:event="onEventClick"
      >
        <template #event="{ event }">
          <div class="pa-1 text-truncate" style="cursor:pointer">
            <div class="text-caption font-weight-bold text-truncate">{{ event.name }}</div>
            <div v-if="type !== 'month'" class="text-caption text-truncate" style="opacity:.8">
              {{ formatEventTime(event) }}
            </div>
          </div>
        </template>
      </v-calendar>
    </v-card>

    <v-dialog v-model="detailDialog" max-width="480">
      <v-card v-if="selectedWorkshop" rounded="lg">
        <v-card-item>
          <v-card-title class="text-body-1 font-weight-bold">{{ selectedWorkshop.title }}</v-card-title>
          <v-card-subtitle class="d-flex align-center ga-2 mt-1">
            <v-chip size="x-small" :color="statusColor[selectedWorkshop.status]" variant="tonal">
              {{ selectedWorkshop.status }}
            </v-chip>
            <span>{{ formatDateRange(selectedWorkshop.date_start, selectedWorkshop.date_end) }}</span>
          </v-card-subtitle>
        </v-card-item>
        <v-divider />
        <v-list density="compact" lines="two">
          <v-list-item v-if="selectedWorkshop.venue" prepend-icon="mdi-door-open">
            <v-list-item-title>{{ selectedWorkshop.venue.name }}</v-list-item-title>
            <v-list-item-subtitle>{{ selectedWorkshop.venue.venue_name }}</v-list-item-subtitle>
          </v-list-item>
          <v-list-item v-if="selectedWorkshop.client" prepend-icon="mdi-domain">
            <v-list-item-title>{{ selectedWorkshop.client.name }}</v-list-item-title>
            <v-list-item-subtitle>Client</v-list-item-subtitle>
          </v-list-item>
          <v-list-item v-if="selectedWorkshop.workshop_programs?.length" prepend-icon="mdi-book-open-variant">
            <v-list-item-title>{{ selectedWorkshop.workshop_programs.length }} program(s)</v-list-item-title>
            <v-list-item-subtitle>
              {{ selectedWorkshop.workshop_programs.map(wp => wp.program?.title).filter(Boolean).join(', ') }}
            </v-list-item-subtitle>
          </v-list-item>
        </v-list>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="detailDialog = false">Close</v-btn>
          <v-btn color="primary" :to="`/manage/workshops/${selectedWorkshop.id}`">View Workshop</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup lang="ts">
import type { WorkshopWithRelations } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { workshops } = useAdminWorkshops()

const calendar = ref()
const today = ref(new Date())
const type = ref('month')
const detailDialog = ref(false)
const selectedWorkshop = ref<WorkshopWithRelations | null>(null)

const weekdays = [0, 1, 2, 3, 4, 5, 6]

const statusColor: Record<string, string> = {
  ongoing: 'success',
  published: 'primary',
  upcoming: 'primary',
  draft: 'grey-lighten-1',
  completed: 'grey',
  cancelled: 'error',
}

const statusLegend = [
  { status: 'ongoing', label: 'Ongoing', color: 'success' },
  { status: 'upcoming', label: 'Upcoming', color: 'primary' },
  { status: 'completed', label: 'Completed', color: 'grey' },
  { status: 'cancelled', label: 'Cancelled', color: 'error' },
]

interface CalEvent {
  name: string
  start: Date
  end: Date
  color: string
  timed: boolean
  workshop: WorkshopWithRelations
}

const events = computed<CalEvent[]>(() => {
  if (!workshops.value) return []
  return workshops.value.map(w => {
    const start = new Date(w.date_start)
    const end = new Date(w.date_end)
    end.setDate(end.getDate() + 1)
    return {
      name: w.title,
      start,
      end,
      color: statusColor[w.status] || 'grey',
      timed: false,
      workshop: w,
    }
  })
})

function getEventColor(event: CalEvent) {
  return event.color
}

function onEventClick(info: any) {
  const workshop = info.event?.workshop || info.event?.workshop
  if (workshop) {
    selectedWorkshop.value = workshop
    detailDialog.value = true
  }
}

function goToday() {
  today.value = new Date()
}

function formatEventTime(event: CalEvent) {
  const opts: Intl.DateTimeFormatOptions = { hour: '2-digit', minute: '2-digit' }
  return `${event.start.toLocaleTimeString('en-US', opts)} - ${event.end.toLocaleTimeString('en-US', opts)}`
}

function formatDateRange(start: string, end: string) {
  const s = new Date(start)
  const e = new Date(end)
  const opts: Intl.DateTimeFormatOptions = { month: 'short', day: 'numeric', year: 'numeric' }
  if (s.getTime() === e.getTime()) return s.toLocaleDateString('en-US', opts)
  return `${s.toLocaleDateString('en-US', opts)} - ${e.toLocaleDateString('en-US', opts)}`
}

const headerTitle = computed(() => {
  const d = today.value
  const opts: Intl.DateTimeFormatOptions = type.value === 'month'
    ? { month: 'long', year: 'numeric' }
    : type.value === 'week'
      ? { month: 'long', year: 'numeric' }
      : { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }
  return d.toLocaleDateString('en-US', opts)
})
</script>
