import type { DashboardStats } from '~/types'

export function useStats() {
  const { data: stats, pending, error, refresh } = useFetch<DashboardStats>('/api/stats')

  const statList = computed(() => stats.value ? Object.values(stats.value) : [])

  return { stats, statList, pending, error, refresh }
}
