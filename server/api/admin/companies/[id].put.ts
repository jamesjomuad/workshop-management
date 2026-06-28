import type { Company } from '~/types'

export default defineEventHandler(async (event): Promise<Company> => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)
  const { data, error } = await supabase
    .from('companies')
    .update({ name: body.name, contact_email: body.contact_email || null, contact_phone: body.contact_phone || null, updated_at: new Date().toISOString() })
    .eq('id', id)
    .select()
    .single()
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
