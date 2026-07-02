export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  // Look up user_roles to get user_id, then get the auth user's email
  const { data: roleRecord, error: roleError } = await supabase
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleError || !roleRecord) throw createError({ statusCode: 404, message: 'User not found' })

  const { data: authUser, error: authError } = await supabase.auth.admin.getUserById(roleRecord.user_id)
  if (authError || !authUser?.user?.email) throw createError({ statusCode: 500, message: 'Could not retrieve user email' })

  const redirectTo = process.env.AUTH_REDIRECT_URL || `${getRequestURL(event).origin}/confirm`

  // Generate a recovery link (triggers password reset email)
  const { data, error } = await supabase.auth.admin.generateLink({
    type: 'recovery',
    email: authUser.user.email,
    options: { redirectTo },
  })

  if (error) throw createError({ statusCode: 500, message: error.message })

  return { success: true }
})
