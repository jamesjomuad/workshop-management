import type { Workshop, Category, Testimonial } from '~/types'

export function useWorkshops() {
  const searchQuery = ref('')
  const selectedCategory = ref('')

  const {
    data: result,
    pending,
    error,
    refresh,
  } = useFetch<{ workshops: Workshop[]; categories: Category[]; testimonials: Testimonial[] }>(
    '/api/workshops'
  )

  const workshops = computed(() => result.value?.workshops ?? [])
  const categories = computed(() => result.value?.categories ?? [])
  const testimonials = computed(() => result.value?.testimonials ?? [])

  const filteredWorkshops = computed(() => {
    let items = workshops.value

    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      items = items.filter(
        (w) =>
          w.title.toLowerCase().includes(q) ||
          w.host.toLowerCase().includes(q) ||
          w.category.toLowerCase().includes(q)
      )
    }

    if (selectedCategory.value) {
      items = items.filter((w) => w.category === selectedCategory.value)
    }

    return items
  })

  return {
    workshops,
    categories,
    testimonials,
    searchQuery,
    selectedCategory,
    filteredWorkshops,
    pending,
    error,
    refresh,
  }
}
