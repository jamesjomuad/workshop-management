<template>
  <div class="calendar-wrapper position-relative">
    <div class="glow-blob" aria-hidden="true" />

    <v-card
      :class="['calendar-card', { tilted: !isMobile }]"
      elevation="8"
      rounded="xl"
    >
      <div class="pa-4 pa-sm-5">
        <div class="d-flex align-center justify-space-between mb-3">
          <span class="text-subtitle-1 font-weight-bold">July 2026</span>
          <div class="d-flex ga-1">
            <v-btn icon="mdi-chevron-left" variant="text" density="compact" size="small" />
            <v-btn icon="mdi-chevron-right" variant="text" density="compact" size="small" />
          </div>
        </div>

        <div class="calendar-grid">
          <div v-for="day in dayLabels" :key="day" class="calendar-day-label text-caption font-weight-medium text-grey">
            {{ day }}
          </div>
          <div
            v-for="cell in calendarCells"
            :key="cell.label"
            class="calendar-cell"
            :class="{
              'cell-highlight': cell.highlight,
              'cell-muted': cell.muted,
              'cell-today': cell.today,
              'cell-selected': cell.selected,
            }"
          >
            <span class="cell-number">{{ cell.label }}</span>
            <div v-if="cell.highlight" class="cell-dot bg-secondary" />
          </div>
        </div>
      </div>

      <v-divider />

      <div class="pa-4 pa-sm-5">
        <div class="d-flex align-center justify-space-between mb-3">
          <span class="text-subtitle-2 font-weight-bold">Thu, Jul 12</span>
          <span class="text-caption text-grey">4 venues available</span>
        </div>
        <div class="d-flex flex-column ga-2">
          <v-chip
            v-for="(room, i) in roomOptions"
            :key="i"
            :color="room.color"
            :variant="room.variant"
            size="small"
            :disabled="room.disabled"
            label
            class="justify-start px-3"
            style="height: 32px;"
          >
            <v-icon start size="14">{{ room.icon }}</v-icon>
            <span class="text-caption">{{ room.label }}</span>
          </v-chip>
        </div>

        <div class="d-flex align-center mt-4 pt-1">
          <v-icon size="16" color="secondary" class="me-1">mdi-check-circle</v-icon>
          <span class="text-caption text-grey me-2">Free cancellation up to 48h</span>
          <v-spacer />
          <span class="text-caption font-weight-medium" style="color: rgb(var(--v-theme-navy));">Trusted by 200+ hotels</span>
        </div>
      </div>

      <div class="live-badge">
        <div class="live-dot" />
        <span class="text-caption font-weight-medium">Marriott Downtown just confirmed a 3-day conference</span>
      </div>
    </v-card>
  </div>
</template>

<script setup lang="ts">
const isMobile = ref(false)

function onResize() {
  isMobile.value = window.innerWidth < 960
}
onMounted(() => {
  onResize()
  window.addEventListener('resize', onResize)
})
onUnmounted(() => window.removeEventListener('resize', onResize))

const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']

const calendarCells = computed(() => {
  const cells = []
  for (let i = 0; i < 5; i++) cells.push({ label: '', highlight: false, muted: true, today: false, selected: false })
  for (let i = 1; i <= 31; i++) {
    cells.push({
      label: i,
      highlight: [2, 5, 8, 12, 15, 19, 22, 26, 29].includes(i),
      muted: [1, 6, 13, 20, 27, 31].includes(i),
      today: i === 12,
      selected: i === 12,
    })
  }
  return cells
})

const roomOptions = [
  { label: 'Grand Ballroom — Available (seats 200)', icon: 'mdi-sofa-single', color: 'secondary', variant: 'tonal' as const, disabled: false },
  { label: 'Conference Room B — Fully Booked', icon: 'mdi-lock', color: '', variant: 'tonal' as const, disabled: true },
  { label: 'Skyline Terrace — 2 spaces left', icon: 'mdi-weather-sunset', color: 'secondary', variant: 'tonal' as const, disabled: false },
  { label: 'Half Day AM — 2 rooms left', icon: 'mdi-clock-outline', color: 'secondary', variant: 'tonal' as const, disabled: false },
]
</script>

<style scoped>
.calendar-wrapper {
  max-width: 480px;
  margin: 0 auto;
}

.glow-blob {
  position: absolute;
  width: 70%;
  height: 70%;
  top: 15%;
  right: -10%;
  background: radial-gradient(circle, rgba(245, 158, 11, 0.25) 0%, transparent 70%);
  filter: blur(50px);
  pointer-events: none;
  z-index: 0;
}

.calendar-card {
  position: relative;
  z-index: 1;
  overflow: hidden;
  border: 1px solid rgba(0, 0, 0, 0.06);
}

.dark .calendar-card {
  border-color: rgba(255, 255, 255, 0.06);
}

.calendar-card.tilted {
  transform: perspective(1000px) rotateY(-4deg) rotateX(2deg);
  transition: transform 0.4s ease;
}

.calendar-card.tilted:hover {
  transform: perspective(1000px) rotateY(-2deg) rotateX(1deg);
}

.calendar-grid {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  gap: 4px;
}

.calendar-day-label {
  text-align: center;
  padding: 4px 0;
}

.calendar-cell {
  aspect-ratio: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  border-radius: 8px;
  cursor: default;
  position: relative;
  transition: background 0.2s;
}

.cell-number {
  font-size: 0.8rem;
  font-weight: 500;
}

.cell-highlight .cell-number {
  color: rgb(var(--v-theme-secondary));
  font-weight: 700;
}

.cell-muted .cell-number {
  opacity: 0.35;
}

.cell-today {
  background: rgba(var(--v-theme-primary), 0.12);
}

.cell-selected {
  background: rgb(var(--v-theme-secondary)) !important;
}

.cell-selected .cell-number {
  color: white !important;
  font-weight: 700;
}

.cell-dot {
  width: 5px;
  height: 5px;
  border-radius: 50%;
  margin-top: 2px;
}

.live-badge {
  position: absolute;
  bottom: -12px;
  left: 50%;
  transform: translateX(-50%);
  background: white;
  border: 1px solid rgba(0, 0, 0, 0.08);
  border-radius: 100px;
  padding: 4px 14px;
  display: flex;
  align-items: center;
  gap: 6px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
  white-space: nowrap;
  animation: badgePulse 3s ease-in-out infinite;
}

.dark .live-badge {
  background: rgb(var(--v-theme-surface));
  border-color: rgba(255, 255, 255, 0.08);
}

.live-dot {
  width: 7px;
  height: 7px;
  border-radius: 50%;
  background: #22c55e;
  animation: dotPulse 1.5s ease-in-out infinite;
}

@keyframes dotPulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.5; transform: scale(1.3); }
}

@keyframes badgePulse {
  0%, 100% { transform: translateX(-50%) translateY(0); }
  50% { transform: translateX(-50%) translateY(-3px); }
}
</style>
