import type { ProgramLesson } from '~/types'

export default defineEventHandler(async (event): Promise<ProgramLesson> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('program_lessons')
    .insert({
      section_id: body.section_id,
      title: body.title,
      sort_order: body.sort_order ?? 0,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ...data, topics: [] }
})
