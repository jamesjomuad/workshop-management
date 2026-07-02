import type { Venue } from '~/types'

export default defineEventHandler(async (event): Promise<Venue> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('venues')
    .update({
      name: body.name,
      type: body.type || 'other',
      address: body.address || null,
      city: body.city || null,
      province: body.province || null,
      country: body.country || null,
      postal_code: body.postal_code || null,
      latitude: body.latitude || null,
      longitude: body.longitude || null,
      contact_person: body.contact_person || null,
      contact_phone: body.contact_phone || null,
      contact_email: body.contact_email || null,
      logo_url: body.logo_url || null,
      cover_image_url: body.cover_image_url || null,
      notes: body.notes || null,
      is_active: body.is_active ?? true,
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
