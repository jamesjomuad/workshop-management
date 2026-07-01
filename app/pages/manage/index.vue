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
      <v-col cols="12" md="6">
        <v-card rounded="lg" variant="outlined">
          <v-card-item>
            <v-card-title class="text-h6">Today's Sessions</v-card-title>
            <v-card-subtitle>{{ currentDate }}</v-card-subtitle>
            <template #append>
              <v-chip size="small" color="success" variant="tonal" class="mt-2">
                <template #prepend><v-icon size="10" color="success">mdi-circle</v-icon></template>
                2 ongoing
              </v-chip>
            </template>
          </v-card-item>
          <v-divider />
          <v-list lines="two" density="compact">
            <v-list-item
              v-for="session in todaySessions"
              :key="session.title"
              :title="session.title"
              :subtitle="session.subtitle"
            >
              <template #prepend>
                <div class="text-caption font-weight-mono text-medium-emphasis me-2" style="min-width:44px">{{ session.time }}</div>
                <v-icon :color="session.color" size="8" class="me-3">mdi-circle</v-icon>
              </template>
              <template #append>
                <v-chip size="x-small" :color="session.chipColor" variant="tonal">{{ session.status }}</v-chip>
              </template>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>

      <v-col cols="12" md="6">
        <v-card rounded="lg" variant="outlined">
          <v-card-item>
            <v-card-title class="text-h6">Attendance Rate</v-card-title>
            <v-card-subtitle>Active workshops this month</v-card-subtitle>
          </v-card-item>
          <v-divider />
          <v-list density="compact">
            <v-list-item v-for="att in attendanceRates" :key="att.label">
              <template #default>
                <div class="d-flex align-center ga-2 py-1">
                  <div class="text-body-2 text-medium-emphasis" style="min-width:120px">{{ att.label }}</div>
                  <v-progress-linear
                    :model-value="att.pct"
                    :color="att.color"
                    height="8"
                    rounded
                    class="flex-grow-1"
                  />
                  <div class="text-caption font-weight-mono text-medium-emphasis" style="min-width:34px;text-align:right">{{ att.pct }}%</div>
                </div>
              </template>
            </v-list-item>
          </v-list>
        </v-card>
      </v-col>
    </v-row>


  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const today = new Date()
const currentDate = today.toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })

const statCards = [
  { label: 'Active Workshops', value: '3', icon: 'mdi-notebook', color: 'primary', delta: '2 this month', deltaClass: 'text-success text-caption' },
  { label: 'Rooms in Use', value: '2 / 5', icon: 'mdi-door-open', color: 'warning', delta: '3 available today', deltaClass: 'text-medium-emphasis text-caption' },
  { label: 'Avg. Attendance', value: '87%', icon: 'mdi-check-circle', color: 'purple', delta: '4% vs last month', deltaClass: 'text-success text-caption' },
]

const todaySessions = [
  { time: '08:00', title: 'Module 1 — Project Planning', subtitle: 'Ballroom B · Maria Santos · 24 participants', color: 'success', chipColor: 'success', status: 'Ongoing' },
  { time: '09:30', title: 'Safety Fundamentals — Day 2', subtitle: 'Function Room 1 · Rico Cruz · 18 participants', color: 'success', chipColor: 'success', status: 'Ongoing' },
  { time: '13:00', title: 'Leadership Essentials', subtitle: 'Boardroom A · Ana Reyes · 12 participants', color: 'warning', chipColor: 'warning', status: 'Starting soon' },
  { time: '14:00', title: 'Module 2 — Risk Management', subtitle: 'Ballroom B · Maria Santos · 24 participants', color: 'grey', chipColor: 'default', status: 'Upcoming' },
]

const attendanceRates = [
  { label: 'PM Workshop', pct: 92, color: 'success' },
  { label: 'Safety Training', pct: 85, color: 'primary' },
  { label: 'Leadership Series', pct: 78, color: 'secondary' },
  { label: 'HR Fundamentals', pct: 95, color: 'success' },
  { label: 'Digital Literacy', pct: 61, color: 'warning' },
]


</script>

<style scoped>
.font-family-mono { font-family: 'DM Mono', 'SF Mono', 'Cascadia Code', monospace; }
</style>
