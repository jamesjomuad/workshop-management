<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" to="/manage/programs" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold ma-0">{{ program?.title || 'Program' }}</h1>
      <v-chip v-if="program?.deleted_at" size="small" color="grey" variant="tonal">Archived</v-chip>
      <v-spacer />
      <v-btn v-if="program?.deleted_at" color="success" variant="outlined" prepend-icon="mdi-restore" :loading="restoring" @click="onRestore">
        Restore
      </v-btn>
      <v-btn v-else color="error" variant="outlined" :loading="deleting" @click="confirmDelete">
        Delete program
      </v-btn>
      <v-btn color="primary" :loading="saving" @click="saveProgram">
        Save
      </v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-card variant="outlined" rounded="lg" class="mb-4">
          <v-card-item>
            <template #prepend>
              <v-icon color="primary" class="me-2">mdi-book-open-variant</v-icon>
              <div>
                <v-card-title class="text-body-1 font-weight-bold">Program details</v-card-title>
                <v-card-subtitle>Title and description of the curriculum</v-card-subtitle>
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text class="d-flex flex-column ga-4">
            <v-text-field v-model="editTitle" label="Program title *" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
            <v-textarea v-model="editDescription" label="Description" variant="outlined" density="comfortable" rows="2" hide-details />
          </v-card-text>
        </v-card>

        <div class="d-flex align-center mb-3">
          <h2 class="text-h6 font-weight-bold">Topics</h2>
          <v-spacer />
        </div>

        <div v-if="!localTopics.length && !addingTopic" class="py-8 text-center text-medium-emphasis">
          <v-icon size="40" class="mb-2">mdi-playlist-plus</v-icon>
          <div class="text-body-1">No topics yet</div>
          <div class="text-caption mt-1">Add a topic to start building your curriculum</div>
        </div>

        <draggable
          v-model="localTopics"
          item-key="id"
          handle=".drag-topic"
          :animation="250"
          @end="onReorderTopics"
        >
          <template #item="{ element: topic, index }">
            <div class="mb-2">
              <v-card variant="outlined" rounded="lg">
                <v-list lines="one" density="compact">
                  <v-list-item>
                    <template #prepend>
                      <v-icon class="drag-topic cursor-grab me-2 text-medium-emphasis" size="18">mdi-drag</v-icon>
                      <v-avatar size="28" color="primary" variant="tonal" class="text-body-2 font-weight-bold">{{ index + 1 }}</v-avatar>
                    </template>

                    <template v-if="editingTopic === topic.id">
                      <v-text-field v-model="editTopicTitle" variant="outlined" density="compact" hide-details class="mr-2" @keyup.enter="updateTopic(topic)" />
                    </template>
                    <template v-else>
                      <v-list-item-title class="text-body-2">
                        {{ topic.title }}
                        <v-chip v-if="topic.status" size="x-small" :color="chipColor(topic.status)" variant="tonal" class="ml-2">
                          {{ statusLabel(topic.status) }}
                        </v-chip>
                      </v-list-item-title>
                    </template>

                    <template #append>
                      <template v-if="editingTopic === topic.id">
                        <v-btn icon variant="text" size="x-small" color="primary" @click="updateTopic(topic)"><v-icon>mdi-check</v-icon></v-btn>
                        <v-btn icon variant="text" size="x-small" @click="cancelEditTopic"><v-icon>mdi-close</v-icon></v-btn>
                      </template>
                      <template v-else>
                        <v-btn icon variant="text" size="x-small" @click="startEditTopic(topic)"><v-icon size="14">mdi-pencil</v-icon></v-btn>
                        <v-btn icon variant="text" size="x-small" color="error" @click="deleteTopic(topic)"><v-icon size="14">mdi-delete</v-icon></v-btn>
                      </template>
                    </template>
                  </v-list-item>
                </v-list>
              </v-card>
            </div>
          </template>
        </draggable>

        <div v-if="addingTopic" class="d-flex align-center ga-2 mt-2">
          <v-text-field v-model="newTopicTitle" variant="outlined" density="compact" hide-details placeholder="Topic title" autofocus @keyup.enter="addTopic" />
          <v-btn color="primary" variant="tonal" :loading="savingTopic" @click="addTopic">Add</v-btn>
          <v-btn variant="text" @click="cancelAddTopic">Cancel</v-btn>
        </div>
        <v-btn v-else size="small" color="primary" variant="tonal" prepend-icon="mdi-plus" class="mt-2" @click="startAddTopic">
          Add topic
        </v-btn>
      </v-col>

      <v-col cols="12" md="4">
        <div class="d-flex flex-column ga-3" style="position:sticky;top:80px">
          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <v-card-title class="text-body-2 font-weight-bold">Summary</v-card-title>
            </v-card-item>
            <v-divider />
            <v-list density="compact">
              <v-list-item title="Topics">
                <template #subtitle>{{ topicCount }}</template>
              </v-list-item>
            </v-list>
          </v-card>

          <v-dialog v-model="deleteDialog" max-width="400">
            <v-card>
              <v-card-title class="text-body-1 font-weight-bold">Archive program?</v-card-title>
              <v-card-text>This will move the program to the archive. You can restore it later.</v-card-text>
              <v-card-actions>
                <v-spacer />
                <v-btn variant="text" @click="deleteDialog = false">Cancel</v-btn>
                <v-btn color="error" :loading="deleting" @click="doDelete">Archive</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>
        </div>
      </v-col>
    </v-row>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script setup lang="ts">
