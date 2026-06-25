<template>
  <div>
    <div class="d-flex flex-wrap ga-4 mb-6">
      <StatCard
        v-for="stat in statList"
        :key="stat.title"
        v-bind="stat"
        class="flex-grow-1"
        style="min-width: 220px"
      />
    </div>

    <v-row>
      <v-col cols="12" md="8">
        <v-card elevation="2" rounded="lg">
          <v-card-title class="text-h6">Revenue Overview</v-card-title>
          <v-card-text>
            <Line v-if="loaded" :data="chartData" :options="chartOptions" />
          </v-card-text>
        </v-card>
      </v-col>
      <v-col cols="12" md="4">
        <v-card elevation="2" rounded="lg">
          <v-card-title class="text-h6">Recent Activity</v-card-title>
          <v-list density="compact">
            <v-list-item
              v-for="activity in activities"
              :key="activity.text"
              :prepend-icon="activity.icon"
              :title="activity.text"
              :subtitle="activity.time"
            />
          </v-list>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'auth' })

import { Line } from 'vue-chartjs'
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
  Filler,
} from 'chart.js'

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Legend, Filler)

const { statList, pending } = useStats()
const loaded = ref(false)

const activities = [
  { icon: 'mdi-account-plus', text: 'New user registered', time: '2 min ago' },
  { icon: 'mdi-cart', text: 'Order #3841 completed', time: '15 min ago' },
  { icon: 'mdi-currency-usd', text: 'Invoice paid — $1,200', time: '1 hour ago' },
  { icon: 'mdi-alert', text: 'Server CPU at 78%', time: '3 hours ago' },
]

const chartData = {
  labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
  datasets: [
    {
      label: 'Revenue',
      data: [28, 35, 31, 42, 48, 52, 55, 60, 58, 63, 70, 78],
      fill: true,
      borderColor: '#1867c0',
      backgroundColor: 'rgba(24, 103, 192, 0.1)',
      tension: 0.3,
    },
  ],
}

const chartOptions = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { display: false } },
  scales: {
    y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' } },
    x: { grid: { display: false } },
  },
}

watch(pending, (val) => {
  if (!val) loaded.value = true
})
</script>
