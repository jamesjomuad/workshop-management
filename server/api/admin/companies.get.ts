import type { Company } from '~/types'

export default defineEventHandler(async (): Promise<Company[]> => {
  const supabase = useAdminClient()
  const { data, error } = await supabase
    .from('companies')
    .select('*')
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data ?? []
})
