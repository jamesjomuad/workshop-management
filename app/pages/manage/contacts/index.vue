<template>
  <div>
    <div class="d-flex align-center mb-4">
      <div>
        <h1 class="text-h4 font-weight-bold ma-0">Contacts</h1>
        <div class="text-caption text-medium-emphasis mt-1">{{ companies?.length ?? 0 }} companies · {{ contacts?.length ?? 0 }} people</div>
      </div>
      <v-spacer />
      <v-chip
        v-if="tab === 'contacts'"
        variant="outlined"
        size="small"
        class="me-2"
        :color="showArchived ? 'warning' : undefined"
        @click="showArchived = !showArchived"
      >
        <v-icon start size="16">{{ showArchived ? 'mdi-archive-check' : 'mdi-archive' }}</v-icon>
        {{ showArchived ? 'Archived' : 'Archived' }}
      </v-chip>
      <v-btn
        v-if="tab === 'contacts' && !showArchived"
        color="primary"
        prepend-icon="mdi-plus"
        to="/manage/contacts/new"
      >Add Contact</v-btn>
      <v-btn
        v-if="tab === 'companies'"
        color="primary"
        prepend-icon="mdi-plus"
        to="/manage/companies/new"
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
            <v-avatar size="32" :color="item.deleted_at ? 'grey' : 'primary'" variant="tonal">
              <span class="text-body-2 font-weight-medium">{{ initials(item) }}</span>
            </v-avatar>
            <span :class="{ 'text-decoration-line-through text-medium-emphasis': item.deleted_at }">
              {{ item.first_name }} {{ item.last_name }}
            </span>
          </div>
        </template>
        <template #item.company_name="{ value }">
          <v-chip v-if="value" size="small" variant="tonal" color="secondary">{{ value }}</v-chip>
          <span v-else class="text-disabled">—</span>
        </template>
        <template #item.actions="{ item }">
          <div class="d-flex ga-1">
            <v-btn v-if="!item.deleted_at" icon variant="text" size="small" :to="`/manage/contacts/${item.id}`">
              <v-icon size="18">mdi-pencil</v-icon>
            </v-btn>
            <v-btn
              v-if="item.deleted_at"
              icon
              variant="text"
              size="small"
              color="success"
              @click="handleRestore(item)"
            >
              <v-icon size="18">mdi-restore</v-icon>
            </v-btn>
            <v-btn
              v-if="!item.deleted_at"
              icon
              variant="text"
              size="small"
              color="error"
              @click="confirmDeleteContact(item)"
            >
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
        <template #item.status="{ value }">
          <v-chip size="small" variant="tonal" :color="value === 'active' ? 'success' : value === 'inactive' ? 'grey' : 'warning'">
            {{ value }}
          </v-chip>
        </template>
        <template #item.industry="{ value }">
          <span class="text-body-2">{{ value || '—' }}</span>
        </template>
        <template #item.size="{ value }">
          <span class="text-body-2">{{ value || '—' }}</span>
        </template>
        <template #item.contacts="{ item }">
          <span class="text-body-2">{{ contactCount(item.id) }}</span>
        </template>
        <template #item.actions="{ item }">
          <div class="d-flex ga-1">
            <v-btn icon variant="text" size="small" color="primary" :to="`/manage/contacts/new?company_id=${item.id}`">
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
                <v-btn variant="outlined" size="x-small" prepend-icon="mdi-plus" :to="`/manage/contacts/new?company_id=${item.id}`">Add contact</v-btn>
              </div>
              <v-data-table
                :headers="contactSubHeaders"
                :items="companyContacts(item.id)"
                density="compact"
                hide-default-footer
                class="contact-subtable"
              >
                <template #item.full_name="{ item: c }">
                  <span :class="{ 'text-decoration-line-through text-medium-emphasis': c.deleted_at }">
                    {{ c.first_name }} {{ c.last_name }}
                  </span>
                </template>
                <template #item.actions="{ item: c }">
                  <div class="d-flex ga-1">
                    <v-btn v-if="!c.deleted_at" icon variant="text" size="x-small" :to="`/manage/contacts/${c.id}`">
                      <v-icon size="16">mdi-pencil</v-icon>
                    </v-btn>
                    <v-btn
                      v-if="c.deleted_at"
                      icon
                      variant="text"
                      size="x-small"
                      color="success"
                      @click="handleRestore(c)"
                    >
                      <v-icon size="16">mdi-restore</v-icon>
                    </v-btn>
                    <v-btn v-if="!c.deleted_at" icon variant="text" size="x-small" color="error" @click="confirmDeleteContact(c)">
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

    <v-dialog v-model="companyDialog" max-width="700">
      <v-card rounded="lg">
        <v-card-title class="text-body-1 font-weight-bold">{{ editingCompany ? 'Edit Company' : 'Add Company' }}</v-card-title>
        <v-divider />
        <v-card-text class="d-flex flex-column ga-3 pt-4" style="max-height: 70vh; overflow-y: auto">
          <div class="text-subtitle-2 font-weight-bold text-medium-emphasis">Core Identity</div>
          <v-text-field v-model="companyForm.name" label="Company name *" name="name" variant="outlined" density="comfortable" hide-details="auto" :rules="[(v: any) => !!v || 'Required']" />
          <v-text-field v-model="companyForm.slug" label="Slug (URL-friendly)" name="slug" variant="outlined" density="comfortable" hide-details hint="Auto-generated from name if left empty" />
          <v-select v-model="companyForm.status" :items="statusOptions" label="Status" variant="outlined" density="comfortable" hide-details />

          <div class="text-subtitle-2 font-weight-bold text-medium-emphasis mt-2">Contact Info</div>
          <v-text-field v-model="companyForm.contact_email" label="Email" name="email" type="email" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="companyForm.contact_phone" label="Phone" name="phone" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="companyForm.website" label="Website" name="website" variant="outlined" density="comfortable" hide-details hint="https://..." />
          <v-textarea v-model="companyForm.address" label="Address" name="address" variant="outlined" density="comfortable" hide-details rows="2" />
          <v-row density="comfortable">
            <v-col cols="6"><v-text-field v-model="companyForm.city" label="City" name="city" variant="outlined" density="comfortable" hide-details /></v-col>
            <v-col cols="6"><v-text-field v-model="companyForm.state" label="State / Province" name="state" variant="outlined" density="comfortable" hide-details /></v-col>
          </v-row>
          <v-row density="comfortable">
            <v-col cols="6"><v-text-field v-model="companyForm.country" label="Country" name="country" variant="outlined" density="comfortable" hide-details /></v-col>
            <v-col cols="6"><v-text-field v-model="companyForm.postal_code" label="Postal code" name="postal_code" variant="outlined" density="comfortable" hide-details /></v-col>
          </v-row>

          <div class="text-subtitle-2 font-weight-bold text-medium-emphasis mt-2">Business Details</div>
          <v-text-field v-model="companyForm.industry" label="Industry" name="industry" variant="outlined" density="comfortable" hide-details />
          <v-select v-model="companyForm.size" :items="sizeOptions" label="Company size" variant="outlined" density="comfortable" hide-details clearable />
          <v-text-field v-model="companyForm.registration_number" label="Registration number" name="registration_number" variant="outlined" density="comfortable" hide-details />
          <v-text-field v-model="companyForm.tax_number" label="Tax number (VAT / TIN)" name="tax_number" variant="outlined" density="comfortable" hide-details />
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
          <v-btn color="error" :loading="saving" @click="confirmDelete">Archive</v-btn>
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
const showArchived = ref(false)
const { contacts, pending: ctPending, refresh: refreshContacts, deleteContact, restoreContact } = useContacts({ archived: computed(() => showArchived.value) })

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
  { title: 'Status', key: 'status', sortable: true },
  { title: 'Industry', key: 'industry', sortable: false },
  { title: 'Size', key: 'size', sortable: false },
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

