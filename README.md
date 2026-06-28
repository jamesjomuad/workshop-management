# Workshop Training Management System

A full-stack training workshop management platform built with **Nuxt 4 + Vue 3 + Vuetify 4 + Supabase + Pinia**.

## Features

- **Authentication** — Email/password signup, login, and session management via Supabase Auth
- **Workshop CRUD** — Create, edit, list, and delete training workshops with organizer assignment, date ranges, conference room booking, and program linking
- **Conference Rooms** — Manage venue rooms with capacity, floor, and status tracking
- **Programs & Sessions** — Curriculum management with per-day session scheduling (Phase 2)
- **Enrollments & Attendance** — Batch enrollment, payment tracking, attendance marking (Phase 3)
- **Contacts & Companies** — CRM-style people and company management with search, tabs, and nested expandable tables
- **Role-based access** — RLS policies on all tables; admin/staff roles via `user_roles`
- **Dashboard** — Overview stats and quick access to key entities

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Frontend | Nuxt 4, Vue 3, Vuetify 4, Pinia |
| Backend | Nuxt server routes (Nitro), H3 |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth + RLS |
| Icons | Material Design Icons (MDI) |
| Styling | Vuetify 4 + `@nuxtjs/color-mode` (dark mode) |

## Architecture

- **File-based routing** — `app/pages/` maps to `/`, `/manage/*`, `/login`, etc.
- **File-based API** — `server/api/` maps to REST endpoints (`rooms.get.ts`, `rooms.post.ts`, `rooms/[id].put.ts`)
- **Admin API** uses `useAdminClient()` (service role key) to bypass RLS
- **Public API** (venues, workshops landing) returns hardcoded mock data
- **Composables** in `app/composables/` wrap API calls and expose reactive state

## Pages

| Route | Description |
|-------|-------------|
| `/` | Landing page (venue marketplace demo) |
| `/login` | Login form |
| `/signup` | Registration form |
| `/confirm` | Auth callback |
| `/about` | About page |
| `/manage` | Admin dashboard |
| `/manage/workshops` | Workshop list |
| `/manage/workshops/new` | Create workshop |
| `/manage/workshops/:id` | Edit workshop |
| `/manage/programs` | Program management (Phase 2) |
| `/manage/enrollments` | Enrollment management (Phase 3) |
| `/manage/rooms` | Conference room CRUD |
| `/manage/contacts` | Contacts & Companies (tabs) |
| `/manage/users` | User management + invite |

## Setup

### Prerequisites

- Node.js 18+
- npm

### Environment variables

Create a `.env` file (see `.env.example`):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Install & run

```bash
npm install
npm run dev
```

Open http://localhost:3000.

### Database

Migrations are in `supabase/migrations/`. Run them against your Supabase project via the dashboard SQL editor or the Supabase CLI:

```bash
npx supabase migration up
```

## Project Structure

```
app/
  components/     — Reusable Vue components
  composables/    — Nuxt composables (useAuth, useCompanies, useContacts, etc.)
  layouts/        — Page layouts (default, dashboard)
  pages/          — Route pages
server/
  api/            — API endpoints (file-based routing)
  utils/          — Server utilities (useAdminClient)
supabase/
  migrations/     — SQL migrations
types/            — TypeScript interfaces
```
