import { createClient } from '@supabase/supabase-js'

export default defineEventHandler(async (event) => {
  const { email } = await readBody(event)

  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY! // service role — server only, never expose to client
  )

  const { data, error } = await supabaseAdmin.auth.admin.inviteUserByEmail(email, {
    redirectTo: 'http://localhost:3000/confirm'
  })

  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})