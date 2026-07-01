<template>
  <div class="d-flex flex-column" style="height: calc(100vh - 128px)">
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold ma-0">Workshops</h1>
        <div class="text-caption text-medium-emphasis mt-1">All scheduled workshop events</div>
      </div>
      <v-spacer />
      <v-btn-toggle v-model="view" variant="outlined" divided mandatory class="me-2">
        <v-btn value="list" size="small" icon><v-icon size="18">mdi-view-list</v-icon></v-btn>
        <v-btn value="calendar" size="small" icon><v-icon size="18">mdi-calendar</v-icon></v-btn>
      </v-btn-toggle>
      <v-btn :to="'/manage/workshops/new'" color="primary" prepend-icon="mdi-plus">
        New Workshop
      </v-btn>
    </div>

    <v-chip-group
      v-model="filter"
      mandatory
      color="primary"
      class="mb-4"
    >
      <v-chip filter variant="tonal" value="all">All</v-chip>
      <v-chip filter variant="tonal" value="ongoing">Ongoing</v-chip>
      <v-chip filter variant="tonal" value="upcoming">Upcoming</v-chip>
      <v-chip filter variant="tonal" value="completed">Completed</v-chip>
      <v-chip filter variant="tonal" value="cancelled">Cancelled</v-chip>
    </v-chip-group>

    <!-- LIST VIEW -->
    <div v-if="view === 'list'" class="d-flex flex-column ga-3">
      <v-card
        v-for="item in filteredWorkshops"
        :key="item.id"
        rounded="lg"
        variant="outlined"
        :class="{ 'opacity-60': item.status === 'completed' || item.status === 'cancelled' }"
      >
        <v-card-item>
          <template #prepend>
            <div class="text-center bg-grey-lighten-4 rounded pa-3" style="min-width:60px">
              <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">{{ monthLabel(item.date_start) }}</div>
              <div class="text-h4 font-weight-bold ma-0">{{ dayLabel(item.date_start) }}</div>
            </div>
          </template>

          <v-card-title class="text-body-1 font-weight-bold">
            {{ item.title }}
          </v-card-title>
          <v-card-subtitle class="text-body-2">
            <v-icon size="14" class="me-1">mdi-hotel</v-icon>
            {{ item.conference_room?.venue_name ?? '' }} · {{ item.conference_room?.name ?? 'No room' }}
          </v-card-subtitle>

          <template #append>
            <div class="d-flex flex-column ga-2 align-end">
              <v-btn variant="text" color="primary" size="small" :to="`/manage/workshops/${item.id}`">View</v-btn>
              <v-btn icon variant="text" size="small" color="medium-emphasis" :to="`/manage/workshops/${item.id}`">
                <v-icon>mdi-monitor-dashboard</v-icon>
              </v-btn>
            </div>
          </template>
        </v-card-item>

        <v-divider />

        <div class="pa-3 d-flex ga-4 flex-wrap text-caption text-medium-emphasis">
          <span>
            <v-icon size="14" class="me-1">mdi-calendar</v-icon>
            <strong>{{ formatDate(item.date_start) }} – {{ formatDate(item.date_end) }}</strong>
            ({{ dayCount }} days)
          </span>
          <span v-if="item.facilitator_name">
            <v-icon size="14" class="me-1">mdi-account</v-icon>
            Trainer: <strong>{{ item.facilitator_name }}</strong>
          </span>
          <span v-if="item.client?.name">
            <v-icon size="14" class="me-1">mdi-domain</v-icon>
            Client: <strong>{{ item.client.name }}</strong>
          </span>
          <span>
            <v-icon size="14" class="me-1">mdi-account-group</v-icon>
            <strong>24</strong> enrolled
          </span>
        </div>

        <div class="pa-3 pt-0 d-flex ga-2">
          <v-chip size="x-small" :color="chipColor(item.status)" variant="tonal">
            <template #prepend v-if="item.status === 'ongoing' || item.status === 'published'">
              <v-icon size="8" :color="chipColor(item.status)">mdi-circle</v-icon>
            </template>
            {{ statusLabel(item.status) }}
          </v-chip>
          <v-chip size="x-small" color="primary" variant="tonal">{{ (item.workshop_programs?.length ?? 0) }} Program{{ (item.workshop_programs?.length ?? 0) !== 1 ? 's' : '' }}</v-chip>
        </div>
      </v-card>

      <div v-if="filteredWorkshops.length === 0 && !pending" class="py-12 text-center text-medium-emphasis">
        <v-icon size="48" class="mb-2">mdi-calendar-blank</v-icon>
        <div class="text-body-1 font-weight-medium">No workshops found</div>
        <div class="text-caption mt-1">Try adjusting the filter or create a new workshop</div>
      </div>
    </div>

    <!-- CALENDAR VIEW -->
    <div v-else class="d-flex flex-column flex-grow-1">
      <v-card rounded="lg" variant="outlined" class="d-flex flex-column flex-grow-1 overflow-hidden">
        <!-- Legend bar -->
        <v-sheet class="d-flex align-center pa-2 px-3" density="compact">
          <div class="d-flex align-center ga-3 text-caption">
            <div v-for="(label, key) in legendItems" :key="key" class="d-flex align-center ga-1">
              <div :style="{ width: '10px', height: '10px', borderRadius: '3px', backgroundColor: `rgb(var(--v-theme-${legendColors[key as string]}))` }" />
              <span class="text-medium-emphasis">{{ label }}</span>
            </div>
          </div>
          <v-spacer />
          <v-menu :close-on-content-click="false">
            <template #activator="{ props }">
              <v-btn
                v-bind="props"
                variant="outlined"
                size="small"
                prepend-icon="mdi-calendar"
              >
                {{ calDateFormatted }}
              </v-btn>
            </template>
            <v-date-picker
              v-model="calDate"
              color="primary"
              show-adjacent-months
              hide-header
            />
          </v-menu>
        </v-sheet>
        <v-divider />

        <!-- FullCalendar -->
        <ClientOnly>
          <FullCalendar ref="calendarRef" :options="calendarOptions" />
          <template #fallback>
            <div class="pa-8 text-center text-medium-emphasis">
              <v-progress-circular indeterminate color="primary" class="mb-3" />
              <div>Loading calendar...</div>
            </div>
          </template>
        </ClientOnly>
      </v-card>
    </div>


  </div>
