export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()
  const id = getRouterParam(event, 'id')

  const { error } = await supabase.from('program_sections').delete().eq('id', id)
  if (error) throw createError({ statusCode: 500, message: error.message })
  return { success: true }
})
