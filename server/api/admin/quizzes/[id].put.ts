export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')
  const body = await readBody(event)

  const { data, error } = await supabase
    .from('program_quizzes')
    .update({
      title: body.title,
      type: body.type,
      status: body.status,
      sort_order: body.sort_order,
    })
    .eq('id', id)
    .select()
    .single()

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
