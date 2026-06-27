export function useAdmin() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const userRole = ref<string | null>(null)
  const loading = ref(true)

  async function fetchRole() {
    if (!user.value) {
      userRole.value = null
      loading.value = false
      return
    }
    const { data } = await supabase
      .from('user_roles')
      .select('role')
      .eq('user_id', user.value.id)
      .single()
    userRole.value = data?.role ?? null
    loading.value = false
  }

  const isAdmin = computed(() => userRole.value === 'admin')
  const isStaff = computed(() => userRole.value === 'staff' || userRole.value === 'admin')
  const isTrainer = computed(() => userRole.value === 'trainer')
  const isFacilitator = computed(() => userRole.value === 'facilitator')

  return { userRole, loading, fetchRole, isAdmin, isStaff, isTrainer, isFacilitator }
}
