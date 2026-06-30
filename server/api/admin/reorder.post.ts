export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()
  const { table, records } = await readBody<{
    table: 'programs' | 'program_sections' | 'program_lessons' | 'program_topics' | 'program_quizzes'
    records: { id: string; order_index: number }[]
  }>(event)

  if (!records?.length) return { success: true }

  const column = table === 'programs' ? 'order_index' : 'sort_order'

  const updates = records.map((r, i) => ({
    id: r.id,
    [column]: r.order_index ?? i,
  }))

  const { error } = await supabase.from(table).upsert(updates, { onConflict: 'id' })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return { success: true }
})
