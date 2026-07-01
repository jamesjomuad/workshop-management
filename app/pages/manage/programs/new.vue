<template>
  <div>
    <div class="d-flex align-center mb-4 ga-3 flex-wrap">
      <v-btn icon variant="text" to="/manage/programs" class="me-1">
        <v-icon>mdi-arrow-left</v-icon>
      </v-btn>
      <v-divider vertical class="align-self-stretch" />
      <h1 class="text-h4 font-weight-bold">New Program</h1>
      <v-spacer />
      <v-btn color="primary" :loading="saving" @click="save">Create program</v-btn>
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-form ref="formRef">
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
              <v-text-field
                v-model="form.title"
                name="title"
                label="Program title *"
                :rules="required"
                variant="outlined"
                density="comfortable"
                hide-details="auto"
              />
              <v-textarea
                v-model="form.description"
                name="description"
                label="Description"
                variant="outlined"
                density="comfortable"
                rows="3"
                hide-details
              />
            </v-card-text>
          </v-card>

          <v-card variant="outlined" rounded="lg">
            <v-card-item>
              <template #prepend>
                <v-icon color="secondary" class="me-2">mdi-order-bool-ascending</v-icon>
                <div>
                  <v-card-title class="text-body-1 font-weight-bold">Topics</v-card-title>
                  <v-card-subtitle>Add the topics this program will cover</v-card-subtitle>
                </div>
              </template>
              <template #append>
                <v-btn size="small" color="primary" variant="tonal" prepend-icon="mdi-plus" @click="addTopicInput">
                  Add topic
                </v-btn>
              </template>
            </v-card-item>
            <v-divider />
            <v-card-text>
              <div v-if="topics.length === 0" class="py-4 text-center text-medium-emphasis">
                <v-icon size="32" class="mb-1">mdi-playlist-plus</v-icon>
                <div class="text-body-2">No topics yet</div>
                <div class="text-caption mt-1">Add topics to outline the curriculum content</div>
              </div>
              <draggable
                v-model="topics"
                item-key="id"
                handle=".drag-topic"
                :animation="200"
              >
                <template #item="{ element: topic, index }">
                  <div class="d-flex align-center ga-2 mb-2">
                    <v-icon class="drag-topic cursor-grab text-medium-emphasis" size="18">mdi-drag</v-icon>
                    <v-avatar size="24" color="secondary" variant="tonal" class="text-caption font-weight-bold">{{ index + 1 }}</v-avatar>
                    <v-text-field
                      v-model="topic.title"
                      variant="outlined"
                      density="compact"
                      hide-details
                      placeholder="Topic title"
                      class="flex-grow-1"
                      @keyup.enter="addTopicInput"
                    />
                    <v-btn icon variant="text" size="small" color="error" @click="topics.splice(index, 1)">
                      <v-icon size="16">mdi-close</v-icon>
                    </v-btn>
                  </div>
                </template>
              </draggable>
            </v-card-text>
          </v-card>
        </v-form>
      </v-col>

      <v-col cols="12" md="4">
        <v-card variant="outlined" rounded="lg">
          <v-card-item>
            <v-card-title class="text-body-2 font-weight-bold">Summary</v-card-title>
          </v-card-item>
          <v-divider />
          <v-list density="compact">
            <v-list-item title="Title">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.title }">{{ form.title || 'Not set' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Description">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': !form.description }">{{ form.description || 'None' }}</span>
              </template>
            </v-list-item>
            <v-divider />
            <v-list-item title="Topics">
              <template #subtitle>
                <span :class="{ 'text-medium-emphasis': topics.length === 0 }">{{ topics.length || 'None' }}</span>
              </template>
            </v-list-item>
          </v-list>
        </v-card>

        <v-btn color="primary" size="large" :loading="saving" block class="mt-3" @click="save">
          Create program
        </v-btn>
      </v-col>
    </v-row>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">
      {{ snackbar.text }}
    </v-snackbar>
  </div>
</template>

<script setup lang="ts">
import draggable from 'vuedraggable'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const router = useRouter()
const { createProgram, createTopic } = useAdminPrograms()

const form = reactive({
  title: '',
  description: '',
})
const topics = reactive<{ id: number; title: string }[]>([])
let topicIdCounter = 0
const saving = ref(false)
const formRef = ref<VForm>()

const required = [(v: any) => !!v || 'Required']

function addTopicInput() {
  topics.push({ id: ++topicIdCounter, title: '' })
}

async function save() {
  saving.value = true
  try {
    if (!formRef.value) throw new Error('Form not found')
    const { valid } = await formRef.value.validate()
    if (!valid) {
      snackbar.value = { show: true, text: 'Please fix the highlighted errors', color: 'warning' }
      return
    }

    const created = await createProgram({
      title: form.title,
      description: form.description || null,
    })

    const programId = created.id

    for (let i = 0; i < topics.length; i++) {
      const title = topics[i].title.trim()
      if (!title) continue
      await createTopic({ program_id: programId, title, sort_order: i })
    }

    snackbar.value = { show: true, text: 'Program created!', color: 'success' }
    setTimeout(() => router.push(`/manage/programs/${programId}`), 1200)
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message || err.toString(), color: 'error' }
  } finally {
    saving.value = false
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>

<style scoped>
.cursor-grab { cursor: grab; }
.cursor-grab:active { cursor: grabbing; }
</style>
