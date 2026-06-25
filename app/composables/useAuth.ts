import type { LoginCredentials } from '~/types'

export function useAuth() {
  const { user, loggedIn, clear, fetch } = useUserSession()

  async function login(credentials: LoginCredentials) {
    await $fetch('/api/login', {
      method: 'POST',
      body: credentials,
    })
    await fetch()
  }

  async function logout() {
    await clear()
  }

  return { user, loggedIn, login, logout }
}
