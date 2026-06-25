<template>
  <v-row>
    <v-col cols="12" md="6">
      <v-card elevation="2" rounded="lg">
        <v-card-title class="text-h6">Profile</v-card-title>
        <v-card-text>
          <v-form>
            <v-text-field label="Name" value="Admin User" prepend-inner-icon="mdi-account" />
            <v-text-field label="Email" value="admin@example.com" prepend-inner-icon="mdi-email" />
            <v-select
              label="Timezone"
              :items="timezones"
              value="UTC"
              prepend-inner-icon="mdi-clock"
            />
            <v-btn color="primary" class="mt-2">Save Profile</v-btn>
          </v-form>
        </v-card-text>
      </v-card>
    </v-col>
    <v-col cols="12" md="6">
      <v-card elevation="2" rounded="lg">
        <v-card-title class="text-h6">App Settings</v-card-title>
        <v-card-text>
          <v-switch label="Email notifications" model-value="true" color="primary" />
          <v-switch label="Dark mode (global)" color="primary" />
          <v-select
            label="Language"
            :items="['English', 'Spanish', 'French']"
            value="English"
            prepend-inner-icon="mdi-translate"
          />
          <v-btn color="primary" class="mt-2">Save Settings</v-btn>
        </v-card-text>
      </v-card>
    </v-col>
  </v-row>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'admin', middleware: 'auth' })

const timezones = ['UTC', 'America/New_York', 'America/Chicago', 'America/Denver', 'America/Los_Angeles', 'Europe/London', 'Europe/Berlin', 'Asia/Tokyo']
</script>
