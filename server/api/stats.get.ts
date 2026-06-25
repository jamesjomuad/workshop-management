import type { DashboardStats, Stat } from '~/types'

export default defineEventHandler((): DashboardStats => {
  return {
    users: { title: 'Total Users', value: '2,420', icon: 'mdi-account-group', color: 'primary', change: '+12%' },
    revenue: { title: 'Revenue', value: '$48,200', icon: 'mdi-currency-usd', color: 'success', change: '+8%' },
    orders: { title: 'Orders', value: '1,380', icon: 'mdi-shopping', color: 'warning', change: '+23%' },
    growth: { title: 'Growth', value: '14.5%', icon: 'mdi-trending-up', color: 'info', change: '+2.1%' },
  }
})
