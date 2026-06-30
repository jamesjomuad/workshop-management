import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  const roleRecord = await supabaseAdmin
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleRecord.error) throw createError({ statusCode: 404, message: 'User not found' })

  // Ban the auth user (soft-deactivate)
  const { error: banError } = await supabaseAdmin.auth.admin.updateUserById(
    roleRecord.data.user_id,
    { ban_duration: '876000h' } // ~100 years
  )

  if (banError) throw createError({ statusCode: 500, message: banError.message })

  // Remove the user_roles record
  const { error: deleteError } = await supabaseAdmin
    .from('user_roles')
    .delete()
    .eq('id', id)

  if (deleteError) throw createError({ statusCode: 500, message: deleteError.message })

  return { success: true }
})
