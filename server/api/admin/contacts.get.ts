import type { Contact } from '~/types'

export default defineEventHandler(async (event): Promise<Contact[]> => {
  const supabase = useAdminClient()
  const query = getQuery(event)
  const includeArchived = query.archived === 'true'

  let builder = supabase
    .from('contacts')
    .select('*, companies(name)')
    .order('first_name')

  if (!includeArchived) {
    builder = builder.is('deleted_at', 'null')
  }

  const { data, error } = await builder
  if (error) throw createError({ statusCode: 500, message: error.message })
  return (data ?? []).map((c: any) => ({
    ...c,
    company_name: c.companies?.name ?? null,
    companies: undefined,
  }))
})
