import type { LoginCredentials, LoginResponse } from '~/types'

export default defineEventHandler(async (event) => {
  const { email, password } = await readBody<LoginCredentials>(event)

  if (email === 'admin@example.com' && password === 'password') {
    await setUserSession(event, {
      user: { name: 'Admin User', email: 'admin@example.com', avatar: '' },
    })
    return { user: { name: 'Admin User', email: 'admin@example.com', avatar: '' } } satisfies LoginResponse
  }

  throw createError({ statusCode: 401, message: 'Invalid credentials' })
})
