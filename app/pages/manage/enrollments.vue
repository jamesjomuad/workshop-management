<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Enrollments & Attendance</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ enrollments.length }} total enrollments across all workshops</div>
      </div>
      <v-spacer />
      <v-btn color="primary" prepend-icon="mdi-plus">Enroll Trainee</v-btn>
    </div>

    <v-chip-group
      v-model="filter"
      mandatory
      color="primary"
      class="mb-4"
    >
      <v-chip filter variant="tonal" value="all">All</v-chip>
      <v-chip filter variant="tonal" value="confirmed">Confirmed</v-chip>
      <v-chip filter variant="tonal" value="pending">Pending payment</v-chip>
      <v-chip filter variant="tonal" value="waitlisted">Waitlisted</v-chip>
      <v-chip filter variant="tonal" value="company">Company-sponsored</v-chip>
      <v-chip filter variant="tonal" value="self">Self-enrolled</v-chip>
    </v-chip-group>

    <v-card rounded="lg" variant="outlined">
      <v-table density="compact">
        <thead>
          <tr>
            <th class="text-uppercase text-caption font-weight-bold">Trainee</th>
            <th class="text-uppercase text-caption font-weight-bold">Workshop</th>
            <th class="text-uppercase text-caption font-weight-bold">Program</th>
            <th class="text-uppercase text-caption font-weight-bold">Company</th>
            <th class="text-uppercase text-caption font-weight-bold">Type</th>
            <th class="text-uppercase text-caption font-weight-bold">Payment</th>
            <th class="text-uppercase text-caption font-weight-bold">Attendance</th>
            <th class="text-uppercase text-caption font-weight-bold">Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="e in filteredEnrollments" :key="e.id">
            <td class="font-weight-medium">{{ e.name }}</td>
            <td>{{ e.workshop }}</td>
            <td>{{ e.program }}</td>
            <td>{{ e.company }}</td>
            <td>
              <v-chip size="x-small" :color="e.typeColor" variant="tonal">{{ e.type }}</v-chip>
            </td>
            <td>
              <v-chip size="x-small" :color="e.paymentColor" variant="tonal">{{ e.payment }}</v-chip>
            </td>
            <td>
              <div v-if="e.attendancePct !== undefined" class="text-caption text-medium-emphasis mb-1">{{ e.attendanceLabel }}</div>
              <div v-if="e.attendancePct !== undefined">
                <v-progress-linear
                  :model-value="e.attendancePct"
                  :color="e.attendancePct >= 50 ? 'success' : 'warning'"
                  height="6"
                  rounded
                />
              </div>
              <div v-else class="text-caption text-medium-emphasis">Not started</div>
            </td>
            <td>
              <v-chip size="x-small" :color="e.statusColor" variant="tonal">
                <template v-if="e.statusDot" #prepend><v-icon size="8" :color="e.statusColor">mdi-circle</v-icon></template>
                {{ e.status }}
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
    </v-card>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

const filter = ref('all')

interface EnrollmentItem {
  id: string
  name: string
  workshop: string
  program: string
  company: string
  type: string
  typeColor: string
  payment: string
  paymentColor: string
  attendancePct?: number
  attendanceLabel?: string
  status: string
  statusColor: string
  statusDot: boolean
  filterStatus: string
  filterType: string
}

const enrollments: EnrollmentItem[] = [
  { id: '1', name: 'Ana Mercado', workshop: 'PM Workshop Batch 4', program: 'PM Fundamentals', company: 'Pacific Corp', type: 'Company', typeColor: 'primary', payment: 'Paid', paymentColor: 'success', attendancePct: 50, attendanceLabel: '4 / 8', status: 'Active', statusColor: 'success', statusDot: true, filterStatus: 'confirmed', filterType: 'company' },
  { id: '2', name: 'Ben Ramos', workshop: 'Safety Training June', program: 'Workplace Safety', company: 'IndyCo Ltd.', type: 'Company', typeColor: 'primary', payment: 'Paid', paymentColor: 'success', attendancePct: 50, attendanceLabel: '2 / 4', status: 'Active', statusColor: 'success', statusDot: true, filterStatus: 'confirmed', filterType: 'company' },
  { id: '3', name: 'Carla Tan', workshop: 'Leadership Series July', program: 'Effective Leadership', company: '—', type: 'Self', typeColor: 'purple', payment: 'Pending', paymentColor: 'warning', status: 'Pending', statusColor: 'warning', statusDot: false, filterStatus: 'pending', filterType: 'self' },
  { id: '4', name: 'Diego Lim', workshop: 'PM Workshop Batch 4', program: 'PM Fundamentals', company: 'Pacific Corp', type: 'Company', typeColor: 'primary', payment: 'Paid', paymentColor: 'success', attendancePct: 50, attendanceLabel: '4 / 8', status: 'Active', statusColor: 'success', statusDot: true, filterStatus: 'confirmed', filterType: 'company' },
  { id: '5', name: 'Eva Santos', workshop: 'PM Workshop Batch 4', program: 'PM Fundamentals', company: 'Pacific Corp', type: 'Company', typeColor: 'primary', payment: 'Paid', paymentColor: 'success', attendancePct: 38, attendanceLabel: '3 / 8', status: 'Absent ×2', statusColor: 'error', statusDot: false, filterStatus: 'confirmed', filterType: 'company' },
  { id: '6', name: 'Felix Cruz', workshop: 'Leadership Series July', program: 'Effective Leadership', company: 'BrightPath Inc.', type: 'Company', typeColor: 'primary', payment: 'Paid', paymentColor: 'success', status: 'Upcoming', statusColor: 'grey', statusDot: false, filterStatus: 'confirmed', filterType: 'company' },
]

const filteredEnrollments = computed(() => {
  if (filter.value === 'all') return enrollments
  if (filter.value === 'company') return enrollments.filter(e => e.filterType === 'company')
  if (filter.value === 'self') return enrollments.filter(e => e.filterType === 'self')
  return enrollments.filter(e => e.filterStatus === filter.value)
})
</script>
