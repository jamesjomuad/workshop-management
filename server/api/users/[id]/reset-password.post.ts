import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  // Look up user_roles to get user_id, then get the auth user's email
  const { data: roleRecord, error: roleError } = await supabaseAdmin
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleError || !roleRecord) throw createError({ statusCode: 404, message: 'User not found' })

  const { data: authUser, error: authError } = await supabaseAdmin.auth.admin.getUserById(roleRecord.user_id)
  if (authError || !authUser?.user?.email) throw createError({ statusCode: 500, message: 'Could not retrieve user email' })

  // Generate a recovery link (triggers password reset email)
  const { data, error } = await supabaseAdmin.auth.admin.generateLink({
    type: 'recovery',
    email: authUser.user.email,
    options: { redirectTo: 'http://localhost:3000/confirm' },
  })

  if (error) throw createError({ statusCode: 500, message: error.message })

  return { success: true }
})
