<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" to="/manage/programs" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">{{ program?.title || 'Program' }}</h1>
      <v-spacer />
      <v-btn color="error" variant="outlined" :loading="deleting" @click="confirmDelete">
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
              </div>
            </template>
          </v-card-item>
          <v-divider />
          <v-card-text class="d-flex flex-column ga-4">
            <v-text-field v-model="editTitle" label="Title *" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
            <v-textarea v-model="editDescription" label="Description" variant="outlined" density="comfortable" rows="2" hide-details />
          </v-card-text>
        </v-card>

        <div class="d-flex align-center mb-3">
          <h2 class="text-h6 font-weight-bold">Curriculum</h2>
          <v-spacer />
          <v-btn size="small" color="primary" variant="tonal" prepend-icon="mdi-plus" @click="addingSection = true">
            Section
          </v-btn>
        </div>

        <v-expand-transition>
          <v-card v-if="addingSection" variant="outlined" rounded="lg" class="mb-3">
            <v-card-text class="d-flex align-center ga-2 pa-3">
              <v-text-field v-model="newSectionTitle" label="Section title" variant="outlined" density="compact" hide-details autofocus @keyup.enter="addSection" />
              <v-btn color="primary" variant="tonal" :loading="savingSection" @click="addSection">Add</v-btn>
              <v-btn variant="text" @click="cancelAddSection">Cancel</v-btn>
            </v-card-text>
          </v-card>
        </v-expand-transition>

        <div v-if="!program?.sections?.length && !addingSection" class="py-8 text-center text-medium-emphasis">
          <v-icon size="40" class="mb-2">mdi-file-tree</v-icon>
          <div class="text-body-1">No sections yet</div>
          <div class="text-caption mt-1">Add a section to start building your curriculum</div>
        </div>

        <draggable
          v-model="localSections"
          item-key="id"
          handle=".drag-section"
          :animation="250"
          @end="onReorderSections"
        >
          <template #item="{ element: section, index: si }">
            <div class="mb-3">
              <v-card variant="outlined" rounded="lg">
                <v-card-item>
                  <template #prepend>
                    <v-icon class="drag-section cursor-grab me-2 text-medium-emphasis" size="18">mdi-drag</v-icon>
                    <v-avatar size="28" color="primary" variant="tonal" class="text-body-2 font-weight-bold">{{ si + 1 }}</v-avatar>
                  </template>

                  <template v-if="editingSection === section.id">
                    <v-text-field v-model="editSectionTitle" variant="outlined" density="compact" hide-details class="mr-2" @keyup.enter="updateSection(section)" />
                  </template>
                  <template v-else>
                    <v-card-title class="text-body-1 font-weight-bold">{{ section.title }}</v-card-title>
                  </template>

                  <template #append>
                    <template v-if="editingSection === section.id">
                      <v-btn icon variant="text" size="small" color="primary" @click="updateSection(section)"><v-icon>mdi-check</v-icon></v-btn>
                      <v-btn icon variant="text" size="small" @click="cancelEditSection"><v-icon>mdi-close</v-icon></v-btn>
                    </template>
                    <template v-else>
                      <v-btn icon variant="text" size="small" @click="startEditSection(section)"><v-icon>mdi-pencil</v-icon></v-btn>
                      <v-btn icon variant="text" size="small" color="error" @click="deleteSection(section)"><v-icon>mdi-delete</v-icon></v-btn>
                    </template>
                  </template>
                </v-card-item>

                <v-divider />

                <draggable
                  v-model="section.lessons"
                  item-key="id"
                  handle=".drag-lesson"
                  :animation="250"
                  group="lessons"
                  @end="onReorderLessons"
                >
                  <template #item="{ element: lesson, index: li }">
                    <v-list lines="one" density="compact">
                      <v-list-item>
                        <template #prepend>
                          <v-icon class="drag-lesson cursor-grab me-1 text-medium-emphasis" size="14">mdi-drag</v-icon>
                          <v-icon size="14" color="primary" class="me-2">mdi-play-circle-outline</v-icon>
                        </template>

                        <template v-if="editingLesson === lesson.id">
                          <v-text-field v-model="editLessonTitle" variant="outlined" density="compact" hide-details class="mr-2" @keyup.enter="updateLesson(lesson)" />
                        </template>
                        <template v-else>
                          <v-list-item-title class="text-body-2">
                            {{ lesson.title }}
                            <v-chip v-if="lesson.status" size="x-small" :color="chipColor(lesson.status)" variant="tonal" class="ml-2">
                              {{ statusLabel(lesson.status) }}
                            </v-chip>
                          </v-list-item-title>
                        </template>

                        <template #append>
                          <template v-if="editingLesson === lesson.id">
                            <v-btn icon variant="text" size="x-small" color="primary" @click="updateLesson(lesson)"><v-icon>mdi-check</v-icon></v-btn>
                            <v-btn icon variant="text" size="x-small" @click="cancelEditLesson"><v-icon>mdi-close</v-icon></v-btn>
                          </template>
                          <template v-else>
                            <v-btn icon variant="text" size="x-small" @click="startEditLesson(lesson)"><v-icon size="14">mdi-pencil</v-icon></v-btn>
                            <v-btn icon variant="text" size="x-small" color="error" @click="deleteLesson(lesson)"><v-icon size="14">mdi-delete</v-icon></v-btn>
                          </template>
                        </template>

                        <template #subtitle>
                          <template v-if="lesson.topics?.length">
                            <draggable
                              v-model="lesson.topics"
                              item-key="id"
                              handle=".drag-topic"
                              :animation="250"
                              group="topics"
                              @end="onReorderTopics"
                            >
                              <template #item="{ element: topic, index: ti }">
                                <div class="ml-6 mt-1 d-flex align-center ga-1">
                                  <v-icon class="drag-topic cursor-grab text-medium-emphasis" size="10">mdi-drag-vertical</v-icon>
                                  <v-icon size="10" class="text-medium-emphasis">mdi-circle-small</v-icon>

                                  <template v-if="editingTopic === topic.id">
                                    <v-text-field v-model="editTopicTitle" variant="plain" density="compact" hide-details class="mr-1" style="max-width:200px" @keyup.enter="updateTopic(topic)" />
                                  </template>
                                  <template v-else>
                                    <span class="text-caption">{{ topic.title }}</span>
                                    <v-chip v-if="topic.status" size="x-small" :color="chipColor(topic.status)" variant="tonal" class="ml-1">{{ statusLabel(topic.status) }}</v-chip>
                                  </template>

                                  <template v-if="editingTopic === topic.id">
                                    <v-btn icon variant="text" size="x-small" color="primary" @click="updateTopic(topic)"><v-icon size="12">mdi-check</v-icon></v-btn>
                                    <v-btn icon variant="text" size="x-small" @click="cancelEditTopic"><v-icon size="12">mdi-close</v-icon></v-btn>
                                  </template>
                                  <template v-else>
                                    <v-btn icon variant="text" size="x-small" @click="startEditTopic(topic)"><v-icon size="12">mdi-pencil</v-icon></v-btn>
                                    <v-btn icon variant="text" size="x-small" color="error" @click="deleteTopic(topic)"><v-icon size="12">mdi-delete</v-icon></v-btn>
                                  </template>

                                  <template v-if="topic.quiz">
                                    <v-chip size="x-small" :color="topic.quiz.type === 'quiz' ? 'warning' : 'info'" variant="tonal" class="ml-1">
                                      <template #prepend>
                                        <v-icon size="10">{{ topic.quiz.type === 'quiz' ? 'mdi-help-circle-outline' : 'mdi-file-document-edit-outline' }}</v-icon>
                                      </template>
                                      {{ topic.quiz.title }}
                                      <v-btn icon variant="text" size="x-small" color="error" class="ml-1" @click.stop="deleteQuiz(topic.quiz!)">
                                        <v-icon size="10">mdi-close</v-icon>
                                      </v-btn>
                                    </v-chip>
                                  </template>
                                  <template v-else>
                                    <v-btn size="x-small" variant="text" color="warning" class="ml-1" @click="startAddQuiz(topic)">
                                      <v-icon size="12">mdi-help-circle-outline</v-icon>
                                    </v-btn>
                                  </template>
                                </div>
                              </template>
                            </draggable>
                          </template>

                          <div v-if="addingTopicLesson === lesson.id" class="d-flex align-center ga-1 ml-4 mt-1">
                            <v-text-field v-model="newTopicTitle" variant="outlined" density="compact" hide-details placeholder="Topic title" style="max-width:200px" @keyup.enter="addTopic(lesson)" />
                            <v-btn size="x-small" color="primary" variant="tonal" :loading="savingTopic" @click="addTopic(lesson)">Add</v-btn>
                            <v-btn size="x-small" variant="text" @click="cancelAddTopic">Cancel</v-btn>
                          </div>
                          <v-btn v-else size="x-small" variant="text" color="primary" class="ml-6 mt-1" @click="startAddTopic(lesson)">
                            <v-icon size="12" class="me-1">mdi-plus</v-icon>
                            <span class="text-caption">Topic</span>
                          </v-btn>
                        </template>
                      </v-list-item>
                    </v-list>
                  </template>
                </draggable>

                <v-divider />

                <div v-if="addingLessonSection === section.id" class="pa-3 d-flex align-center ga-2">
                  <v-text-field v-model="newLessonTitle" label="Lesson title" variant="outlined" density="compact" hide-details autofocus @keyup.enter="addLesson(section)" />
                  <v-btn color="primary" variant="tonal" :loading="savingLesson" @click="addLesson(section)">Add</v-btn>
                  <v-btn variant="text" @click="cancelAddLesson">Cancel</v-btn>
                </div>
                <v-btn v-else variant="text" size="small" color="primary" class="ma-2" prepend-icon="mdi-plus" @click="startAddLesson(section)">
                  Lesson
                </v-btn>
              </v-card>
            </div>
          </template>
        </draggable>
      </v-col>

      <v-col cols="12" md="4">
        <div class="d-flex flex-column ga-3" style="position:sticky;top:80px">
          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <v-card-title class="text-body-2 font-weight-bold">Summary</v-card-title>
            </v-card-item>
            <v-divider />
            <v-list density="compact">
              <v-list-item title="Sections">
                <template #subtitle>{{ sectionCount }}</template>
              </v-list-item>
              <v-list-item title="Lessons">
                <template #subtitle>{{ lessonCount }}</template>
              </v-list-item>
              <v-list-item title="Topics">
                <template #subtitle>{{ topicCount }}</template>
              </v-list-item>
            </v-list>
          </v-card>

          <v-dialog v-model="quizDialog" max-width="400">
            <v-card>
              <v-card-title class="text-body-1 font-weight-bold">Add Quiz / Assignment</v-card-title>
              <v-card-text class="d-flex flex-column ga-3 pt-3">
                <v-text-field v-model="quizForm.title" label="Title *" :rules="required" variant="outlined" density="comfortable" hide-details="auto" />
                <v-select v-model="quizForm.type" label="Type" :items="[{ title: 'Quiz', value: 'quiz' }, { title: 'Assignment', value: 'assignment' }]" variant="outlined" density="comfortable" hide-details />
              </v-card-text>
              <v-card-actions>
                <v-spacer />
                <v-btn variant="text" @click="quizDialog = false">Cancel</v-btn>
                <v-btn color="primary" :loading="savingQuiz" @click="addQuiz">Save</v-btn>
              </v-card-actions>
            </v-card>
          </v-dialog>

          <v-dialog v-model="deleteDialog" max-width="400">
            <v-card>
              <v-card-title class="text-body-1 font-weight-bold">Delete program?</v-card-title>
              <v-card-text>This will permanently delete the program and all its sections, lessons, topics, and quizzes. This action cannot be undone.</v-card-text>
              <v-card-actions>
                <v-spacer />
                <v-btn variant="text" @click="deleteDialog = false">Cancel</v-btn>
                <v-btn color="error" :loading="deleting" @click="doDelete">Delete</v-btn>
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
import type { ProgramSection, ProgramLesson, ProgramTopic, ProgramQuiz } from '~/types'
import draggable from 'vuedraggable'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const route = useRoute()
const router = useRouter()
const id = route.params.id as string

