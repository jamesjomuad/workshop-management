import type { Program } from '~/types'

export default defineEventHandler(async (event): Promise<Program> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('programs')
    .insert({
      title: body.title,
      description: body.description || null,
      status: body.status || 'upcoming',
      created_by: body.created_by || null,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
