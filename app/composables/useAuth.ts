import type { LoginCredentials } from '~/types'

export function useAuth() {
  const supabase = useSupabaseClient()
  const user = useSupabaseUser()
  const router = useRouter()

  const loggedIn = computed(() => user.value !== null)

  async function login(credentials: LoginCredentials) {
    const { error } = await supabase.auth.signInWithPassword({
      email: credentials.email,
      password: credentials.password,
    })
    if (error) throw error
  }

  async function signUp(email: string, password: string, metadata?: Record<string, unknown>) {
    const origin = typeof window !== 'undefined' ? window.location.origin : ''
    const options: any = { data: metadata }
    if (origin) options.emailRedirectTo = `${origin}/confirm`
    const { data, error } = await supabase.auth.signUp({ email, password, options })
    if (error) throw error
    return data
  }

  async function logout() {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
    await router.push('/login')
  }

  async function resetPassword(email: string) {
    const origin = typeof window !== 'undefined' ? window.location.origin : ''
    const options: any = {}
    if (origin) options.redirectTo = `${origin}/confirm`
    const { error } = await supabase.auth.resetPasswordForEmail(email, options)
    if (error) throw error
  }

  async function updatePassword(password: string) {
    const { error } = await supabase.auth.updateUser({ password })
    if (error) throw error
  }

  return { user, loggedIn, login, signUp, logout, resetPassword, updatePassword }
}
