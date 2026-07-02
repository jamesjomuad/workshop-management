export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  const body = await readBody(event)

  const roleRecord = await supabase
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleRecord.error) throw createError({ statusCode: 404, message: 'User not found' })

  // Update user_roles role if provided
  if (body.role) {
    const { error: roleError } = await supabase
      .from('user_roles')
      .update({ role: body.role })
      .eq('id', id)

    if (roleError) throw createError({ statusCode: 500, message: roleError.message })
  }

  // Update auth user metadata (name) if provided
  if (body.name) {
    const { error: authError } = await supabase.auth.admin.updateUserById(
      roleRecord.data.user_id,
      { user_metadata: { full_name: body.name } }
    )

    if (authError) throw createError({ statusCode: 500, message: authError.message })
  }

  return { success: true }
})
