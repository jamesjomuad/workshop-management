import type { Contact } from '~/types'

export function useContacts(opts?: { archived?: boolean | Ref<boolean> }) {
  const archived = computed(() => {
    if (!opts?.archived) return false
    return toValue(opts.archived)
  })

  const query = computed(() => archived.value ? '?archived=true' : '')
  const { data: contacts, pending, error, refresh } = useFetch<Contact[]>(() => `/api/admin/contacts${query.value}`)

  async function createContact(payload: Partial<Contact>) {
    await $fetch('/api/admin/contacts', { method: 'POST', body: payload })
    await refresh()
  }

  async function updateContact(id: string, payload: Partial<Contact>) {
    await $fetch(`/api/admin/contacts/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteContact(id: string) {
    await $fetch(`/api/admin/contacts/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function restoreContact(id: string) {
    await updateContact(id, { deleted_at: null })
  }

  return { contacts, pending, error, refresh, createContact, updateContact, deleteContact, restoreContact }
}
