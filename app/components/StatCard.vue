<template>
  <v-card :color="color" class="pa-4" elevation="2" rounded="lg">
    <v-card-item>
      <template #prepend>
        <v-icon :icon="icon" size="40" />
      </template>
      <v-card-title class="text-h5 font-weight-bold">{{ value }}</v-card-title>
      <v-card-subtitle>{{ title }}</v-card-subtitle>
    </v-card-item>
    <v-card-text class="pa-0 pt-2">
      <v-chip size="small" :color="change.startsWith('+') ? 'green' : 'red'" variant="tonal">
        {{ change }} vs last month
      </v-chip>
    </v-card-text>
  </v-card>
</template>

<script setup lang="ts">
defineProps<{
  title: string
  value: string
  icon: string
  color: string
  change: string
}>()
</script>
