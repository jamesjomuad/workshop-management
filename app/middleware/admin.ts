export default defineNuxtRouteMiddleware(async () => {
  const user = useSupabaseUser()
  if (!user.value) {
    return navigateTo('/login')
  }

  const supabase = useSupabaseClient()
  const { data } = await supabase
    .from('user_roles')
    .select('role')
    .eq('user_id', user.value.id)
    .single()

  if (!data || !['admin', 'staff'].includes(data.role)) {
    return navigateTo('/manage')
  }
})
