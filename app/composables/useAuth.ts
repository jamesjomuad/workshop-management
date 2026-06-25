import type { LoginCredentials } from '~/types'

export function useAuth() {
  const { user, loggedIn, login: sessionLogin, logout: sessionLogout, fetch } = useUserSession()

  async function login(credentials: LoginCredentials) {
    await $fetch('/api/login', {
      method: 'POST',
      body: credentials,
    })
    await fetch()
  }

  async function logout() {
    await sessionLogout()
  }

  return { user, loggedIn, login, logout }
}
