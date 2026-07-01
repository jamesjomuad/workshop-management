import type { Workshop } from '~/types'

export default defineEventHandler(async (event): Promise<Workshop> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('workshops')
    .insert({
      title: body.title,
      description: body.description || null,
      date_start: body.date_start,
      date_end: body.date_end,
      conference_room_id: body.conference_room_id || null,
      facilitator_id: body.facilitator_id || null,
      client_id: body.client_id || null,
      status: body.status || 'draft',
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })

  if (body.programs?.length) {
    const { error: wpError } = await supabase
      .from('workshop_programs')
      .insert(body.programs.map((p: any) => ({
        workshop_id: data.id,
        program_id: p.program_id,
        trainer_id: p.trainer_id || null,
      })))

    if (wpError) throw createError({ statusCode: 500, message: wpError.message })
  }

  if (body.schedules?.length) {
    const { error: schError } = await supabase
      .from('workshop_schedules')
      .insert(body.schedules.map((s: any) => ({
        workshop_id: data.id,
        date_start: s.date_start,
        date_end: s.date_end,
        time_start: s.time_start || null,
        time_end: s.time_end || null,
      })))

    if (schError) throw createError({ statusCode: 500, message: schError.message })
  }

  return data
})
