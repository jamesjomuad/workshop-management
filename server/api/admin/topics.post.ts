import type { ProgramTopic } from '~/types'

export default defineEventHandler(async (event): Promise<ProgramTopic> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('program_topics')
    .insert({
      lesson_id: body.lesson_id,
      title: body.title,
      sort_order: body.sort_order ?? 0,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ...data, quiz: null }
})
