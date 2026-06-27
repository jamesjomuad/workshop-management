import { createClient } from '@supabase/supabase-js'
import type { User } from '~/types'

export default defineEventHandler(async (): Promise<User[]> => {
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const { data, error } = await supabaseAdmin.auth.admin.listUsers()

  if (error) throw createError({ statusCode: 500, message: error.message })

  return data.users.map((u) => ({
    id: u.id,
    name: u.user_metadata?.full_name || u.email?.split('@')[0] || 'Unknown',
    email: u.email || '',
    role: u.user_metadata?.role || 'Viewer',
    status: u.banned_until ? 'inactive' as const : 'active' as const,
    joinedAt: u.created_at?.split('T')[0] || '',
  }))
})
