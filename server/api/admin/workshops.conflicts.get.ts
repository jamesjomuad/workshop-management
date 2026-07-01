import type { WorkshopWithRelations } from '~/types'

export default defineEventHandler(async (event): Promise<{ conflicts: WorkshopWithRelations[] }> => {
  const supabase = useAdminClient()
  const query = getQuery(event)

  const venueId = query.venue_id as string
  const dateStart = query.date_start as string
  const dateEnd = query.date_end as string
  const timeStart = query.time_start as string | null
  const timeEnd = query.time_end as string | null
  const excludeId = query.exclude_id as string | null

  if (!venueId || !dateStart || !dateEnd) {
    return { conflicts: [] }
  }

  let q = supabase
    .from('workshops')
    .select('*, conference_room:conference_room_id(*), client:client_id(*), workshop_programs(*, program:program_id(*)), schedules:workshop_schedules(*)')
    .eq('conference_room_id', venueId)
    .neq('status', 'cancelled')
    .lte('date_start', dateEnd)
    .gte('date_end', dateStart)

  if (excludeId) {
    q = q.neq('id', excludeId)
  }

  const { data, error } = await q

  if (error) throw createError({ statusCode: 500, message: error.message })

  const candidates = data ?? []

  if (!timeStart || !timeEnd) {
    return { conflicts: candidates }
  }

  const overlapping = candidates.filter((w) => {
    const schedules = w.schedules ?? []
    if (schedules.length === 0) return true
    return schedules.some((s) => {
      const sOverlap = s.date_start <= dateEnd && s.date_end >= dateStart
      if (!sOverlap) return false
      if (!s.time_start || !s.time_end) return true
      return timeStart < s.time_end && timeEnd > s.time_start
    })
  })

  return { conflicts: overlapping }
})
