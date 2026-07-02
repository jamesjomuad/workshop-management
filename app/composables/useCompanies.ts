import type { Company } from '~/types'

export function useCompanies() {
  const { data: companies, pending, error, refresh } = useFetch<Company[]>('/api/admin/companies')

  async function createCompany(payload: Partial<Company>) {
    await $fetch('/api/admin/companies', { method: 'POST', body: payload })
    await refresh()
  }

  async function updateCompany(id: string, payload: Partial<Company>) {
    await $fetch(`/api/admin/companies/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteCompany(id: string) {
    await $fetch(`/api/admin/companies/${id}`, { method: 'DELETE' })
    await refresh()
  }

  return { companies, pending, error, refresh, createCompany, updateCompany, deleteCompany }
}
