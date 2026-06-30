<template>
  <div>
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold">Programs & Sessions</h1>
        <div class="text-caption text-medium-emphasis mt-1">Curriculum organized by workshop</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus">
        New Program
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
    </v-chip-group>

    <div class="d-flex flex-column ga-3">
      <v-card
        v-for="item in filteredPrograms"
        :key="item.id"
        rounded="lg"
        variant="outlined"
        :class="{ 'opacity-60': item.status === 'completed' }"
      >
        <v-card-item>
          <template #prepend>
            <div class="text-center bg-grey-lighten-4 rounded pa-3" style="min-width:60px">
              <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">{{ monthLabel(item.date_start) }}</div>
              <div class="text-h4 font-weight-bold">{{ dayLabel(item.date_start) }}</div>
            </div>
          </template>

          <v-card-title class="text-body-1 font-weight-bold">
            {{ item.name }}
          </v-card-title>
          <v-card-subtitle class="text-body-2">
            <v-icon size="14" class="me-1">mdi-book-open-variant</v-icon>
            {{ item.workshopLabel }}
          </v-card-subtitle>

          <template #append>
            <div class="d-flex flex-column ga-2 align-end">
              <v-btn variant="text" color="primary" size="small">View</v-btn>
              <v-btn icon variant="text" size="small" color="medium-emphasis">
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
            ({{ dayCount(item) }} days)
          </span>
          <span>
            <v-icon size="14" class="me-1">mdi-silverware-variant</v-icon>
            <strong>{{ item.sessionCount }}</strong> sessions
          </span>
          <span v-if="item.trainer">
            <v-icon size="14" class="me-1">mdi-account</v-icon>
            Trainer: <strong>{{ item.trainer }}</strong>
          </span>
        </div>

        <div class="pa-3 pt-0 d-flex ga-2">
          <v-chip size="x-small" :color="chipColor(item.status)" variant="tonal">
            <template #prepend v-if="item.status === 'ongoing'">
              <v-icon size="8" :color="chipColor(item.status)">mdi-circle</v-icon>
            </template>
            {{ statusLabel(item.status) }}
          </v-chip>
          <v-chip size="x-small" color="primary" variant="tonal">{{ item.sessions.length }} sessions</v-chip>
        </div>
      </v-card>

      <div v-if="filteredPrograms.length === 0" class="py-12 text-center text-medium-emphasis">
        <v-icon size="48" class="mb-2">mdi-book-open-variant</v-icon>
        <div class="text-body-1 font-weight-medium">No programs found</div>
        <div class="text-caption mt-1">Try adjusting the filter or create a new program</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

interface SessionItem {
  id: string
  day: string
  title: string
  time: string
  status: 'completed' | 'ongoing' | 'upcoming'
  statusLabel: string
}

interface ProgramItem {
  id: string
  workshopLabel: string
  name: string
  date_start: string
  date_end: string
  sessionCount: number
  status: 'completed' | 'ongoing' | 'upcoming'
  statusColor: string
  statusLabel: string
  trainer?: string
  sessions: SessionItem[]
}

const programs: ProgramItem[] = [
  {
    id: '1',
    workshopLabel: 'PM Workshop — Batch 4',
    name: 'Project Management Fundamentals',
    date_start: '2026-06-24',
    date_end: '2026-06-27',
    sessionCount: 8,
    status: 'ongoing',
    statusColor: 'success',
    statusLabel: 'Ongoing',
    trainer: 'Sarah Mitchell',
    sessions: [
      { id: 's1', day: 'Day 1', title: 'Module 1 — Project Planning', time: '08:00 – 12:00', status: 'completed', statusLabel: 'Done' },
      { id: 's2', day: 'Day 1', title: 'Module 2 — Scope & WBS', time: '13:00 – 17:00', status: 'completed', statusLabel: 'Done' },
      { id: 's3', day: 'Day 2', title: 'Module 3 — Risk Management', time: '08:00 – 12:00', status: 'ongoing', statusLabel: 'Ongoing' },
      { id: 's4', day: 'Day 2', title: 'Module 4 — Scheduling', time: '13:00 – 17:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's5', day: 'Day 3', title: 'Module 5 — Cost Estimation', time: '08:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
  {
    id: '2',
    workshopLabel: 'Safety Training — June',
    name: 'Workplace Safety & Compliance',
    date_start: '2026-06-25',
    date_end: '2026-06-26',
    sessionCount: 4,
    status: 'ongoing',
    statusColor: 'success',
    statusLabel: 'Ongoing',
    trainer: 'James Chen',
    sessions: [
      { id: 's6', day: 'Day 1', title: 'Safety Regulations Overview', time: '08:00 – 11:00', status: 'completed', statusLabel: 'Done' },
      { id: 's7', day: 'Day 1', title: 'Hazard Identification', time: '13:00 – 17:00', status: 'ongoing', statusLabel: 'Ongoing' },
      { id: 's8', day: 'Day 2', title: 'Emergency Response', time: '08:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's9', day: 'Day 2', title: 'Practical Assessment', time: '13:00 – 16:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
  {
    id: '3',
    workshopLabel: 'Leadership Series — July',
    name: 'Effective Leadership & Team Building',
    date_start: '2026-07-07',
    date_end: '2026-07-09',
    sessionCount: 6,
    status: 'upcoming',
    statusColor: 'warning',
    statusLabel: 'Upcoming',
    trainer: 'Emily Rodriguez',
    sessions: [
      { id: 's10', day: 'Day 1', title: 'Leadership Styles', time: '09:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's11', day: 'Day 1', title: 'Communication & Influence', time: '13:00 – 17:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
]

const filter = ref('all')

const filteredPrograms = computed(() => {
  if (filter.value === 'all') return programs
  return programs.filter(p => p.status === filter.value)
})

function chipColor(s: string) {
  const map: Record<string, string> = { ongoing: 'success', upcoming: 'warning', completed: 'info' }
  return map[s] || 'grey'
}

function statusLabel(s: string) {
  const map: Record<string, string> = { ongoing: 'Ongoing', upcoming: 'Upcoming', completed: 'Completed' }
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

function dayCount(item: ProgramItem) {
  const start = new Date(item.date_start)
  const end = new Date(item.date_end)
  return Math.max(1, Math.round((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1)
}
</script>

<style scoped>
.opacity-60 { opacity: 0.6; }
</style>
