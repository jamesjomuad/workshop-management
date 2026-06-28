import type { Contact } from '~/types'

export default defineEventHandler(async (): Promise<Contact[]> => {
  const supabase = useAdminClient()
  const { data, error } = await supabase
    .from('contacts')
    .select('*, companies(name)')
    .order('first_name')
  if (error) throw createError({ statusCode: 500, message: error.message })
  return (data ?? []).map((c: any) => ({
    ...c,
    company_name: c.companies?.name ?? null,
    companies: undefined,
  }))
})
