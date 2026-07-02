import type { Venue } from '~/types'

export default defineEventHandler(async (): Promise<Venue[]> => {
  const supabase = useAdminClient()
  const { data, error } = await supabase
    .from('venues')
    .select('*')
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data ?? []
})
