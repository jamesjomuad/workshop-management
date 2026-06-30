import type { ProgramSection } from '~/types'

export default defineEventHandler(async (event): Promise<ProgramSection> => {
  const supabase = useAdminClient()
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('program_sections')
    .insert({
      program_id: body.program_id,
      title: body.title,
      sort_order: body.sort_order ?? 0,
    })
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { ...data, lessons: [] }
})
