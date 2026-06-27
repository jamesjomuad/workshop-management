import type { ConferenceRoom } from '~/types'

export default defineEventHandler(async (): Promise<ConferenceRoom[]> => {
  const supabase = useAdminClient()
  const { data, error } = await supabase
    .from('conference_rooms')
    .select('*')
    .order('name')

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data ?? []
})
