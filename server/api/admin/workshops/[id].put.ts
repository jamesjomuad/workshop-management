import type { Workshop } from '~/types'

export default defineEventHandler(async (event): Promise<Workshop> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('workshops')
    .update({
      title: body.title,
      description: body.description || null,
      date_start: body.date_start,
      date_end: body.date_end,
      time_start: body.time_start || null,
      time_end: body.time_end || null,
      conference_room_id: body.conference_room_id || null,
      facilitator_id: body.facilitator_id || null,
      client_id: body.client_id || null,
      status: body.status || 'draft',
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })

  if (body.programs) {
    const { error: delError } = await supabase
      .from('workshop_programs')
      .delete()
      .eq('workshop_id', id)

    if (delError) throw createError({ statusCode: 500, message: delError.message })

    if (body.programs.length) {
      const { error: insError } = await supabase
        .from('workshop_programs')
        .insert(body.programs.map((p: any) => ({
          workshop_id: id,
          program_id: p.program_id,
          trainer_id: p.trainer_id || null,
        })))

      if (insError) throw createError({ statusCode: 500, message: insError.message })
    }
  }

  return data
})
