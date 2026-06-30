import type { User } from '~/types'

export function useUsers() {
  const { data: users, pending, error, refresh } = useFetch<User[]>('/api/users')

  const activeUsers = computed(() => users.value?.filter(u => u.status === 'active') ?? [])
  const inactiveUsers = computed(() => users.value?.filter(u => u.status === 'inactive') ?? [])

  async function inviteUser(email: string) {
    await $fetch('/api/invite', { method: 'POST', body: { email } })
    await refresh()
  }

  async function updateUser(id: string, payload: { name?: string; role?: string }) {
    await $fetch(`/api/users/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteUser(id: string) {
    await $fetch(`/api/users/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function resetPassword(id: string) {
    await $fetch(`/api/users/${id}/reset-password`, { method: 'POST' })
  }

  return { users, pending, error, refresh, activeUsers, inactiveUsers, inviteUser, updateUser, deleteUser, resetPassword }
}