</template>

<script setup lang="ts">
import type { WorkshopWithRelations } from '~/types'
import FullCalendar from '@fullcalendar/vue3'
import { classicThemePlugin, dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin } from '~/utils/fullcalendar'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { workshops, pending } = useAdminWorkshops()
const filter = ref('all')
const view = ref('list')

const filteredWorkshops = computed(() => {
  if (filter.value === 'all') return workshops.value ?? []
  return workshops.value?.filter(w => w.status === filter.value) ?? []
})

function chipColor(s: string) {
  const map: Record<string, string> = { draft: 'grey', published: 'primary', ongoing: 'success', completed: 'info', cancelled: 'error' }
  return map[s] || 'grey'
}

function statusLabel(s: string) {
  const map: Record<string, string> = { draft: 'Draft', published: 'Upcoming', ongoing: 'Ongoing', completed: 'Completed', cancelled: 'Cancelled' }
  return map[s] || s
}

function monthLabel(dateStr: string) {
  const d = new Date(dateStr)
  return d.toLocaleString('en-US', { month: 'short' }).toUpperCase()
}

function dayLabel(dateStr: string) {
  return new Date(dateStr).getDate().toString()
}

function formatDate(dateStr: string) {
  const d = new Date(dateStr)
  return d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
}

const dayCount = 3

// Calendar
const calendarRef = ref()
const calDate = ref(new Date())
const calDateFormatted = computed(() => {
  return calDate.value.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' })
})

watch(calDate, (d) => {
  const api = calendarRef.value?.getApi?.()
  if (api) api.gotoDate(d)
})

const colorMap: Record<string, string> = { draft: '#9E9E9E', published: '#F59E0B', ongoing: '#10B981', completed: '#3B82F6', cancelled: '#EF4444' }
const legendItems: Record<string, string> = { draft: 'Draft', published: 'Upcoming', ongoing: 'Ongoing', completed: 'Completed', cancelled: 'Cancelled' }
const legendColors: Record<string, string> = { draft: 'grey', published: 'primary', ongoing: 'success', completed: 'info', cancelled: 'error' }

const calEvents = computed(() => {
  if (!workshops.value) return []
  const events: any[] = []
  for (const w of workshops.value) {
    const venue = w.conference_room?.name || ''
    const schedules = w.schedules?.length
      ? w.schedules
      : [{ date_start: w.date_start, date_end: w.date_end, time_start: null, time_end: null }]

    for (const s of schedules) {
      if (!s.date_start || !s.date_end) continue
      const hasTime = s.time_start && s.time_end
      const start = hasTime
        ? `${s.date_start}T${s.time_start}`
        : s.date_start
      const endDate = new Date(s.date_end + 'T00:00:00')
      endDate.setDate(endDate.getDate() + 1)
      const end = hasTime
        ? `${s.date_end}T${s.time_end}`
        : endDate.toISOString().slice(0, 10)

      events.push({
        title: w.title,
        start,
        end,
        color: colorMap[w.status] || '#9E9E9E',
        extendedProps: { workshop: w, venue },
      })
    }
  }
  return events
})

const calendarOptions = computed(() => ({
  plugins: [classicThemePlugin, dayGridPlugin, timeGridPlugin, interactionPlugin, listPlugin],
  initialView: 'dayGridMonth',
  headerToolbar: {
    left: 'prev,next today',
    center: 'title',
    right: 'dayGridMonth,timeGridWeek,timeGridDay,listWeek',
  },
  events: calEvents.value,
  eventClick: (info: any) => {
    const workshop = info.event?.extendedProps?.workshop
    if (workshop) navigateTo(`/manage/workshops/${workshop.id}`)
  },
  height: 'auto' as const,
  nowIndicator: true,
  weekends: true,
  dayMaxEvents: 3,
  buttonText: { today: 'Today', month: 'Month', week: 'Week', day: 'Day', list: 'List' },
}))
</script>

<style scoped>
.opacity-60 { opacity: 0.6; }
:deep(.fc) { font-family: inherit; }
:deep(.fc .fc-toolbar-title) { font-size: 1.15rem; font-weight: 600; }
:deep(.fc .fc-button) { text-transform: none; font-weight: 500; }
:deep(.fc .fc-button-active) { opacity: 1; }
:deep(.fc .fc-event) { cursor: pointer; border-radius: 4px; border: none; padding: 1px 4px; }
:deep(.fc .fc-daygrid-event) { margin-bottom: 2px; }
</style>
