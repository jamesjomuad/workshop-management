import type { Program, ProgramWithRelations, ProgramSection, ProgramLesson, ProgramTopic, ProgramQuiz } from '~/types'

export function useAdminPrograms() {
  const { data: programs, pending, error, refresh } = useFetch<ProgramWithRelations[]>('/api/admin/programs')

  async function createProgram(payload: Partial<Program>) {
    const data = await $fetch('/api/admin/programs', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateProgram(id: string, payload: Partial<Program>) {
    await $fetch(`/api/admin/programs/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteProgram(id: string) {
    await $fetch(`/api/admin/programs/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderPrograms(ids: string[]) {
    await $fetch('/api/admin/programs/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  async function createSection(payload: Partial<ProgramSection>) {
    const data = await $fetch<ProgramSection>('/api/admin/sections', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateSection(id: string, payload: Partial<ProgramSection>) {
    await $fetch(`/api/admin/sections/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteSection(id: string) {
    await $fetch(`/api/admin/sections/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderSections(ids: string[]) {
    await $fetch('/api/admin/sections/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  async function createLesson(payload: Partial<ProgramLesson>) {
    const data = await $fetch<ProgramLesson>('/api/admin/lessons', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateLesson(id: string, payload: Partial<ProgramLesson>) {
    await $fetch(`/api/admin/lessons/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteLesson(id: string) {
    await $fetch(`/api/admin/lessons/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderLessons(ids: string[]) {
    await $fetch('/api/admin/lessons/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  async function createTopic(payload: Partial<ProgramTopic>) {
    const data = await $fetch<ProgramTopic>('/api/admin/topics', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateTopic(id: string, payload: Partial<ProgramTopic>) {
    await $fetch(`/api/admin/topics/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteTopic(id: string) {
    await $fetch(`/api/admin/topics/${id}`, { method: 'DELETE' })
    await refresh()
  }

  async function reorderTopics(ids: string[]) {
    await $fetch('/api/admin/topics/reorder', { method: 'POST', body: { ids } })
    await refresh()
  }

  async function createQuiz(payload: Partial<ProgramQuiz>) {
    const data = await $fetch<ProgramQuiz>('/api/admin/quizzes', { method: 'POST', body: payload })
    await refresh()
    return data
  }

  async function updateQuiz(id: string, payload: Partial<ProgramQuiz>) {
    await $fetch(`/api/admin/quizzes/${id}`, { method: 'PUT', body: payload })
    await refresh()
  }

  async function deleteQuiz(id: string) {
    await $fetch(`/api/admin/quizzes/${id}`, { method: 'DELETE' })
    await refresh()
  }

  return {
    programs, pending, error, refresh,
    createProgram, updateProgram, deleteProgram, reorderPrograms,
    createSection, updateSection, deleteSection, reorderSections,
    createLesson, updateLesson, deleteLesson, reorderLessons,
    createTopic, updateTopic, deleteTopic, reorderTopics,
    createQuiz, updateQuiz, deleteQuiz,
  }
}
