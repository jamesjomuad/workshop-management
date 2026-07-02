<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold ma-0">Venues</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ venues?.length ?? 0 }} venues</div>
      </div>
      <v-spacer />
      <v-btn :to="'/manage/venues/new'" color="primary" prepend-icon="mdi-plus">
        Add Venue
      </v-btn>
    </div>

    <v-row>
      <v-col
        v-for="item in venues ?? []"
        :key="item.id"
        cols="12"
        sm="6"
        md="4"
      >
        <v-card
          rounded="lg"
          variant="outlined"
          :to="`/manage/venues/${item.id}`"
          :class="['venue-card', { 'opacity-60': !item.is_active }]"
        >
          <v-card-item>
            <template #prepend>
              <v-avatar size="40" :color="typeColor[item.type]" variant="tonal" class="me-3">
                <v-icon size="20">{{ typeIcon[item.type] }}</v-icon>
              </v-avatar>
            </template>
            <v-card-title class="text-body-1 font-weight-bold pa-0">{{ item.name }}</v-card-title>
            <v-card-subtitle class="text-caption mt-1 pa-0">
              {{ typeLabel[item.type] }}
            </v-card-subtitle>
            <template #append>
              <v-chip
                size="x-small"
                :color="item.is_active ? 'success' : 'grey'"
                variant="tonal"
              >
                {{ item.is_active ? 'Active' : 'Inactive' }}
              </v-chip>
            </template>
          </v-card-item>

          <v-divider />

          <v-card-text>
            <div class="d-flex flex-column ga-2">
              <div v-if="item.address || item.city" class="d-flex align-center text-caption text-medium-emphasis">
                <v-icon size="14" class="me-2">mdi-map-marker</v-icon>
                <span>{{ formatLocation(item) }}</span>
              </div>
              <div v-if="item.contact_person" class="d-flex align-center text-caption text-medium-emphasis">
                <v-icon size="14" class="me-2">mdi-account</v-icon>
                <span>{{ item.contact_person }}</span>
              </div>
              <div v-if="item.contact_phone" class="d-flex align-center text-caption text-medium-emphasis">
                <v-icon size="14" class="me-2">mdi-phone</v-icon>
                <span>{{ item.contact_phone }}</span>
              </div>
            </div>
          </v-card-text>

          <v-card-actions class="pa-3 pt-0">
            <v-spacer />
            <v-btn
              icon
              variant="text"
              size="x-small"
              color="error"
              @click.stop.prevent="confirmDelete(item)"
            >
              <v-icon size="18">mdi-delete</v-icon>
            </v-btn>
          </v-card-actions>
        </v-card>
      </v-col>
    </v-row>

    <div v-if="(venues?.length ?? 0) === 0 && !pending" class="py-12 text-center text-medium-emphasis">
      <v-icon size="48" class="mb-2">mdi-office-building-outline</v-icon>
      <div class="text-body-1 font-weight-medium">No venues yet</div>
      <div class="text-caption mt-1">Add your first venue to get started</div>
    </div>

    <v-dialog v-model="deleteDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Confirm delete</v-card-title>
        <v-card-text>Delete "{{ deletingItem?.name }}" and all its data?</v-card-text>
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="deleteDialog = false">Cancel</v-btn>
          <v-btn color="error" :loading="deleting" @click="handleDelete">Delete</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">{{ snackbar.text }}</v-snackbar>
  </div>
</template>

<script setup lang="ts">
import type { Venue } from '~/types'

definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { data: venues, pending, refresh } = useFetch<Venue[]>('/api/admin/rooms')

const typeLabel: Record<string, string> = { hotel: 'Hotel', convention_center: 'Convention Center', office: 'Office', other: 'Other' }
const typeIcon: Record<string, string> = { hotel: 'mdi-bed', convention_center: 'mdi-domain', office: 'mdi-desk', other: 'mdi-map-marker' }
const typeColor: Record<string, string> = { hotel: 'primary', convention_center: 'secondary', office: 'info', other: 'grey' }

function formatLocation(v: Venue) {
  const parts = [v.city, v.province, v.country].filter(Boolean)
  return parts.length ? parts.join(', ') : v.address || 'No location set'
}

async function deleteVenue(id: string) {
  await $fetch(`/api/admin/rooms/${id}`, { method: 'DELETE' })
  await refresh()
}

const deleteDialog = ref(false)
const deleting = ref(false)
const deletingItem = ref<Venue | null>(null)
const snackbar = ref({ show: false, text: '', color: 'success' })

function confirmDelete(item: Venue) {
  deletingItem.value = item
  deleteDialog.value = true
}

async function handleDelete() {
  if (!deletingItem.value) return
  deleting.value = true
  try {
    await deleteVenue(deletingItem.value.id)
    snackbar.value = { show: true, text: 'Venue deleted', color: 'success' }
    deleteDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    deleting.value = false
  }
}
</script>

<style scoped>
.venue-card { cursor: pointer; transition: border-color 0.15s, box-shadow 0.15s; }
.venue-card:hover { border-color: rgb(var(--v-theme-primary)) !important; }
.opacity-60 { opacity: 0.6; }
</style>