import type { ProgramTopic } from '~/types'
import draggable from 'vuedraggable'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const route = useRoute()
const router = useRouter()
const id = route.params.id as string

const {
  programs, pending, refresh,
  updateProgram, deleteProgram, restoreProgram,
  createTopic: apiCreateTopic, updateTopic: apiUpdateTopic, deleteTopic: apiDeleteTopic,
  reorderTopics,
} = useAdminPrograms()

const program = computed(() => (programs.value ?? []).find(p => p.id === id))

const localTopics = ref<ProgramTopic[]>([])

watch(() => program.value?.topics, (topics) => {
  localTopics.value = topics ? [...topics] : []
}, { immediate: true })

const editTitle = ref('')
const editDescription = ref('')
const saving = ref(false)
const deleting = ref(false)
const restoring = ref(false)
const deleteDialog = ref(false)
const formRef = ref<VForm>()
const required = [(v: any) => !!v || 'Required']

watch(program, (p) => {
  if (p) {
    editTitle.value = p.title
    editDescription.value = p.description ?? ''
  }
}, { immediate: true })

const addingTopic = ref(false)
const newTopicTitle = ref('')
const savingTopic = ref(false)
const editingTopic = ref<string | null>(null)
const editTopicTitle = ref('')

function chipColor(s: string) {
  const map: Record<string, string> = { ongoing: 'success', upcoming: 'warning', completed: 'info' }
  return map[s] || 'grey'
}

function statusLabel(s: string) {
  const map: Record<string, string> = { ongoing: 'Ongoing', upcoming: 'Upcoming', completed: 'Completed' }
  return map[s] || s
}

const topicCount = computed(() => program.value?.topics?.length ?? 0)

async function saveProgram() {
  saving.value = true
  try {
    await updateProgram(id, {
      title: editTitle.value,
      description: editDescription.value || null,
    })
    snackbar.value = { show: true, text: 'Program updated', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    saving.value = false
  }
}

function confirmDelete() {
  deleteDialog.value = true
}

async function doDelete() {
  deleting.value = true
  try {
    await deleteProgram(id)
    snackbar.value = { show: true, text: 'Program deleted', color: 'success' }
    setTimeout(() => router.push('/manage/programs'), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    deleting.value = false
    deleteDialog.value = false
  }
}

async function onRestore() {
  restoring.value = true
  try {
    await restoreProgram(id)
    snackbar.value = { show: true, text: 'Program restored', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    restoring.value = false
  }
}

async function onReorderTopics() {
  const ids = localTopics.value.map(t => t.id)
  await reorderTopics(ids)
}

function startAddTopic() {
  addingTopic.value = true
  newTopicTitle.value = ''
}

function cancelAddTopic() {
  addingTopic.value = false
  newTopicTitle.value = ''
}

async function addTopic() {
  if (!newTopicTitle.value.trim()) return
  savingTopic.value = true
  try {
    const sort = (program.value?.topics?.length ?? 0) + 1
    await apiCreateTopic({ program_id: id, title: newTopicTitle.value.trim(), sort_order: sort })
    addingTopic.value = false
    newTopicTitle.value = ''
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    savingTopic.value = false
  }
}

function startEditTopic(topic: ProgramTopic) {
  editingTopic.value = topic.id
  editTopicTitle.value = topic.title
}

function cancelEditTopic() {
  editingTopic.value = null
}

async function updateTopic(topic: ProgramTopic) {
  if (!editTopicTitle.value.trim()) return
  try {
    await apiUpdateTopic(topic.id, { title: editTopicTitle.value.trim() })
    editingTopic.value = null
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

async function deleteTopic(topic: ProgramTopic) {
  try {
    await apiDeleteTopic(topic.id)
    snackbar.value = { show: true, text: 'Topic deleted', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>

<style scoped>
.cursor-grab { cursor: grab; }
.cursor-grab:active { cursor: grabbing; }
</style>
