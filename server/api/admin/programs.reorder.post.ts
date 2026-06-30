export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()
  const { ids } = await readBody<{ ids: string[] }>(event)

  if (!ids?.length) return { success: true }

  const updates = ids.map((id, i) => ({ id, order_index: i }))
  const { error } = await supabase.from('programs').upsert(updates, { onConflict: 'id' })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { success: true }
})
