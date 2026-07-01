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

  if (body.schedules) {
    const { error: delErr } = await supabase
      .from('workshop_schedules')
      .delete()
      .eq('workshop_id', id)

    if (delErr) throw createError({ statusCode: 500, message: delErr.message })

    if (body.schedules.length) {
      const { error: insErr } = await supabase
        .from('workshop_schedules')
        .insert(body.schedules.map((s: any) => ({
          workshop_id: id,
          date_start: s.date_start,
          date_end: s.date_end,
          time_start: s.time_start || null,
          time_end: s.time_end || null,
        })))

      if (insErr) throw createError({ statusCode: 500, message: insErr.message })
    }
  }

  return data
})
