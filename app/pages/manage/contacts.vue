<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold">Contacts</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ companies?.length ?? 0 }} companies · {{ contacts?.length ?? 0 }} people</div>
      </div>
      <v-spacer />
      <v-btn
        v-if="tab === 'contacts'"
        color="primary"
        prepend-icon="mdi-plus"
        @click="openContactDialog()"
      >Add Contact</v-btn>
      <v-btn
        v-if="tab === 'companies'"
        color="primary"
        prepend-icon="mdi-plus"
        @click="openCompanyDialog()"
      >Add Company</v-btn>
    </div>

    <v-card variant="outlined" rounded="lg">
      <v-tabs v-model="tab" color="primary" class="px-4 pt-2">
        <v-tab value="contacts" prepend-icon="mdi-account-multiple">Contacts</v-tab>
        <v-tab value="companies" prepend-icon="mdi-domain">Companies</v-tab>
      </v-tabs>
      <v-divider />

      <v-text-field
        v-if="tab === 'contacts'"
        v-model="search"
        prepend-inner-icon="mdi-magnify"
        label="Search contacts..."
        variant="outlined"
        density="comfortable"
        hide-details
        clearable
        class="pa-4 pb-0"
      />

      <v-data-table
        v-if="tab === 'contacts'"
        :headers="contactHeaders"
        :items="filteredContacts"
        :loading="loading"
        item-value="id"
        density="comfortable"
      >
        <template #item.full_name="{ item }">
          <div class="d-flex align-center ga-2">
            <v-avatar size="32" color="primary" variant="tonal">
              <span class="text-body-2 font-weight-medium">{{ initials(item) }}</span>
            </v-avatar>
            <span>{{ item.first_name }} {{ item.last_name }}</span>
          </div>
        </template>
        <template #item.company_name="{ value }">
          <v-chip v-if="value" size="small" variant="tonal" color="secondary">{{ value }}</v-chip>
          <span v-else class="text-disabled">—</span>
        </template>
        <template #item.actions="{ item }">
          <div class="d-flex ga-1">
            <v-btn icon variant="text" size="small" @click="openContactDialog(item)">
              <v-icon size="18">mdi-pencil</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" color="error" @click="confirmDeleteContact(item)">
              <v-icon size="18">mdi-delete</v-icon>
            </v-btn>
          </div>
        </template>
      </v-data-table>

      <v-data-table
        v-if="tab === 'companies'"
        :headers="companyHeaders"
        :items="companies ?? []"
        :loading="loading"
        show-expand
        item-value="id"
        density="comfortable"
      >
        <template #item.contact_email="{ value }">
          <span class="text-body-2">{{ value || '—' }}</span>
        </template>
        <template #item.contact_phone="{ value }">
          <span class="text-body-2">{{ value || '—' }}</span>
        </template>
        <template #item.contacts="{ item }">
          <span class="text-body-2">{{ contactCount(item.id) }}</span>
        </template>
        <template #item.actions="{ item }">
          <div class="d-flex ga-1">
            <v-btn icon variant="text" size="small" color="primary" @click="openContactDialog(item.id)">
              <v-icon size="18">mdi-account-plus</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" @click="openCompanyDialog(item)">
              <v-icon size="18">mdi-pencil</v-icon>
            </v-btn>
            <v-btn icon variant="text" size="small" color="error" @click="confirmDeleteCompany(item)">
              <v-icon size="18">mdi-delete</v-icon>
            </v-btn>
          </div>
        </template>
        <template #expanded-row="{ item }">
          <tr>
            <td :colspan="companyHeaders.length + 1" class="pa-4 bg-grey-lighten-5">
              <div class="d-flex align-center mb-2">
                <span class="text-body-2 font-weight-bold">Contacts</span>
                <v-spacer />
                <v-btn variant="outlined" size="x-small" prepend-icon="mdi-plus" @click="openContactDialog(item.id)">Add contact</v-btn>
              </div>
              <v-data-table
                :headers="contactSubHeaders"
                :items="companyContacts(item.id)"
                density="compact"
                hide-default-footer
                class="contact-subtable"
              >
                <template #item.full_name="{ item: c }">
                  {{ c.first_name }} {{ c.last_name }}
                </template>
                <template #item.actions="{ item: c }">
                  <div class="d-flex ga-1">
                    <v-btn icon variant="text" size="x-small" @click="openContactDialog(item.id, c)">
                      <v-icon size="16">mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn icon variant="text" size="x-small" color="error" @click="confirmDeleteContact(c)">
                      <v-icon size="16">mdi-delete</v-icon>
                    </v-btn>
                  </div>
                </template>
              </v-data-table>
            </td>
          </tr>
        </template>
      </v-data-table>
    </v-card>

    <v-dialog v-model="contactDialog" max-width="500">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">{{ editingContact ? 'Edit Contact' : 'Add Contact' }}</v-card-title>
        <v-divider />
        <v-card-text class="d-flex flex-column ga-3 pt-4">
          <v-autocomplete
            v-model="contactForm.company_id"
            :items="companies ?? []"
            item-title="name"
            item-value="id"
            label="Company"
            variant="outlined"
            density="comfortable"
            hide-details
            clearable
          />
          <v-row>
            <v-col cols="6">
              <v-text-field v-model="contactForm.first_name" label="First name *" name="first_name" variant="outlined" density="comfortable" hide-details="auto" :rules="[(v: any) => !!v || 'Required']" />
            </v-col>
            <v-col cols="6">
              <v-text-field v-model="contactForm.last_name" label="Last name *" name="last_name" variant="outlined" density="comfortable" hide-details="auto" :rules="[(v: any) => !!v || 'Required']" />
            </v-col>
          </v-row>
          <v-text-field v-model="contactForm.email" label="Email" name="email" type="email" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="contactForm.phone" label="Phone" name="phone" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="contactForm.position" label="Position / Job title" name="position" variant="outlined" density="comfortable" hide-details />
          <v-textarea v-model="contactForm.notes" label="Notes" name="notes" variant="outlined" density="comfortable" rows="2" hide-details />
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="contactDialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="saving" @click="saveContact">{{ editingContact ? 'Save' : 'Add' }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="companyDialog" max-width="500">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">{{ editingCompany ? 'Edit Company' : 'Add Company' }}</v-card-title>
        <v-divider />
        <v-card-text class="d-flex flex-column ga-3 pt-4">
          <v-text-field v-model="companyForm.name" label="Company name *" name="name" variant="outlined" density="comfortable" hide-details="auto" :rules="[(v: any) => !!v || 'Required']" />
          <v-text-field v-model="companyForm.contact_email" label="Email" name="email" type="email" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="companyForm.contact_phone" label="Phone" name="phone" variant="outlined" density="comfortable" hide-details />
        </v-card-text>
        <v-divider />
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="companyDialog = false">Cancel</v-btn>
          <v-btn color="primary" :loading="saving" @click="saveCompany">{{ editingCompany ? 'Save' : 'Add' }}</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-dialog v-model="deleteDialog" max-width="400">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">Confirm delete</v-card-title>
        <v-card-text>{{ deleteMessage }}</v-card-text>
        <v-card-actions class="pa-4">
          <v-spacer />
          <v-btn variant="outlined" @click="deleteDialog = false">Cancel</v-btn>
          <v-btn color="error" :loading="saving" @click="confirmDelete">Delete</v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-snackbar v-model="snackbar.show" :color="snackbar.color" timeout="3000">{{ snackbar.text }}</v-snackbar>
  </div>
