import type { Contact } from '~/types'

export default defineEventHandler(async (event): Promise<Contact> => {
  const supabase = useAdminClient()
  const body = await readBody(event)
  const { data, error } = await supabase
    .from('contacts')
    .insert({
      company_id: body.company_id,
      first_name: body.first_name,
      last_name: body.last_name,
      email: body.email || null,
      phone: body.phone || null,
      position: body.position || null,
      notes: body.notes || null,
    })
    .select()
    .single()
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
