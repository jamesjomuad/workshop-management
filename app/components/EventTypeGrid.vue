<template>
  <section id="event-types" class="py-12 py-md-16">
    <v-container>
      <div class="text-center mb-8">
        <h2 class="text-h4 font-weight-bold mb-2" style="color: rgb(var(--v-theme-navy));">Event Types</h2>
        <p class="text-body-1 text-medium-emphasis">From board meetings to galas — find the perfect space</p>
      </div>
      <div class="category-scroll">
        <div class="d-flex ga-4" style="min-width: max-content;">
          <v-card
            v-for="evt in eventTypes"
            :key="evt.id"
            class="event-card"
            :class="{ active: selected === evt.id }"
            @click="selectType(evt.id)"
            variant="outlined"
            rounded="xl"
            :ripple="false"
          >
            <div class="d-flex flex-column align-center pa-5" style="width: 140px;">
              <div class="event-icon-wrapper mb-3">
                <v-icon size="28" :color="selected === evt.id ? 'white' : 'primary'">{{ evt.icon }}</v-icon>
              </div>
              <span class="text-body-2 font-weight-bold text-center mb-1">{{ evt.name }}</span>
              <span class="text-caption text-grey text-center">{{ evt.description }}</span>
            </div>
          </v-card>
        </div>
      </div>
      <div class="text-center mt-6">
        <v-btn variant="text" color="primary" class="text-none" append-icon="mdi-arrow-right">
          Browse All Event Types
        </v-btn>
      </div>
    </v-container>
  </section>
</template>

<script setup lang="ts">
import type { EventType } from '~/types'

const emit = defineEmits<{ select: [id: string] }>()

defineProps<{
  eventTypes: EventType[]
}>()

const selected = ref('')

function selectType(id: string) {
  selected.value = selected.value === id ? '' : id
  emit('select', selected.value)
}
</script>

<style scoped>
.category-scroll {
  overflow-x: auto;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  padding-bottom: 8px;
}

.category-scroll::-webkit-scrollbar {
  display: none;
}

.event-card {
  cursor: pointer;
  transition: transform 0.2s, box-shadow 0.2s, background 0.2s;
  border-color: rgba(0, 0, 0, 0.08);
}

.dark .event-card {
  border-color: rgba(255, 255, 255, 0.08);
}

.event-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
}

.event-card.active {
  background: rgb(var(--v-theme-navy));
  border-color: rgb(var(--v-theme-navy));
  color: white;
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.12);
}

.event-card.active .event-icon-wrapper {
  background: rgba(255, 255, 255, 0.15);
}

.event-icon-wrapper {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(var(--v-theme-primary), 0.1);
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
