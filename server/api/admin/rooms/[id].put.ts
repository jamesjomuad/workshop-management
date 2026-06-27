import type { ConferenceRoom } from '~/types'

export default defineEventHandler(async (event): Promise<ConferenceRoom> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('conference_rooms')
    .update({
      name: body.name,
      venue_name: body.venue_name,
      venue_address: body.venue_address || null,
      floor: body.floor || null,
      capacity: body.capacity,
      notes: body.notes || null,
      status: body.status || 'available',
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
