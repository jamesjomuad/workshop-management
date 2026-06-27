import type { ConferenceRoom } from '~/types'

export function useConferenceRooms() {
  const { data: rooms, pending, error, refresh } = useFetch<ConferenceRoom[]>('/api/admin/rooms')

  async function createRoom(payload: Partial<ConferenceRoom>) {
    const { data, error } = await useFetch('/api/admin/rooms', {
      method: 'POST',
      body: payload,
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
    return data
  }

  async function updateRoom(id: string, payload: Partial<ConferenceRoom>) {
    const { error } = await useFetch(`/api/admin/rooms/${id}`, {
      method: 'PUT',
      body: payload,
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function deleteRoom(id: string) {
    const { error } = await useFetch(`/api/admin/rooms/${id}`, {
      method: 'DELETE',
    })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  return { rooms, pending, error, refresh, createRoom, updateRoom, deleteRoom }
}
