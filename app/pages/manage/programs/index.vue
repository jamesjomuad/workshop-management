<template>
  <div>
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold">Programs</h1>
        <div class="text-caption text-medium-emphasis mt-1">Curriculum organized by workshop</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus" to="/manage/programs/new">
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
              <template v-if="item.workshop_date_start">
                <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">{{ monthLabel(item.workshop_date_start) }}</div>
                <div class="text-h4 font-weight-bold">{{ dayLabel(item.workshop_date_start) }}</div>
              </template>
              <template v-else>
                <v-icon size="24" class="text-medium-emphasis">mdi-calendar-blank</v-icon>
              </template>
            </div>
          </template>

          <v-card-title class="text-body-1 font-weight-bold">
            {{ item.title }}
          </v-card-title>
          <v-card-subtitle class="text-body-2">
            <v-icon size="14" class="me-1">mdi-book-open-variant</v-icon>
            {{ item.workshop_label }}
          </v-card-subtitle>

          <template #append>
            <div class="d-flex flex-column ga-2 align-end">
              <v-btn variant="text" color="primary" size="small" :to="`/manage/programs/${item.id}`">View</v-btn>
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
            <template v-if="item.workshop_date_start">
              <strong>{{ formatDate(item.workshop_date_start) }} – {{ formatDate(item.workshop_date_end) }}</strong>
              ({{ dayCount(item) }} days)
            </template>
            <template v-else>
              <span class="text-medium-emphasis">No workshop linked</span>
            </template>
          </span>
          <span>
            <v-icon size="14" class="me-1">mdi-silverware-variant</v-icon>
            <strong>{{ totalLessons(item) }}</strong> lessons
          </span>
          <span v-if="item.trainer_name">
            <v-icon size="14" class="me-1">mdi-account</v-icon>
            Trainer: <strong>{{ item.trainer_name }}</strong>
          </span>
        </div>

        <div class="pa-3 pt-0 d-flex ga-2">
          <v-chip size="x-small" :color="chipColor(item.status)" variant="tonal">
            <template #prepend v-if="item.status === 'ongoing'">
              <v-icon size="8" :color="chipColor(item.status)">mdi-circle</v-icon>
            </template>
            {{ statusLabel(item.status) }}
          </v-chip>
        </div>

        <v-divider />

        <!-- Curriculum Hierarchy -->
        <div class="pa-3">
          <v-expansion-panels variant="accordion" multiple>
            <v-expansion-panel
              v-for="section in item.sections"
              :key="section.id"
              class="mb-1"
            >
              <v-expansion-panel-title class="text-body-2 font-weight-bold" style="min-height:36px">
                <template #default="{ expanded }">
                  <v-icon size="16" class="me-2 text-medium-emphasis">
                    {{ expanded ? 'mdi-chevron-down' : 'mdi-chevron-right' }}
                  </v-icon>
                  {{ section.title }}
                </template>
              </v-expansion-panel-title>
              <v-expansion-panel-text class="py-0">
                <div
                  v-for="lesson in section.lessons"
                  :key="lesson.id"
                  class="ml-4 mb-2"
                >
                  <div class="d-flex align-center ga-2 mb-1">
                    <v-icon size="14" color="primary">mdi-play-circle-outline</v-icon>
                    <span class="text-body-2 font-weight-medium">{{ lesson.title }}</span>
                    <v-chip
                      v-if="lesson.status"
                      size="x-small"
                      :color="chipColor(lesson.status)"
                      variant="tonal"
                    >{{ statusLabel(lesson.status) }}</v-chip>
                  </div>

                  <!-- Topics -->
                  <div
                    v-for="topic in lesson.topics"
                    :key="topic.id"
                    class="ml-6 mb-1 d-flex align-center ga-2"
                  >
                    <v-icon size="12" class="text-medium-emphasis">mdi-circle-small</v-icon>
                    <span class="text-caption">{{ topic.title }}</span>
                    <v-chip
                      v-if="topic.status"
                      size="x-small"
                      :color="chipColor(topic.status)"
                      variant="tonal"
                    >{{ statusLabel(topic.status) }}</v-chip>

                    <!-- Quiz / Assignment -->
                    <template v-if="topic.quiz">
                      <v-chip
                        size="x-small"
                        :color="topic.quiz.type === 'quiz' ? 'warning' : 'info'"
                        variant="tonal"
                        :prepend-icon="topic.quiz.type === 'quiz' ? 'mdi-help-circle-outline' : 'mdi-file-document-edit-outline'"
                        class="ml-1"
                      >{{ topic.quiz.title }}</v-chip>
                    </template>
                  </div>
                </div>
              </v-expansion-panel-text>
            </v-expansion-panel>
          </v-expansion-panels>
        </div>
      </v-card>

      <div v-if="filteredPrograms.length === 0 && !pending" class="py-12 text-center text-medium-emphasis">
        <v-icon size="48" class="mb-2">mdi-book-open-variant</v-icon>
        <div class="text-body-1 font-weight-medium">No programs found</div>
        <div class="text-caption mt-1">Try adjusting the filter or create a new program</div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import type { ProgramWithRelations } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { programs: apiPrograms, pending } = useAdminPrograms()
const filter = ref('all')

const filteredPrograms = computed(() => {
  const list = apiPrograms.value ?? []
  if (filter.value === 'all') return list
  return list.filter(p => p.status === filter.value)
})

function totalLessons(p: ProgramWithRelations) {
  let count = 0
  for (const s of p.sections) count += s.lessons.length
  return count
}

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

function dayCount(item: ProgramWithRelations) {
  const start = new Date(item.workshop_date_start ?? '')
  const end = new Date(item.workshop_date_end ?? '')
  if (!item.workshop_date_start || !item.workshop_date_end) return 1
  return Math.max(1, Math.round((end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24)) + 1)
}
</script>

<style scoped>
.opacity-60 { opacity: 0.6; }
</style>
