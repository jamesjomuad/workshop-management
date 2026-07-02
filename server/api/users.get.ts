import type { User } from '~/types'

export default defineEventHandler(async (): Promise<User[]> => {
  const supabase = useAdminClient()

  const { data: authData, error: authError } = await supabase.auth.admin.listUsers()
  if (authError) throw createError({ statusCode: 500, message: authError.message })

  const userIds = authData.users.map(u => u.id)

  const { data: roles, error: rolesError } = await supabase
    .from('user_roles')
    .select('id, user_id, role')
    .in('user_id', userIds)

  if (rolesError) throw createError({ statusCode: 500, message: rolesError.message })

  // Build a map of user_id -> user_roles record
  const roleMap = new Map(roles?.map(r => [r.user_id, r]) ?? [])

  // Ensure every auth user has a user_roles record
  const toInsert = userIds.filter(id => !roleMap.has(id))
  for (const userId of toInsert) {
    const authUser = authData.users.find(u => u.id === userId)
    const defaultRole = authUser?.user_metadata?.role || 'trainee'
    const { data: newRole, error: insertError } = await supabase
      .from('user_roles')
      .insert({ user_id: userId, role: defaultRole })
      .select('id, user_id, role')
      .single()

    if (!insertError && newRole) {
      roleMap.set(userId, newRole)
    }
  }

  return authData.users.map((u) => {
    const role = roleMap.get(u.id)
    return {
      id: role?.id || u.id,
      name: u.user_metadata?.full_name || u.email?.split('@')[0] || 'Unknown',
      email: u.email || '',
      role: role?.role || u.user_metadata?.role || 'trainee',
      status: u.banned_until ? 'inactive' as const : 'active' as const,
      joinedAt: u.created_at?.split('T')[0] || '',
    }
  })
})
