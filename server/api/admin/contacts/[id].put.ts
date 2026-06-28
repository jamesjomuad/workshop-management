import type { Contact } from '~/types'

export default defineEventHandler(async (event): Promise<Contact> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)
  const { data, error } = await supabase
    .from('contacts')
    .update({
      company_id: body.company_id,
      first_name: body.first_name,
      last_name: body.last_name,
      email: body.email || null,
      phone: body.phone || null,
      position: body.position || null,
      notes: body.notes || null,
      updated_at: new Date().toISOString(),
    })
    .eq('id', id)
    .select()
    .single()
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
