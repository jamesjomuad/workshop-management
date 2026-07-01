import type { Company } from '~/types'

export default defineEventHandler(async (event): Promise<Company> => {
  const supabase = useAdminClient()
  const body = await readBody(event)
  const { data, error } = await supabase
    .from('companies')
    .insert({
      name: body.name,
      slug: body.slug || null,
      logo_url: body.logo_url || null,
      status: body.status || 'active',
      contact_email: body.contact_email || null,
      contact_phone: body.contact_phone || null,
      website: body.website || null,
      address: body.address || null,
      city: body.city || null,
      state: body.state || null,
      country: body.country || null,
      postal_code: body.postal_code || null,
      industry: body.industry || null,
      size: body.size || null,
      registration_number: body.registration_number || null,
      tax_number: body.tax_number || null,
    })
    .select()
    .single()
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
