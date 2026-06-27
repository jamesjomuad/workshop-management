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
  return data
})
