<template>
  <div>
    <div class="d-flex mb-1 text-caption text-medium-emphasis">
      {{ currentDate }}
    </div>

    <v-row class="mb-4">
      <v-col v-for="stat in statCards" :key="stat.label" cols="12" sm="6" md="4">
        <v-card rounded="lg" variant="outlined" class="pa-4">
          <v-icon :color="stat.color" class="mb-2" size="36">{{ stat.icon }}</v-icon>
          <div class="text-caption text-medium-emphasis mb-1">{{ stat.label }}</div>
          <div class="text-h3 font-weight-bold">{{ stat.value }}</div>
          <div :class="stat.deltaClass" class="text-caption mt-1">{{ stat.delta }}</div>
        </v-card>
      </v-col>
    </v-row>

    <v-row class="mb-4">
      <v-col cols="12" md="7">
        <v-card rounded="lg" variant="outlined">
          <v-card-item>
            <v-card-title class="text-h6">Schedule</v-card-title>
            <v-card-subtitle>{{ headerTitle }}</v-card-subtitle>
            <template #append>
              <v-btn variant="text" size="small" color="primary" to="/manage/workshops">View all workshops</v-btn>
            </template>
          </v-card-item>
          <v-divider />
          <v-calendar
            ref="miniCal"
            v-model="today"
            type="month"
            :events="events"
            :event-color="getEventColor"
            :weekdays="[0, 1, 2, 3, 4, 5, 6]"
            height="340"
            @click:event="onEventClick"
          />
        </v-card>
      </v-col>

      <v-col cols="12" md="5">
        <v-card rounded="lg" variant="outlined">
          <v-card-item>
            <v-card-title class="text-h6">Upcoming Workshops</v-card-title>
          </v-card-item>
          <v-divider />
          <v-list v-if="upcomingWorkshops.length" lines="two" density="compact">
            <v-list-item
              v-for="w in upcomingWorkshops"
              :key="w.id"
              :to="`/manage/workshops/${w.id}`"
            >
              <template #prepend>
                <v-avatar size="36" :color="statusColor[w.status]" variant="tonal" class="me-3">
                  <v-icon size="18">mdi-calendar-text</v-icon>
                </v-avatar>
              </template>
              <v-list-item-title class="font-weight-medium">{{ w.title }}</v-list-item-title>
              <v-list-item-subtitle>
                {{ formatShortDate(w.date_start) }} · {{ w.venue?.name || 'No venue' }}
              </v-list-item-subtitle>
              <template #append>
                <v-chip size="x-small" :color="statusColor[w.status]" variant="tonal">{{ w.status }}</v-chip>
              </template>
            </v-list-item>
          </v-list>
          <v-card-text v-else class="text-center text-medium-emphasis">
            No upcoming workshops
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
import type { WorkshopWithRelations } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { workshops } = useAdminWorkshops()

const today = ref(new Date())
const miniCal = ref()

const currentDate = new Date().toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })

const statusColor: Record<string, string> = {
  ongoing: 'success',
  published: 'primary',
  upcoming: 'primary',
  draft: 'grey-lighten-1',
  completed: 'grey',
  cancelled: 'error',
}

const activeWorkshops = computed(() => {
  if (!workshops.value) return []
  return workshops.value.filter(w => ['ongoing', 'published'].includes(w.status))
})

const upcomingWorkshops = computed(() => {
  if (!workshops.value) return []
  const now = new Date()
  return workshops.value
    .filter(w => w.status === 'published' || (w.status === 'draft' && new Date(w.date_start) > now))
    .sort((a, b) => new Date(a.date_start).getTime() - new Date(b.date_start).getTime())
    .slice(0, 5)
})

const statCards = computed(() => [
  {
    label: 'Active Workshops',
    value: String(activeWorkshops.value.length),
    icon: 'mdi-notebook',
    color: 'primary',
    delta: `${workshops.value?.length ?? 0} total`,
    deltaClass: 'text-medium-emphasis text-caption',
  },
  {
    label: 'Total Workshops',
    value: String(workshops.value?.length ?? 0),
    icon: 'mdi-calendar-multiple',
    color: 'secondary',
    delta: `${upcomingWorkshops.value.length} upcoming`,
    deltaClass: 'text-medium-emphasis text-caption',
  },
  {
    label: 'Status',
    value: activeWorkshops.value.length ? 'Active' : 'Idle',
    icon: 'mdi-check-circle',
    color: activeWorkshops.value.length ? 'success' : 'grey',
    delta: activeWorkshops.value.length ? 'Workshops running' : 'No active workshops',
    deltaClass: activeWorkshops.value.length ? 'text-success text-caption' : 'text-medium-emphasis text-caption',
  },
])

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
  const workshop = info.event?.workshop
  if (workshop) navigateTo(`/manage/workshops/${workshop.id}`)
}

function formatShortDate(date: string) {
  return new Date(date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })
}

const headerTitle = computed(() => {
  return today.value.toLocaleDateString('en-US', { month: 'long', year: 'numeric' })
})
</script>