const {
  programs, pending, refresh,
  updateProgram, deleteProgram,
  createSection: apiCreateSection, updateSection: apiUpdateSection, deleteSection: apiDeleteSection,
  createLesson: apiCreateLesson, updateLesson: apiUpdateLesson, deleteLesson: apiDeleteLesson,
  createTopic: apiCreateTopic, updateTopic: apiUpdateTopic, deleteTopic: apiDeleteTopic,
  createQuiz: apiCreateQuiz, deleteQuiz: apiDeleteQuiz,
  reorderSections, reorderLessons, reorderTopics,
} = useAdminPrograms()

const program = computed(() => (programs.value ?? []).find(p => p.id === id))

const localSections = computed({
  get: () => program.value?.sections ?? [],
  set: () => {},
})

const editTitle = ref('')
const editDescription = ref('')
const saving = ref(false)
const deleting = ref(false)
const deleteDialog = ref(false)
const formRef = ref<VForm>()
const required = [(v: any) => !!v || 'Required']

watch(program, (p) => {
  if (p) {
    editTitle.value = p.title
    editDescription.value = p.description ?? ''
  }
}, { immediate: true })

const addingSection = ref(false)
const newSectionTitle = ref('')
const savingSection = ref(false)
const editingSection = ref<string | null>(null)
const editSectionTitle = ref('')

