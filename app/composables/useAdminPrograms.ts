import type { Program, ProgramWithRelations, ProgramTopic } from '~/types'

export function useAdminPrograms() {
  const { data: programs, pending, error, refresh } = useFetch<ProgramWithRelations[]>('/api/admin/programs')

  async function createProgram(payload: Partial<Program>) {
    const data = await $fetch('/api/admin/programs', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateProgram(id: string, payload: Partial<Program>) {
    await $fetch(`/api/admin/programs/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteProgram(id: string) {
    await $fetch(`/api/admin/programs/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderPrograms(ids: string[]) {
    await $fetch('/api/admin/programs/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  async function createTopic(payload: Partial<ProgramTopic>) {
    const data = await $fetch<ProgramTopic>('/api/admin/topics', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateTopic(id: string, payload: Partial<ProgramTopic>) {
    await $fetch(`/api/admin/topics/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteTopic(id: string) {
    await $fetch(`/api/admin/topics/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderTopics(ids: string[]) {
    await $fetch('/api/admin/topics/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  return {
    programs, pending, error, refresh,
    createProgram, updateProgram, deleteProgram, reorderPrograms,
    createTopic, updateTopic, deleteTopic, reorderTopics,
  }
}
