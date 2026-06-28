import type { Company } from '~/types'

export function useCompanies() {
  const { data: companies, pending, error, refresh } = useFetch<Company[]>('/api/admin/companies')

  async function createCompany(payload: Partial<Company>) {
    const { error } = await useFetch('/api/admin/companies', { method: 'POST', body: payload })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function updateCompany(id: string, payload: Partial<Company>) {
    const { error } = await useFetch(`/api/admin/companies/${id}`, { method: 'PUT', body: payload })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  async function deleteCompany(id: string) {
    const { error } = await useFetch(`/api/admin/companies/${id}`, { method: 'DELETE' })
    if (error.value) throw new Error(error.value.message)
    await refresh()
  }

  return { companies, pending, error, refresh, createCompany, updateCompany, deleteCompany }
}
