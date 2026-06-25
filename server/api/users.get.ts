import type { User } from '~/types'

export default defineEventHandler((): User[] => {
  return [
    { id: 1, name: 'Alice Johnson', email: 'alice@example.com', role: 'Admin', status: 'active', joinedAt: '2025-01-15' },
    { id: 2, name: 'Bob Smith', email: 'bob@example.com', role: 'Editor', status: 'active', joinedAt: '2025-03-22' },
    { id: 3, name: 'Carol White', email: 'carol@example.com', role: 'Viewer', status: 'inactive', joinedAt: '2025-04-10' },
    { id: 4, name: 'David Brown', email: 'david@example.com', role: 'Editor', status: 'active', joinedAt: '2025-05-05' },
    { id: 5, name: 'Eve Davis', email: 'eve@example.com', role: 'Admin', status: 'active', joinedAt: '2025-06-18' },
    { id: 6, name: 'Frank Miller', email: 'frank@example.com', role: 'Viewer', status: 'inactive', joinedAt: '2025-07-01' },
    { id: 7, name: 'Grace Wilson', email: 'grace@example.com', role: 'Editor', status: 'active', joinedAt: '2025-08-12' },
    { id: 8, name: 'Hank Moore', email: 'hank@example.com', role: 'Viewer', status: 'active', joinedAt: '2025-09-25' },
    { id: 9, name: 'Ivy Taylor', email: 'ivy@example.com', role: 'Admin', status: 'inactive', joinedAt: '2025-10-30' },
    { id: 10, name: 'Jack Anderson', email: 'jack@example.com', role: 'Editor', status: 'active', joinedAt: '2025-11-14' },
    { id: 11, name: 'Karen Thomas', email: 'karen@example.com', role: 'Viewer', status: 'active', joinedAt: '2025-12-03' },
    { id: 12, name: 'Leo Jackson', email: 'leo@example.com', role: 'Editor', status: 'inactive', joinedAt: '2026-01-19' },
  ]
})