const addingLessonSection = ref<string | null>(null)
const newLessonTitle = ref('')
const savingLesson = ref(false)
const editingLesson = ref<string | null>(null)
const editLessonTitle = ref('')

const addingTopicLesson = ref<string | null>(null)
const newTopicTitle = ref('')
const savingTopic = ref(false)
const editingTopic = ref<string | null>(null)
const editTopicTitle = ref('')

const quizDialog = ref(false)
const quizTopic = ref<ProgramTopic | null>(null)
const quizForm = reactive({ title: '', type: 'quiz' })
const savingQuiz = ref(false)

function chipColor(s: string) {
  const map: Record<string, string> = { ongoing: 'success', upcoming: 'warning', completed: 'info' }
  return map[s] || 'grey'
}

function statusLabel(s: string) {
  const map: Record<string, string> = { ongoing: 'Ongoing', upcoming: 'Upcoming', completed: 'Completed' }
  return map[s] || s
}

const sectionCount = computed(() => program.value?.sections?.length ?? 0)
const lessonCount = computed(() => {
  if (!program.value?.sections) return 0
  return program.value.sections.reduce((sum, s) => sum + (s.lessons?.length ?? 0), 0)
})
const topicCount = computed(() => {
  if (!program.value?.sections) return 0
  let count = 0
  for (const s of program.value.sections) {
    for (const l of s.lessons ?? []) {
      count += l.topics?.length ?? 0
    }
  }
  return count
})

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

