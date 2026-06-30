export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()
  const { ids } = await readBody<{ ids: string[] }>(event)

  if (!ids?.length) return { success: true }

  const updates = ids.map((id, i) => ({ id, sort_order: i }))
  const { error } = await supabase.from('program_lessons').upsert(updates, { onConflict: 'id' })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { success: true }
})
