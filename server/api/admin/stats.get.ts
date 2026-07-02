import type { DashboardStats, Stat } from '~/types'

function makeStat(title: string, value: number | string, icon: string, color: string, change: string): Stat {
  return {
    title,
    value: String(value),
    icon,
    color,
    change,
  }
}

export default defineEventHandler(async (): Promise<DashboardStats> => {
  const supabase = useAdminClient()

  const [
    { count: venuesCount, error: venuesError },
    { count: workshopsCount, error: workshopsError },
    { count: programsCount, error: programsError },
    { count: contactsCount, error: contactsError },
  ] = await Promise.all([
    supabase.from('venues').select('*', { count: 'exact', head: true }),
    supabase.from('workshops').select('*', { count: 'exact', head: true }),
    supabase.from('programs').select('*', { count: 'exact', head: true }).is('deleted_at', null),
    supabase.from('contacts').select('*', { count: 'exact', head: true }).is('deleted_at', null),
  ])

  if (venuesError) throw createError({ statusCode: 500, message: venuesError.message })
  if (workshopsError) throw createError({ statusCode: 500, message: workshopsError.message })
  if (programsError) throw createError({ statusCode: 500, message: programsError.message })
  if (contactsError) throw createError({ statusCode: 500, message: contactsError.message })

  return {
    users: makeStat('Total Users', contactsCount ?? 0, 'mdi-account-group', 'primary', '+12%'),
    revenue: makeStat('Active Workshops', workshopsCount ?? 0, 'mdi-calendar-multiple', 'success', '+8%'),
    orders: makeStat('Programs', programsCount ?? 0, 'mdi-book-open-variant', 'warning', '+23%'),
    growth: makeStat('Venues', venuesCount ?? 0, 'mdi-domain', 'info', '+2.1%'),
  }
})
