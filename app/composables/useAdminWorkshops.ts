import type { Workshop, WorkshopWithRelations, ConferenceRoom, Company } from '~/types'

export function useAdminWorkshops() {
  const { data: workshops, pending, error, refresh } = useFetch<WorkshopWithRelations[]>('/api/admin/workshops')
  const { data: venues } = useFetch<ConferenceRoom[]>('/api/admin/rooms')
  const { data: companies } = useFetch<Company[]>('/api/admin/companies')

  async function createWorkshop(payload: Partial<Workshop>) {
    const data = await $fetch('/api/admin/workshops', {
      method: 'POST',
      body: payload,
    })
    await refresh()
    return data
  }

  async function updateWorkshop(id: string, payload: Partial<Workshop>) {
    await $fetch(`/api/admin/workshops/${id}`, {
      method: 'PUT',
      body: payload,
    })
    await refresh()
  }

  async function deleteWorkshop(id: string) {
    await $fetch(`/api/admin/workshops/${id}`, {
      method: 'DELETE',
    })
    await refresh()
  }

  return { workshops, venues, companies, pending, error, refresh, createWorkshop, updateWorkshop, deleteWorkshop }
}
