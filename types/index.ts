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

export interface LoginResponse {
  user: {
    name: string
    email: string
    avatar: string
  }
}
