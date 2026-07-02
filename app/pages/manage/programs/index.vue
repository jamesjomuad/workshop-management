<template>
  <div>
    <div class="d-flex align-center mb-4 flex-wrap ga-3">
      <div>
        <h1 class="text-h4 font-weight-bold ma-0">Programs</h1>
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
      <v-chip filter variant="tonal" value="archived">Archived</v-chip>
    </v-chip-group>

    <div class="d-flex flex-column ga-3">
      <draggable
        v-model="sortedPrograms"
        item-key="id"
        handle=".drag-handle"
        :animation="250"
        class="d-flex flex-column ga-3"
        @end="onReorderPrograms"
      >
        <template #item="{ element: item }">
          <v-card
            rounded="lg"
            variant="outlined"
            :class="{ 'opacity-60': item.status === 'completed' }"
          >
            <v-card-item>
              <template #prepend>
                <div class="d-flex align-center ga-3">
                  <v-icon class="drag-handle cursor-grab text-medium-emphasis" size="20">mdi-drag</v-icon>
                  <div class="text-center bg-grey-lighten-4 rounded pa-3" style="min-width:60px">
                    <template v-if="item.workshop_date_start">
                      <div class="text-caption font-weight-bold text-medium-emphasis text-uppercase">{{ monthLabel(item.workshop_date_start) }}</div>
                      <div class="text-h4 font-weight-bold ma-0">{{ dayLabel(item.workshop_date_start) }}</div>
                    </template>
                    <template v-else>
                      <v-icon size="24" class="text-medium-emphasis">mdi-calendar-blank</v-icon>
                    </template>
                  </div>
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
                  <v-btn
                    v-if="item.deleted_at"
                    variant="text"
                    color="success"
                    size="small"
                    prepend-icon="mdi-restore"
                    @click="onRestore(item)"
                  >Restore</v-btn>
                  <v-btn
                    v-else
                    icon
                    variant="text"
                    size="small"
                    color="error"
                    @click="confirmDelete(item)"
                  >
                    <v-icon>mdi-delete-outline</v-icon>
                    <v-tooltip activator="parent" location="top">Delete</v-tooltip>
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
                <v-icon size="14" class="me-1">mdi-order-bool-ascending</v-icon>
                <strong>{{ item.topics?.length ?? 0 }}</strong> topics
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
              <v-chip v-if="item.deleted_at" size="x-small" color="grey" variant="tonal">
                Archived
              </v-chip>
            </div>

            <template v-if="item.topics?.length">
              <v-divider />
              <div class="pa-3">
                <div
                  v-for="topic in item.topics"
                  :key="topic.id"
                  class="d-flex align-center ga-2 mb-1"
                >
                  <v-icon size="12" class="text-medium-emphasis">mdi-circle-small</v-icon>
                  <span class="text-caption">{{ topic.title }}</span>
                  <v-chip
                    v-if="topic.status"
                    size="x-small"
                    :color="chipColor(topic.status)"
                    variant="tonal"
                  >{{ statusLabel(topic.status) }}</v-chip>
                </div>
              </div>
            </template>
          </v-card>
        </template>

        <template #footer v-if="sortedPrograms.length === 0 && !pending">
          <div class="py-12 text-center text-medium-emphasis">
            <v-icon size="48" class="mb-2">mdi-book-open-variant</v-icon>
            <div class="text-body-1 font-weight-medium">No programs found</div>
            <div class="text-caption mt-1">Try adjusting the filter or create a new program</div>
          </div>
        </template>
      </draggable>
    </div>

    <v-dialog v-model="deleteDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-h6 font-weight-bold">Delete Program</v-card-title>
        <v-card-text>Are you sure you want to delete <strong>{{ deleteTarget?.title }}</strong>? It will be moved to the archive.</v-card-text>
        <v-card-actions>
          <v-spacer />
          <v-btn variant="text" @click="deleteDialog = false">Cancel</v-btn>
          <v-btn color="error" variant="flat" :loading="deleting" @click="onDelete">Delete</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>
  </div>
</template>

<script setup lang="ts">
import type { ProgramWithRelations } from '~/types'
import draggable from 'vuedraggable'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { programs: apiPrograms, pending, reorderPrograms, deleteProgram, restoreProgram } = useAdminPrograms()
const filter = ref('all')
const deleteDialog = ref(false)
const deleteTarget = ref<ProgramWithRelations | null>(null)
const deleting = ref(false)

const activePrograms = ref<ProgramWithRelations[]>([])
const archivedPrograms = ref<ProgramWithRelations[]>([])
const sortedPrograms = ref<ProgramWithRelations[]>([])

watch(apiPrograms, (list) => {
  activePrograms.value = list ?? []
}, { immediate: true })

watchEffect(async () => {
  if (filter.value === 'archived') {
    const data = await $fetch<ProgramWithRelations[]>('/api/admin/programs', { query: { archived: 'true' } })
    archivedPrograms.value = data.filter(p => p.deleted_at)
  }
})

watch([filter, activePrograms, archivedPrograms], () => {
  if (filter.value === 'archived') {
    sortedPrograms.value = archivedPrograms.value
  } else if (filter.value === 'all') {
    sortedPrograms.value = activePrograms.value
  } else {
    sortedPrograms.value = activePrograms.value.filter(p => p.status === filter.value)
  }
}, { immediate: true })

async function onReorderPrograms() {
  activePrograms.value = sortedPrograms.value
  const ids = sortedPrograms.value.map(p => p.id)
  await reorderPrograms(ids)
}

function confirmDelete(item: ProgramWithRelations) {
  deleteTarget.value = item
  deleteDialog.value = true
}

async function onDelete() {
  if (!deleteTarget.value) return
  deleting.value = true
  await deleteProgram(deleteTarget.value.id)
  deleting.value = false
  deleteDialog.value = false
  deleteTarget.value = null
}

async function onRestore(item: ProgramWithRelations) {
  await restoreProgram(item.id)
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
.cursor-grab { cursor: grab; }
.cursor-grab:active { cursor: grabbing; }
</style>
