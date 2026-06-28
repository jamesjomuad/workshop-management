import type { Contact } from '~/types'

export function useContacts() {
  const { data: contacts, pending, error, refresh } = useFetch<Contact[]>('/api/admin/contacts')

  async function createContact(payload: Partial<Contact>) {
    const { error } = await useFetch('/api/admin/contacts', { method: 'POST', body: payload })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function updateContact(id: string, payload: Partial<Contact>) {
    const { error } = await useFetch(`/api/admin/contacts/${id}`, { method: 'PUT', body: payload })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function deleteContact(id: string) {
    const { error } = await useFetch(`/api/admin/contacts/${id}`, { method: 'DELETE' })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  return { contacts, pending, error, refresh, createContact, updateContact, deleteContact }
}