async function onReorderSections() {
  const ids = (program.value?.sections ?? []).map(s => s.id)
  await reorderSections(ids)
}

async function onReorderLessons() {
  const ids: string[] = []
  for (const s of program.value?.sections ?? []) {
    for (const l of s.lessons ?? []) {
      ids.push(l.id)
    }
  }
  await reorderLessons(ids)
}

async function onReorderTopics() {
  const ids: string[] = []
  for (const s of program.value?.sections ?? []) {
    for (const l of s.lessons ?? []) {
      for (const t of l.topics ?? []) {
        ids.push(t.id)
      }
    }
  }
  await reorderTopics(ids)
}

function cancelAddSection() {
  addingSection.value = false
  newSectionTitle.value = ''
}

async function addSection() {
  if (!newSectionTitle.value.trim()) return
  savingSection.value = true
  try {
    const sort = (program.value?.sections?.length ?? 0) + 1
    await apiCreateSection({ program_id: id, title: newSectionTitle.value.trim(), sort_order: sort })
    addingSection.value = false
    newSectionTitle.value = ''
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    savingSection.value = false
  }
}

function startEditSection(section: ProgramSection) {
  editingSection.value = section.id
  editSectionTitle.value = section.title
}

function cancelEditSection() {
  editingSection.value = null
}

