import type { DashboardStats, Stat } from '~/types'

export function useStats() {
  const { data: stats, pending, error, refresh } = useFetch<DashboardStats>('/api/admin/stats')

  const statList = computed<Stat[]>(() => {
    if (!stats.value) return []
    return [
      stats.value.users,
      stats.value.revenue,
      stats.value.orders,
      stats.value.growth,
    ]
  })

  return { stats, statList, pending, error, refresh }
}
