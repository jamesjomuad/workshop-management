import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const id = getRouterParam(event, 'id')
  if (!id) throw createError({ statusCode: 400, message: 'Missing id' })

  const body = await readBody(event)

  const roleRecord = await supabaseAdmin
    .from('user_roles')
    .select('user_id')
    .eq('id', id)
    .single()

  if (roleRecord.error) throw createError({ statusCode: 404, message: 'User not found' })

  // Update user_roles role if provided
  if (body.role) {
    const { error: roleError } = await supabaseAdmin
      .from('user_roles')
      .update({ role: body.role })
      .eq('id', id)

    if (roleError) throw createError({ statusCode: 500, message: roleError.message })
  }

  // Update auth user metadata (name) if provided
  if (body.name) {
    const { error: authError } = await supabaseAdmin.auth.admin.updateUserById(
      roleRecord.data.user_id,
      { user_metadata: { full_name: body.name } }
    )

    if (authError) throw createError({ statusCode: 500, message: authError.message })
  }

  return { success: true }
})