async function updateSection(section: ProgramSection) {
  if (!editSectionTitle.value.trim()) return
  try {
    await apiUpdateSection(section.id, { title: editSectionTitle.value.trim() })
    editingSection.value = null
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

async function deleteSection(section: ProgramSection) {
  try {
    await apiDeleteSection(section.id)
    snackbar.value = { show: true, text: 'Section deleted', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

function startAddLesson(section: ProgramSection) {
  addingLessonSection.value = section.id
  newLessonTitle.value = ''
}

function cancelAddLesson() {
  addingLessonSection.value = null
  newLessonTitle.value = ''
}

async function addLesson(section: ProgramSection) {
  if (!newLessonTitle.value.trim()) return
  savingLesson.value = true
  try {
    const sort = (section.lessons?.length ?? 0) + 1
    await apiCreateLesson({ section_id: section.id, title: newLessonTitle.value.trim(), sort_order: sort })
    addingLessonSection.value = null
    newLessonTitle.value = ''
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    savingLesson.value = false
  }
}

function startEditLesson(lesson: ProgramLesson) {
  editingLesson.value = lesson.id
  editLessonTitle.value = lesson.title
}

function cancelEditLesson() {
  editingLesson.value = null
}

async function updateLesson(lesson: ProgramLesson) {
  if (!editLessonTitle.value.trim()) return
  try {
    await apiUpdateLesson(lesson.id, { title: editLessonTitle.value.trim() })
    editingLesson.value = null
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

async function deleteLesson(lesson: ProgramLesson) {
  try {
    await apiDeleteLesson(lesson.id)
    snackbar.value = { show: true, text: 'Lesson deleted', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  }
}

function startAddTopic(lesson: ProgramLesson) {
  addingTopicLesson.value = lesson.id
  newTopicTitle.value = ''
}

function cancelAddTopic() {
  addingTopicLesson.value = null
  newTopicTitle.value = ''
}

async function addTopic(lesson: ProgramLesson) {
  if (!newTopicTitle.value.trim()) return
  savingTopic.value = true
  try {
    const sort = (lesson.topics?.length ?? 0) + 1
    await apiCreateTopic({ lesson_id: lesson.id, title: newTopicTitle.value.trim(), sort_order: sort })
    addingTopicLesson.value = null
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

function startAddQuiz(topic: ProgramTopic) {
  quizTopic.value = topic
  quizForm.title = ''
  quizForm.type = 'quiz'
  quizDialog.value = true
}

async function addQuiz() {
  if (!quizForm.title.trim() || !quizTopic.value) return
  savingQuiz.value = true
  try {
    await apiCreateQuiz({ topic_id: quizTopic.value.id, title: quizForm.title.trim(), type: quizForm.type as any })
    quizDialog.value = false
    quizTopic.value = null
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    savingQuiz.value = false
  }
}

async function deleteQuiz(quiz: ProgramQuiz) {
  try {
    await apiDeleteQuiz(quiz.id)
    snackbar.value = { show: true, text: 'Quiz deleted', color: 'success' }
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
