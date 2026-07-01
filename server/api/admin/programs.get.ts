import type { ProgramWithRelations } from '~/types'

export default defineEventHandler(async (): Promise<ProgramWithRelations[]> => {
  const supabase = useAdminClient()

  const { data: programs, error } = await supabase
    .from('programs')
    .select('*')
    .order('order_index')
    .order('created_at', { ascending: false })

  if (error) throw createError({ statusCode: 500, message: error.message })
  if (!programs?.length) return []

  const programIds = programs.map(p => p.id)

  const [topicsRes, workshopsRes] = await Promise.all([
    supabase.from('program_topics').select('*').in('program_id', programIds).order('sort_order'),
    supabase.from('workshop_programs').select('*, workshop:workshop_id(title, date_start, date_end, facilitator_id)').in('program_id', programIds),
  ])

  if (topicsRes.error) throw createError({ statusCode: 500, message: topicsRes.error.message })

  const topicsByProgram = new Map<string, any[]>()
  for (const topic of topicsRes.data ?? []) {
    const arr = topicsByProgram.get(topic.program_id) ?? []
    arr.push(topic)
    topicsByProgram.set(topic.program_id, arr)
  }

  const workshopByProgram = new Map<string, any>()
  for (const wp of workshopsRes.data ?? []) {
    workshopByProgram.set(wp.program_id, wp)
  }

  return programs.map((p) => {
    const wp = workshopByProgram.get(p.id)
    return {
      ...p,
      workshop_label: wp?.workshop?.title ?? '',
      workshop_date_start: wp?.workshop?.date_start ?? '',
      workshop_date_end: wp?.workshop?.date_end ?? '',
      trainer_name: '',
      topics: topicsByProgram.get(p.id) ?? [],
    }
  })
})
