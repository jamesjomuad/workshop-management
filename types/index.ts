export interface User {
  id: number
  name: string
  email: string
  role: string
  status: 'active' | 'inactive'
  joinedAt: string
}

export interface Stat {
  title: string
  value: string
  icon: string
  color: string
  change: string
}

export interface DashboardStats {
  users: Stat
  revenue: Stat
  orders: Stat
  growth: Stat
}

export interface LoginCredentials {
  email: string
  password: string
}

export interface Venue {
  id: number
  name: string
  hotel: string
  location: string
  capacity: number
  pricePerDay: number
  rating: number
  reviewCount: number
  image: string
  amenities: string[]
  eventType: string
}

export interface EventType {
  id: string
  name: string
  icon: string
  description: string
}

export interface Testimonial {
  id: number
  name: string
  avatar: string
  title: string
  company: string
  quote: string
  rating: number
}
