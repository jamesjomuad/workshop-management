import type { Workshop, WorkshopWithRelations, ConferenceRoom, Company } from '~/types'

export function useAdminWorkshops() {
  const { data: workshops, pending, error, refresh } = useFetch<WorkshopWithRelations[]>('/api/admin/workshops')
  const { data: rooms } = useFetch<ConferenceRoom[]>('/api/admin/rooms')
  const { data: companies } = useFetch<Company[]>('/api/admin/companies')

  async function createWorkshop(payload: Partial<Workshop>) {
    const { data, error } = await useFetch('/api/admin/workshops', {
      method: 'POST',
      body: payload,
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
    return data
  }

  async function updateWorkshop(id: string, payload: Partial<Workshop>) {
    const { error } = await useFetch(`/api/admin/workshops/${id}`, {
      method: 'PUT',
      body: payload,
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function deleteWorkshop(id: string) {
    const { error } = await useFetch(`/api/admin/workshops/${id}`, {
      method: 'DELETE',
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  return { workshops, rooms, companies, pending, error, refresh, createWorkshop, updateWorkshop, deleteWorkshop }
}
