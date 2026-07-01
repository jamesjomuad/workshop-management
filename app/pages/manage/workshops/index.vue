<template>
  <div>
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold">Workshops</h1>
        <div class="text-caption text-medium-emphasis mt-1">All scheduled workshop events</div>
      </div>
      <v-spacer />
      <v-btn-toggle v-model="view" density="comfortable" variant="outlined" divided mandatory class="me-2">
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
              <div class="text-h4 font-weight-bold">{{ dayLabel(item.date_start) }}</div>
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
    <div v-else>
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
          <v-btn-toggle v-model="calType" density="comfortable" variant="outlined" divided mandatory>
            <v-btn value="month" size="small">Month</v-btn>
            <v-btn value="week" size="small">Week</v-btn>
            <v-btn value="day" size="small">Day</v-btn>
          </v-btn-toggle>
        </v-sheet>
        <v-divider />
        <v-calendar
          ref="calendar"
          v-model="today"
          :type="calType"
          :events="calEvents"
          :event-color="getEventColor"
          event-overlap-mode="column"
          :weekdays="[0, 1, 2, 3, 4, 5, 6]"
          height="650"
          @click:event="onEventClick"
        >
          <template #event="{ event }">
            <div class="pa-1 text-truncate" style="cursor:pointer">
              <div class="text-caption font-weight-bold text-truncate">{{ event.name }}</div>
              <div v-if="calType !== 'month'" class="text-caption text-truncate" style="opacity:.8">
                {{ formatEventTime(event) }}
              </div>
            </div>
          </template>
        </v-calendar>
      </v-card>
    </div>

    <v-dialog v-model="detailDialog" max-width="480">
      <v-card v-if="selectedWorkshop" rounded="lg">
        <v-card-item>
          <v-card-title class="text-body-1 font-weight-bold">{{ selectedWorkshop.title }}</v-card-title>
          <v-card-subtitle class="d-flex align-center ga-2 mt-1">
            <v-chip size="x-small" :color="chipColor(selectedWorkshop.status)" variant="tonal">
              {{ statusLabel(selectedWorkshop.status) }}
            </v-chip>
            <span>{{ formatDate(selectedWorkshop.date_start) }} – {{ formatDate(selectedWorkshop.date_end) }}</span>
          </v-card-subtitle>
        </v-card-item>
        <v-divider />
        <v-list density="compact" lines="two">
          <v-list-item v-if="selectedWorkshop.conference_room" prepend-icon="mdi-door-open">
            <v-list-item-title>{{ selectedWorkshop.conference_room.name }}</v-list-item-title>
            <v-list-item-subtitle>{{ selectedWorkshop.conference_room.venue_name }}</v-list-item-subtitle>
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
const calendar = ref()
const today = ref(new Date())
const calType = ref('month')
const detailDialog = ref(false)
const selectedWorkshop = ref<WorkshopWithRelations | null>(null)

interface CalEvent {
  name: string
  start: Date
  end: Date
  color: string
  timed: boolean
  workshop: WorkshopWithRelations
}

const calEvents = computed<CalEvent[]>(() => {
  if (!workshops.value) return []
  return workshops.value.map(w => {
    const start = new Date(w.date_start)
    const end = new Date(w.date_end)
    end.setDate(end.getDate() + 1)
    return {
      name: w.title,
      start,
      end,
      color: chipColor(w.status),
      timed: false,
      workshop: w,
    }
  })
})

function getEventColor(event: CalEvent) {
  return event.color
}

function onEventClick(info: any) {
  const workshop = info.event?.workshop
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

const headerTitle = computed(() => {
  const d = today.value
  const opts: Intl.DateTimeFormatOptions = calType.value === 'month'
    ? { month: 'long', year: 'numeric' }
    : calType.value === 'week'
      ? { month: 'long', year: 'numeric' }
      : { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' }
  return d.toLocaleDateString('en-US', opts)
})
</script>

<style scoped>
.opacity-60 { opacity: 0.6; }
</style>
