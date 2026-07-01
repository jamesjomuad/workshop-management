import type { WorkshopWithRelations } from '~/types'

export default defineEventHandler(async (): Promise<WorkshopWithRelations[]> => {
  const supabase = useAdminClient()
  const { data, error } = await supabase
    .from('workshops')
    .select('*, conference_room:conference_room_id(*), client:client_id(*), workshop_programs(*, program:program_id(*)), schedules:workshop_schedules(*)')
    .order('date_start', { ascending: false })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data ?? []
})
