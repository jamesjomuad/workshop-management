<template>
  <div>
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold">Workshops</h1>
        <div class="text-caption text-medium-emphasis mt-1">All scheduled workshop events</div>
      </div>
      <v-spacer />
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

    <div class="d-flex flex-column ga-3">
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
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { workshops, pending } = useAdminWorkshops()
const filter = ref('all')

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
</script>

<style scoped>
.opacity-60 { opacity: 0.6; }
</style>
