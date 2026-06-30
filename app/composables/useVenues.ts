import type { Venue, EventType, Testimonial } from '~/types'

export function useVenues() {
  const searchQuery = ref('')
  const selectedEventType = ref('')

  const {
    data: result,
    pending,
    error,
    refresh,
  } = useFetch<{ venues: Venue[]; eventTypes: EventType[]; testimonials: Testimonial[] }>(
    '/api/venues'
  )

  const venues = computed(() => result.value?.venues ?? [])
  const eventTypes = computed(() => result.value?.eventTypes ?? [])
  const testimonials = computed(() => result.value?.testimonials ?? [])

  const filteredVenues = computed(() => {
    let items = venues.value

    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      items = items.filter(
        (v) =>
          v.name.toLowerCase().includes(q) ||
          v.hotel.toLowerCase().includes(q) ||
          v.location.toLowerCase().includes(q)
      )
    }

    if (selectedEventType.value) {
      items = items.filter((v) => v.eventType === selectedEventType.value)
    }

    return items
  })

  return {
    venues,
    eventTypes,
    testimonials,
    searchQuery,
    selectedEventType,
    filteredVenues,
    pending,
    error,
    refresh,
  }
}
