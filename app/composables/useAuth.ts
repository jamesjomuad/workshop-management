import type { LoginCredentials } from '~/types'

export function useAuth() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()

  const loggedIn = computed(() => user.value !== null)

  async function login(credentials: LoginCredentials) {
    const { error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    })
    if (error) throw error
  }

  async function logout() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return { user, loggedIn, login, logout }
}
