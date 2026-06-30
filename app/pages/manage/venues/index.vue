<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Venues</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ venues?.length ?? 0 }} conference rooms</div>
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
          class="room-card"
        >
          <v-card-item>
            <template #append>
              <v-chip
                size="x-small"
                :color="chipColor(item.status)"
                variant="tonal"
              >
                <template #prepend><v-icon size="8" :color="chipColor(item.status)">mdi-circle</v-icon></template>
                {{ statusLabel(item.status) }}
              </v-chip>
            </template>
          </v-card-item>

            <v-card-text style="position:relative">
              <v-btn
                icon
                variant="text"
                size="x-small"
                color="error"
                class="delete-btn"
                @click.stop.prevent="confirmDelete(item)"
              >
                <v-icon size="18">mdi-delete</v-icon>
              </v-btn>
              <div class="text-caption text-medium-emphasis font-family-mono mb-1">
              <v-icon size="14" class="me-1">mdi-hotel</v-icon>
              {{ item.venue_name }}
            </div>
            <div class="text-h6 font-weight-bold mb-2">{{ item.name }}</div>
            <div class="text-body-2 text-medium-emphasis mb-3">
              <v-icon size="14" class="me-1">mdi-account-group</v-icon>
              Capacity: {{ item.capacity }} pax
              <span v-if="item.floor"> · {{ item.floor }}</span>
            </div>

            <div v-if="hasWorkshop(item.id)" class="bg-grey-lighten-4 rounded pa-3" style="border-left:3px solid rgb(var(--v-theme-primary))">
              <div class="text-body-2 font-weight-medium">PM Workshop — Batch 4</div>
              <div class="text-caption text-medium-emphasis font-family-mono">Jun 24 – Jun 27, 2025</div>
            </div>
            <div v-else class="bg-grey-lighten-4 rounded pa-3 text-medium-emphasis text-body-2">
              <em>No workshop scheduled</em>
            </div>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>

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
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

import type { ConferenceRoom } from '~/types'

const { data: venues, pending, refresh } = useFetch<ConferenceRoom[]>('/api/admin/rooms')

async function deleteVenue(id: string) {
  const { error } = await useFetch(`/api/admin/rooms/${id}`, { method: 'DELETE' })
  if (error.value) throw new Error(error.value.message)
  await refresh()
}

const deleteDialog = ref(false)
const deleting = ref(false)
const deletingItem = ref<ConferenceRoom | null>(null)
const snackbar = ref({ show: false, text: '', color: 'success' })

function confirmDelete(item: ConferenceRoom) {
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

function chipColor(s: string) {
  const map: Record<string, string> = { available: 'grey', booked: 'warning', in_use: 'success' }
  return map[s] || 'grey'
}

function statusLabel(s: string) {
  const map: Record<string, string> = { available: 'Available', booked: 'Booked soon', in_use: 'In use' }
  return map[s] || s
}

function hasWorkshop(_roomId: string) {
  return false
}
</script>

<style scoped>
.room-card { cursor: pointer; transition: border-color 0.15s, box-shadow 0.15s; }
.room-card:hover { border-color: rgb(var(--v-theme-primary)) !important; }
.room-card:hover .delete-btn { opacity: 1; }
.delete-btn { position: absolute; top: 8px; right: 8px; opacity: 0; transition: opacity 0.15s; }
.font-family-mono { font-family: 'DM Mono', 'SF Mono', 'Cascadia Code', monospace; }
</style>
