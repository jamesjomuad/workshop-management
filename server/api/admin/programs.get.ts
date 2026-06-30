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

  const [sectionsRes, workshopsRes] = await Promise.all([
    supabase.from('program_sections').select('*').in('program_id', programIds).order('sort_order'),
    supabase.from('workshop_programs').select('*, workshop:workshop_id(title, date_start, date_end, facilitator_id)').in('program_id', programIds),
  ])

  if (sectionsRes.error) throw createError({ statusCode: 500, message: sectionsRes.error.message })

  const sections = sectionsRes.data ?? []
  const sectionIds = sections.map(s => s.id)

  let lessons: any[] = []
  let topics: any[] = []
  let quizzes: any[] = []

  if (sectionIds.length) {
    const lessonsRes = await supabase.from('program_lessons').select('*').in('section_id', sectionIds).order('sort_order')
    if (lessonsRes.error) throw createError({ statusCode: 500, message: lessonsRes.error.message })
    lessons = lessonsRes.data ?? []

    const lessonIds = lessons.map(l => l.id)
    if (lessonIds.length) {
      const topicsRes = await supabase.from('program_topics').select('*').in('lesson_id', lessonIds).order('sort_order')
      if (topicsRes.error) throw createError({ statusCode: 500, message: topicsRes.error.message })
      topics = topicsRes.data ?? []

      const topicIds = topics.map(t => t.id)
      if (topicIds.length) {
        const quizzesRes = await supabase.from('program_quizzes').select('*').in('topic_id', topicIds).order('sort_order')
        if (quizzesRes.error) throw createError({ statusCode: 500, message: quizzesRes.error.message })
        quizzes = quizzesRes.data ?? []
      }
    }
  }

  const lessonsBySection = new Map<string, any[]>()
  for (const lesson of lessons) {
    const arr = lessonsBySection.get(lesson.section_id) ?? []
    arr.push(lesson)
    lessonsBySection.set(lesson.section_id, arr)
  }

  const topicsByLesson = new Map<string, any[]>()
  for (const topic of topics) {
    const arr = topicsByLesson.get(topic.lesson_id) ?? []
    arr.push(topic)
    topicsByLesson.set(topic.lesson_id, arr)
  }

  const quizzesByTopic = new Map<string, any[]>()
  for (const quiz of quizzes) {
    const arr = quizzesByTopic.get(quiz.topic_id) ?? []
    arr.push(quiz)
    quizzesByTopic.set(quiz.topic_id, arr)
  }

  const workshopByProgram = new Map<string, any>()
  for (const wp of workshopsRes.data ?? []) {
    workshopByProgram.set(wp.program_id, wp)
  }

  return programs.map((p) => {
    const wp = workshopByProgram.get(p.id)
    const programSections = (sections.filter(s => s.program_id === p.id) ?? []).map(s => ({
      ...s,
      lessons: (lessonsBySection.get(s.id) ?? []).map(l => ({
        ...l,
        topics: (topicsByLesson.get(l.id) ?? []).map(t => ({
          ...t,
          quiz: quizzesByTopic.get(t.id)?.[0] ?? null,
        })),
      })),
    }))

    return {
      ...p,
      workshop_label: wp?.workshop?.title ?? '',
      workshop_date_start: wp?.workshop?.date_start ?? '',
      workshop_date_end: wp?.workshop?.date_end ?? '',
      trainer_name: '',
      sections: programSections,
    }
  })
})
