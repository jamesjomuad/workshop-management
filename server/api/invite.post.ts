export default defineEventHandler(async (event) => {
  const { email } = await readBody(event)

  const supabase = useAdminClient()

  const redirectTo = process.env.AUTH_REDIRECT_URL || `${getRequestURL(event).origin}/confirm`

  const { data, error } = await supabase.auth.admin.inviteUserByEmail(email, {
    redirectTo,
  })

  if (error) throw createError({ statusCode: 500, message: error.message })

  // Create a corresponding user_roles record for FK compatibility
  await supabase
    .from('user_roles')
    .upsert({ user_id: data.user.id, role: 'trainee' }, { onConflict: 'user_id' })

  return data
})