</template>

<script setup lang="ts">
definePageMeta({ layout: 'dashboard', middleware: 'auth' })

import type { Company, Contact } from '~/types'

const { companies, pending: coPending, refresh: refreshCompanies, createCompany, updateCompany, deleteCompany } = useCompanies()
const { contacts, pending: ctPending, refresh: refreshContacts, createContact, updateContact, deleteContact } = useContacts()

const loading = computed(() => coPending.value || ctPending.value)
const tab = ref('contacts')
const search = ref('')

const contactHeaders = [
  { title: 'Name', key: 'full_name', sortable: true },
  { title: 'Email', key: 'email', sortable: false },
  { title: 'Phone', key: 'phone', sortable: false },
  { title: 'Company', key: 'company_name', sortable: false },
  { title: 'Position', key: 'position', sortable: false },
  { title: '', key: 'actions', sortable: false, width: 96 },
]

const filteredContacts = computed(() => {
  if (!search.value || !contacts.value) return contacts.value ?? []
  const q = search.value.toLowerCase()
  return contacts.value.filter(c =>
    c.first_name.toLowerCase().includes(q) ||
    c.last_name.toLowerCase().includes(q) ||
    (c.email && c.email.toLowerCase().includes(q)) ||
    (c.company_name && c.company_name.toLowerCase().includes(q)) ||
    (c.position && c.position.toLowerCase().includes(q)) ||
    (c.phone && c.phone.includes(q))
  )
})

function initials(c: Contact) {
  return (c.first_name[0] + c.last_name[0]).toUpperCase()
}

const companyHeaders = [
  { title: 'Company', key: 'name', sortable: true },
  { title: 'Email', key: 'contact_email', sortable: false },
  { title: 'Phone', key: 'contact_phone', sortable: false },
  { title: 'Contacts', key: 'contacts', sortable: false },
  { title: 'Actions', key: 'actions', sortable: false, width: 136 },
]