const companyDialog = ref(false)
const deleteDialog = ref(false)
const editingCompany = ref<Company | null>(null)
const deletingItem = ref<Company | Contact | null>(null)
const deleteMessage = ref('')
const saving = ref(false)

const companyForm = reactive({
  name: '',
  slug: '',
  logo_url: '',
  status: 'active' as const,
  contact_email: '',
  contact_phone: '',
  website: '',
  address: '',
  city: '',
  state: '',
  country: '',
  postal_code: '',
  industry: '',
  size: null as string | null,
  registration_number: '',
  tax_number: '',
})

const statusOptions = ['active', 'inactive', 'suspended']
const sizeOptions = ['1-10', '11-50', '51-200', '200+']

function openCompanyDialog(item?: Company) {
  if (item) {
    editingCompany.value = item
    companyForm.name = item.name
    companyForm.slug = item.slug ?? ''
    companyForm.logo_url = item.logo_url ?? ''
    companyForm.status = item.status ?? 'active'
    companyForm.contact_email = item.contact_email ?? ''
    companyForm.contact_phone = item.contact_phone ?? ''
    companyForm.website = item.website ?? ''
    companyForm.address = item.address ?? ''
    companyForm.city = item.city ?? ''
    companyForm.state = item.state ?? ''
    companyForm.country = item.country ?? ''
    companyForm.postal_code = item.postal_code ?? ''
    companyForm.industry = item.industry ?? ''
    companyForm.size = item.size ?? null
    companyForm.registration_number = item.registration_number ?? ''
    companyForm.tax_number = item.tax_number ?? ''
  } else {
    editingCompany.value = null
    companyForm.name = ''
    companyForm.slug = ''
    companyForm.logo_url = ''
    companyForm.status = 'active'
    companyForm.contact_email = ''
    companyForm.contact_phone = ''
    companyForm.website = ''
    companyForm.address = ''
    companyForm.city = ''
    companyForm.state = ''
    companyForm.country = ''
    companyForm.postal_code = ''
    companyForm.industry = ''
    companyForm.size = null
    companyForm.registration_number = ''
    companyForm.tax_number = ''
  }
  companyDialog.value = true
}

