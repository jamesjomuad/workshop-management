<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Programs & Sessions</h1>
        <div class="text-caption text-medium-emphasis mt-1">Curriculum organized by workshop</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus">New Program</v-btn>
    </div>

    <v-expansion-panels variant="accordion">
      <v-expansion-panel v-for="prog in programs" :key="prog.id">
        <v-expansion-panel-title class="text-body-1">
          <div class="d-flex align-center ga-3 w-100">
            <div class="flex-grow-1">
              <div class="text-caption text-medium-emphasis font-family-mono">{{ prog.workshopLabel }}</div>
              <div class="font-weight-bold">{{ prog.name }}</div>
            </div>
            <v-chip size="x-small" color="primary" variant="tonal">{{ prog.sessionCount }} sessions</v-chip>
            <v-chip size="x-small" :color="prog.statusColor" variant="tonal">
              <template v-if="prog.status === 'ongoing'" #prepend><v-icon size="8" :color="prog.statusColor">mdi-circle</v-icon></template>
              {{ prog.statusLabel }}
            </v-chip>
          </div>
        </v-expansion-panel-title>

        <v-expansion-panel-text>
          <v-table density="compact">
            <thead>
              <tr>
                <th class="text-uppercase text-caption font-weight-bold">Day</th>
                <th class="text-uppercase text-caption font-weight-bold">Session</th>
                <th class="text-uppercase text-caption font-weight-bold">Time</th>
                <th class="text-uppercase text-caption font-weight-bold">Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="session in prog.sessions"
                :key="session.id"
                :class="{ 'bg-warning-lighten-5': session.status === 'ongoing' }"
              >
                <td class="font-family-mono text-caption text-medium-emphasis">{{ session.day }}</td>
                <td class="font-weight-medium">{{ session.title }}</td>
                <td class="font-family-mono text-caption text-medium-emphasis">{{ session.time }}</td>
                <td>
                  <v-chip size="x-small" :color="sessionChipColor(session.status)" variant="tonal">
                    <template v-if="session.status === 'ongoing'" #prepend><v-icon size="8" :color="sessionChipColor(session.status)">mdi-circle</v-icon></template>
                    {{ session.statusLabel }}
                  </v-chip>
                </td>
                <td>
                  <v-btn icon variant="text" size="x-small" color="medium-emphasis">
                    <v-icon size="16">mdi-pencil</v-icon>
                  </v-btn>
                </td>
              </tr>
            </tbody>
          </v-table>
        </v-expansion-panel-text>
      </v-expansion-panel>
    </v-expansion-panels>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

interface SessionItem {
  id: string
  day: string
  title: string
  time: string
  status: 'completed' | 'ongoing' | 'upcoming'
  statusLabel: string
}

interface ProgramItem {
  id: string
  workshopLabel: string
  name: string
  sessionCount: number
  status: 'completed' | 'ongoing' | 'upcoming'
  statusColor: string
  statusLabel: string
  sessions: SessionItem[]
}

const programs: ProgramItem[] = [
  {
    id: '1',
    workshopLabel: 'PM Workshop — Batch 4 · Jun 24–27',
    name: 'Project Management Fundamentals',
    sessionCount: 8,
    status: 'ongoing',
    statusColor: 'success',
    statusLabel: 'Ongoing',
    sessions: [
      { id: 's1', day: 'Day 1', title: 'Module 1 — Project Planning', time: '08:00 – 12:00', status: 'completed', statusLabel: 'Done' },
      { id: 's2', day: 'Day 1', title: 'Module 2 — Scope & WBS', time: '13:00 – 17:00', status: 'completed', statusLabel: 'Done' },
      { id: 's3', day: 'Day 2', title: 'Module 3 — Risk Management', time: '08:00 – 12:00', status: 'ongoing', statusLabel: 'Ongoing' },
      { id: 's4', day: 'Day 2', title: 'Module 4 — Scheduling', time: '13:00 – 17:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's5', day: 'Day 3', title: 'Module 5 — Cost Estimation', time: '08:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
  {
    id: '2',
    workshopLabel: 'Safety Training — June · Jun 25–26',
    name: 'Workplace Safety & Compliance',
    sessionCount: 4,
    status: 'ongoing',
    statusColor: 'success',
    statusLabel: 'Ongoing',
    sessions: [
      { id: 's6', day: 'Day 1', title: 'Safety Regulations Overview', time: '08:00 – 11:00', status: 'completed', statusLabel: 'Done' },
      { id: 's7', day: 'Day 1', title: 'Hazard Identification', time: '13:00 – 17:00', status: 'ongoing', statusLabel: 'Ongoing' },
      { id: 's8', day: 'Day 2', title: 'Emergency Response', time: '08:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's9', day: 'Day 2', title: 'Practical Assessment', time: '13:00 – 16:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
  {
    id: '3',
    workshopLabel: 'Leadership Series — July · Jul 7–9',
    name: 'Effective Leadership & Team Building',
    sessionCount: 6,
    status: 'upcoming',
    statusColor: 'warning',
    statusLabel: 'Upcoming',
    sessions: [
      { id: 's10', day: 'Day 1', title: 'Leadership Styles', time: '09:00 – 12:00', status: 'upcoming', statusLabel: 'Upcoming' },
      { id: 's11', day: 'Day 1', title: 'Communication & Influence', time: '13:00 – 17:00', status: 'upcoming', statusLabel: 'Upcoming' },
    ],
  },
]

function sessionChipColor(s: string) {
  const map: Record<string, string> = { completed: 'success', ongoing: 'success', upcoming: 'grey' }
  return map[s] || 'grey'
}
</script>

<style scoped>
.font-family-mono { font-family: 'DM Mono', 'SF Mono', 'Cascadia Code', monospace; }
.bg-warning-lighten-5 { background-color: rgb(255, 248, 225); }
</style>