const contactSubHeaders = [
  { title: 'Name', key: 'full_name', sortable: true },
  { title: 'Email', key: 'email', sortable: false },
  { title: 'Phone', key: 'phone', sortable: false },
  { title: 'Position', key: 'position', sortable: false },
  { title: 'Actions', key: 'actions', sortable: false, width: 100 },
]

function contactCount(companyId: string) {
  return contacts.value?.filter(c => c.company_id === companyId).length ?? 0
}

function companyContacts(companyId: string) {
  return contacts.value?.filter(c => c.company_id === companyId) ?? []
}

const contactDialog = ref(false)
const companyDialog = ref(false)
const deleteDialog = ref(false)
const editingContact = ref<Contact | null>(null)
const editingCompany = ref<Company | null>(null)
const deletingItem = ref<Company | Contact | null>(null)
const deleteMessage = ref('')
const saving = ref(false)

const companyForm = reactive({ name: '', contact_email: '', contact_phone: '' })
const contactForm = reactive({ company_id: '', first_name: '', last_name: '', email: '', phone: '', position: '', notes: '' })

function openContactDialog(companyIdOrItem?: string | Contact, item?: Contact) {
  const existing = item ?? (typeof companyIdOrItem === 'object' ? companyIdOrItem : undefined)
  const coId = existing ? existing.company_id : (typeof companyIdOrItem === 'string' ? companyIdOrItem : '')
  if (existing) {
    editingContact.value = existing
    contactForm.company_id = existing.company_id ?? ''
    contactForm.first_name = existing.first_name
    contactForm.last_name = existing.last_name
    contactForm.email = existing.email ?? ''
    contactForm.phone = existing.phone ?? ''
    contactForm.position = existing.position ?? ''
    contactForm.notes = existing.notes ?? ''
  } else {
    editingContact.value = null
    contactForm.company_id = coId
    contactForm.first_name = ''
    contactForm.last_name = ''
    contactForm.email = ''
    contactForm.phone = ''
    contactForm.position = ''
    contactForm.notes = ''
  }
  contactDialog.value = true
}

async function saveContact() {
  if (!contactForm.first_name || !contactForm.last_name) return
  saving.value = true
  try {
    const payload = {
      company_id: contactForm.company_id || null,
      first_name: contactForm.first_name,
      last_name: contactForm.last_name,
      email: contactForm.email || null,
      phone: contactForm.phone || null,
      position: contactForm.position || null,
      notes: contactForm.notes || null,
    }
    if (editingContact.value) {
      await updateContact(editingContact.value.id, payload)
      snackbar.value = { show: true, text: 'Contact updated', color: 'success' }
    } else {
      await createContact(payload)
      snackbar.value = { show: true, text: 'Contact added', color: 'success' }
    }
    contactDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    saving.value = false
  }
}

function openCompanyDialog(item?: Company) {
  if (item) {
    editingCompany.value = item
    companyForm.name = item.name
    companyForm.contact_email = item.contact_email ?? ''
    companyForm.contact_phone = item.contact_phone ?? ''
  } else {
    editingCompany.value = null
    companyForm.name = ''
    companyForm.contact_email = ''
    companyForm.contact_phone = ''
  }
  companyDialog.value = true
}

async function saveCompany() {
  if (!companyForm.name) return
  saving.value = true
  try {
    if (editingCompany.value) {
      await updateCompany(editingCompany.value.id, { name: companyForm.name, contact_email: companyForm.contact_email || null, contact_phone: companyForm.contact_phone || null })
      snackbar.value = { show: true, text: 'Company updated', color: 'success' }
    } else {
      await createCompany({ name: companyForm.name, contact_email: companyForm.contact_email || null, contact_phone: companyForm.contact_phone || null })
      snackbar.value = { show: true, text: 'Company added', color: 'success' }
    }
    companyDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    saving.value = false
  }
}

function confirmDeleteContact(item: Contact) {
  deletingItem.value = item
  deleteMessage.value = `Delete ${item.first_name} ${item.last_name}?`
  deleteDialog.value = true
}

function confirmDeleteCompany(item: Company) {
  deletingItem.value = item
  deleteMessage.value = `Delete "${item.name}" and all its contacts?`
  deleteDialog.value = true
}

async function confirmDelete() {
  if (!deletingItem.value) return
  saving.value = true
  try {
    if ('first_name' in deletingItem.value) {
      await deleteContact(deletingItem.value.id)
    } else {
      await deleteCompany(deletingItem.value.id)
    }
    snackbar.value = { show: true, text: 'Deleted', color: 'success' }
    deleteDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    saving.value = false
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>
