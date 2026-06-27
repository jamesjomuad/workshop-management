<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Conference Rooms</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ rooms?.length ?? 0 }} rooms across venues</div>
      </div>
      <v-spacer />
      <v-btn :to="'/manage/rooms/new'" color="primary" prepend-icon="mdi-plus">
        Add Room
      </v-btn>
    </div>

    <v-row>
      <v-col
        v-for="item in rooms ?? []"
        :key="item.id"
        cols="12"
        sm="6"
        md="4"
      >
        <v-card
          rounded="lg"
          variant="outlined"
          :to="`/manage/rooms/${item.id}`"
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

          <v-card-text>
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
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const { rooms, pending, deleteRoom } = useConferenceRooms()

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
.font-family-mono { font-family: 'DM Mono', 'SF Mono', 'Cascadia Code', monospace; }
</style>
