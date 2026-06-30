import type { User } from '~/types'

export function useUsers() {
  const { data: users, pending, error, refresh } = useFetch<User[]>('/api/users')

  const activeUsers = computed(() => users.value?.filter(u => u.status === 'active') ?? [])
  const inactiveUsers = computed(() => users.value?.filter(u => u.status === 'inactive') ?? [])

  async function inviteUser(email: string) {
    await $fetch('/api/invite', { method: 'POST', body: { email } })
    await refresh()
  }

  return { users, pending, error, refresh, activeUsers, inactiveUsers, inviteUser }
}
