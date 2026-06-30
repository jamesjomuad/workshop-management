export interface User {
  id: string
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

export type UserRole = 'admin' | 'staff' | 'trainer' | 'facilitator' | 'trainee' | 'client'

export interface UserRoleRecord {
  id: string
  user_id: string
  role: UserRole
  company_id: string | null
  created_at: string
}

export interface Company {
  id: string
  name: string
  contact_email: string | null
  contact_phone: string | null
  created_at: string
  updated_at: string
}

export interface ConferenceRoom {
  id: string
  name: string
  venue_name: string
  venue_address: string | null
  floor: string | null
  capacity: number
  notes: string | null
  status: 'available' | 'booked' | 'in_use'
  created_at: string
  updated_at: string
}

export type WorkshopStatus = 'draft' | 'published' | 'ongoing' | 'completed' | 'cancelled'

export interface Workshop {
  id: string
  title: string
  description: string | null
  date_start: string
  date_end: string
  conference_room_id: string | null
  facilitator_id: string | null
  client_id: string | null
  status: WorkshopStatus
  created_at: string
  updated_at: string
}

export interface WorkshopWithRelations extends Workshop {
  venue?: ConferenceRoom
  client?: Company
}

export interface Program {
  id: string
  title: string
  description: string | null
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface WorkshopProgram {
  id: string
  workshop_id: string
  program_id: string
  trainer_id: string | null
  notes: string | null
}

export interface Session {
  id: string
  workshop_program_id: string
  title: string
  day_number: number
  time_start: string
  time_end: string
  status: 'upcoming' | 'ongoing' | 'completed'
  created_at: string
  updated_at: string
}

export interface Enrollment {
  id: string
  workshop_id: string
  trainee_id: string
  enrolled_by: 'self' | 'company'
  payment_status: 'paid' | 'pending' | 'waived'
  created_at: string
}

export interface Attendance {
  id: string
  session_id: string
  enrollment_id: string
  status: 'present' | 'absent' | 'late'
  marked_at: string
  marked_by: string | null
}

export interface Contact {
  id: string
  company_id: string
  first_name: string
  last_name: string
  email: string | null
  phone: string | null
  position: string | null
  notes: string | null
  company_name?: string
  created_at: string
  updated_at: string
}