async function saveCompany() {
  if (!companyForm.name) return
  saving.value = true
  try {
    const payload = {
      name: companyForm.name,
      slug: companyForm.slug || null,
      logo_url: companyForm.logo_url || null,
      status: companyForm.status,
      contact_email: companyForm.contact_email || null,
      contact_phone: companyForm.contact_phone || null,
      website: companyForm.website || null,
      address: companyForm.address || null,
      city: companyForm.city || null,
      state: companyForm.state || null,
      country: companyForm.country || null,
      postal_code: companyForm.postal_code || null,
      industry: companyForm.industry || null,
      size: companyForm.size || null,
      registration_number: companyForm.registration_number || null,
      tax_number: companyForm.tax_number || null,
    }
    if (editingCompany.value) {
      await updateCompany(editingCompany.value.id, payload)
      snackbar.value = { show: true, text: 'Company updated', color: 'success' }
    } else {
      await createCompany(payload)
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
  deleteMessage.value = `Archive "${item.first_name} ${item.last_name}"? They can be restored later.`
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
      snackbar.value = { show: true, text: 'Contact archived', color: 'success' }
    } else {
      await deleteCompany(deletingItem.value.id)
      snackbar.value = { show: true, text: 'Deleted', color: 'success' }
    }
    deleteDialog.value = false
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  } finally {
    saving.value = false
  }
}

async function handleRestore(item: Contact) {
  try {
    await restoreContact(item.id)
    snackbar.value = { show: true, text: 'Contact restored', color: 'success' }
  } catch (err: any) {
    snackbar.value = { show: true, text: err.message, color: 'error' }
  }
}

const snackbar = ref({ show: false, text: '', color: 'success' })
</script>
