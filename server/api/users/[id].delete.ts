export default defineEventHandler(async (event) => {
  const supabase = useAdminClient()

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  const roleRecord = await supabase
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleRecord.error) throw createError({ statusCode: 404, message: 'User not found' })

  // Ban the auth user (soft-deactivate)
  const { error: banError } = await supabase.auth.admin.updateUserById(
    roleRecord.data.user_id,
    { ban_duration: '876000h' } // ~100 years
  )

  if (banError) throw createError({ statusCode: 500, message: banError.message })

  // Remove the user_roles record
  const { error: deleteError } = await supabase
    .from('user_roles')
    .delete()
    .eq('id', id)

  if (deleteError) throw createError({ statusCode: 500, message: deleteError.message })

  return { success: true }
})
