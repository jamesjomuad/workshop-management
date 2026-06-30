import type { ProgramQuiz } from '~/types'

export default defineEventHandler(async (event): Promise<ProgramQuiz> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('program_quizzes')
    .insert({
      topic_id: body.topic_id,
      title: body.title,
      type: body.type || 'quiz',
      sort_order: body.sort_order ?? 0,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
