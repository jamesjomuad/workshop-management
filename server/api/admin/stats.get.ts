export default defineEventHandler(async () => {
  const supabase = useAdminClient()

  const [roomsRes, workshopsRes, programsRes, enrollmentsRes] = await Promise.all([
    supabase.from('venues').select('*', { count: 'exact', head: true }),
    supabase.from('workshops').select('*', { count: 'exact', head: true }),
    supabase.from('programs').select('*', { count: 'exact', head: true }),
    supabase.from('enrollments').select('*', { count: 'exact', head: true }),
  ])

  return {
    rooms: { count: roomsRes.count ?? 0 },
    workshops: { count: workshopsRes.count ?? 0 },
    programs: { count: programsRes.count ?? 0 },
    enrollments: { count: enrollmentsRes.count ?? 0 },
  }
})
