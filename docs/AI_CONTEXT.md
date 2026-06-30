# AI Context — Workshop Training Management System

This file is the primary reference for AI agents working on this project. It condenses architecture, conventions, quirks, and state into a single source of truth.

---

## Project Identity

Full-stack training workshop management platform for a single training company. Manages multi-day workshops at hotel venues. Built with **Nuxt 4 + Vue 3 + Vuetify 4 + Supabase + Pinia**.

## Quick Start

```bash
npm install    # also runs `nuxt prepare` via postinstall
npm run dev    # local at http://localhost:3000
npm run build  # verify compilation (no lint/typecheck/test scripts)
```

### Required env vars (`.env`, gitignored — no `.env.example` exists)

```
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

---

## Codebase Map

```
workshop/
├── app/                          # Frontend (Vue 3 + Nuxt 4)
│   ├── app.vue                   # Root: <NuxtLayout><NuxtPage/>
│   ├── components/               # 14 reusable components
│   ├── composables/              # 9 composables (useAuth, useAdmin*, etc.)
│   ├── layouts/                  # default.vue (public), dashboard.vue (admin)
│   ├── middleware/               # auth.ts, admin.ts
│   ├── pages/                    # File-based routing
│   │   ├── index.vue, login.vue, signup.vue, confirm.vue, about.vue
│   │   └── manage/               # Auth-protected admin pages
│   │       ├── index.vue         # Dashboard (HARDCODED data)
│   │       ├── venues/           # List + new + edit (live Supabase)
│   │       ├── workshops/        # List + new + edit (live Supabase)
│   │       ├── contacts.vue      # Contacts + Companies (live Supabase)
│   │       ├── programs.vue      # HARDCODED demo data
│   │       ├── enrollments.vue   # HARDCODED demo data
│   │       ├── users.vue         # User list (live Supabase Auth)
│   │       └── settings.vue      # HARDCODED form
│   └── types/                    # Empty directory
├── server/                       # Backend (Nitro)
│   ├── api/                      # File-based REST endpoints
│   │   ├── venues.get.ts         # MOCK data (venue marketplace)
│   │   ├── workshops.get.ts      # MOCK data (workshop marketplace)
│   │   ├── stats.get.ts          # MOCK data (dashboard stats)
│   │   ├── users.get.ts          # Supabase Auth admin list
│   │   ├── invite.post.ts        # Supabase Auth invite
│   │   └── admin/                # Live Supabase (service role key)
│   │       ├── rooms/            # Venues CRUD (GET/POST/[id].PUT/[id].DELETE)
│   │       ├── workshops/        # Workshops CRUD (GET/POST/[id].PUT/[id].DELETE)
│   │       ├── companies/        # Companies CRUD (GET/POST/[id].PUT/[id].DELETE)
│   │       ├── contacts/         # Contacts CRUD (GET/POST/[id].PUT/[id].DELETE)
│   │       └── stats.get.ts      # Aggregate counts from DB
│   └── utils/supabase.ts         # useAdminClient() — service role client
├── supabase/
│   ├── config.toml               # Local dev config
│   └── migrations/               # 4 SQL migrations
├── types/
│   ├── index.ts                  # 18 hand-written TypeScript interfaces
│   └── database.types.ts         # STUB — not auto-generated
├── docs/
│   ├── plans/training-management-system-plan.md
│   └── ui/                       # HTML mockups (3 files)
├── AGENTS.md                     # Agent instructions
├── ARCHITECTURE.md               # Full architecture doc
├── DECISIONS.md                  # Architectural decisions
└── TODO.md                       # Unfinished items & tech debt
```

---

## Routes & Middleware

| Route | Layout | Middleware | Notes |
|-------|--------|-----------|-------|
| `/`, `/login`, `/signup`, `/confirm`, `/about` | `default` | none | Public |
| `/manage/*` | `dashboard` | `auth` | Auth required |
| *(future admin-only pages)* | `dashboard` | `admin` | Checks `user_roles` table |

**Every page must declare** `definePageMeta({ layout: '...', middleware: '...' })`.

**`auth.ts` middleware:** Redirects to `/login` if `useSupabaseUser()` is null.
**`admin.ts` middleware:** Also checks `user_roles.role` for `admin`/`staff`; redirects to `/manage` if unauthorized.

---

## Data Source Rules

| Endpoint / Pattern | Data Source | Key Used |
|---|---|---|
| `/api/venues`, `/api/workshops`, `/api/stats` | Hardcoded JS objects | None (public) |
| `/api/admin/*` | Live Supabase via `useAdminClient()` | `SUPABASE_SERVICE_ROLE_KEY` |
| `/api/users`, `/api/invite` | Supabase Auth Admin API via `createClient()` | `SUPABASE_SERVICE_ROLE_KEY` |
| `manage/index.vue`, `programs.vue`, `enrollments.vue` | Local hardcoded arrays | None |

**The landing page (`/api/venues`, `/api/workshops`) serves DIFFERENT data from the admin system** — it's a venue marketplace concept, not the same workshops. Do not confuse the two.

---

## API Conventions

```typescript
// File-based routing: rooms.get.ts → GET /api/admin/rooms
export default defineEventHandler(async (event): Promise<Type> => {
  const supabase = useAdminClient()
  const body = await readBody(event)
  const id = getRouterParam(event, 'id')
  // ... supabase query ...
  if (error) throw createError({ statusCode: 500, message: error.message })
  return data
})
```

- All admin endpoints use `useAdminClient()` (service role, bypasses RLS)
- Auth endpoints (`/api/users`, `/api/invite`) use direct `createClient` with same service key
- Error pattern: always `throw createError({ statusCode: 500, message })`
- All endpoints import types from `~/types`

---

## Composables Pattern

All in `app/composables/`. Return reactive refs + action functions:

```typescript
// Example: useAdminWorkshops.ts
export function useAdminWorkshops() {
  const { data: workshops, pending, refresh } = useFetch<WorkshopWithRelations[]>('/api/admin/workshops')
  async function createWorkshop(payload: Partial<Workshop>) { ... }
  async function updateWorkshop(id: string, payload: Partial<Workshop>) { ... }
  async function deleteWorkshop(id: string) { ... }
  return { workshops, venues, companies, pending, error, refresh, createWorkshop, updateWorkshop, deleteWorkshop }
}
```

Existing composables: `useAuth`, `useVenues`, `useWorkshops`, `useAdmin`, `useAdminWorkshops`, `useCompanies`, `useContacts`, `useUsers`, `useStats`.

---

## Database (10 tables)

### Entity Relationship

```
auth.users → user_roles → companies
                              │
user_roles ──► workshops ──► venues
              │       │
              │       └──► enrollments ──► attendance
              │
              └──► workshop_programs ──► sessions
                         │
                    programs
              
companies ──► contacts
```

### Key points

- `venues` was originally named `conference_rooms` — renamed via migration `20260628000002` but TypeScript type is still `ConferenceRoom` and API routes still say `/rooms`
- All 10 tables have RLS enabled with `get_user_role()` helper
- No `updated_at` trigger — column exists but must be set manually in code
- Indexes on all FK columns and frequently queried fields (15 total)
- Single company (no multi-tenancy)

### RLS Summary

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `companies` | all auth | admin/staff | admin/staff | admin |
| `user_roles` | own or admin | admin | admin | admin |
| `venues` | all auth | admin/staff | admin/staff | admin |
| `workshops` | all auth | admin/staff | admin/staff | admin |
| `programs` | all auth | admin/staff/trainer | admin/staff/trainer | admin |
| `workshop_programs` | all auth | admin/staff | admin/staff | admin |
| `sessions` | all auth | admin/staff/trainer | admin/staff/trainer | admin |
| `enrollments` | own or admin/staff/facilitator | admin/staff | admin/staff | admin |
| `attendance` | own or admin/staff/trainer/facilitator | trainer/facilitator/admin/staff | trainer/facilitator/admin/staff | admin |
| `contacts` | all auth | admin/staff | admin/staff | admin |

---

## Vuetify Conventions

- **Theme colors:** amber primary (`#F59E0B`), teal secondary (`#0D9488`), navy (`#1B2A4A`), charcoal (`#2D3436`)
- **Dark mode** via `@nuxtjs/color-mode` — `.dark` class on `<html>`
- Use `rgb(var(--v-theme-*))` for custom colors
- Use Vuetify 4 components: `v-app`, `v-card`, `v-data-table`, `v-navigation-drawer`, etc.
- No other CSS framework

---

## Notable Quirks & Gotchas

1. **Two separate domains** — Landing page mock data (`venues.get.ts`, `workshops.get.ts`) is unrelated to admin system data. The `Venue` type (landing) has different fields than `ConferenceRoom` (admin).

2. **Undeclared type** — `useWorkshops.ts` imports `Category` from `~/types` but it's **not defined** in `types/index.ts`. It's inferred from the mock API response shape.

3. **`cookie` alias** — `nuxt.config.ts` has `'cookie': 'cookie/dist/index.js'` — a Vite workaround for the `cookie` package.

4. **Stub database types** — `types/database.types.ts` has empty `Tables`/`Views`/`Enums`. Not auto-generated.

5. **`manage/venues/[id].vue`** loads ALL venues then finds by ID client-side instead of a dedicated `GET /api/admin/rooms/:id` endpoint.

6. **`manage/workshops/[id].vue`** doesn't populate form from existing data on load — `watch(workshop, ..., { immediate: true })` handles this.

7. **Hardcoded dashboard** — `manage/index.vue` uses local arrays. `/api/admin/stats` exists but is unused by the dashboard.

8. **No `updated_at` updates** — Columns exist on all tables with `DEFAULT NOW()` but are never updated.

---

## Security Notes

- `SUPABASE_SERVICE_ROLE_KEY` is used server-side only (`server/utils/supabase.ts`) — never exposed to client
- RLS is the primary authorization mechanism, not middleware
- `admin.ts` middleware is defined but **not referenced** by any page's `definePageMeta` — currently unused
- No CSRF, rate limiting, or input sanitization beyond Supabase client's built-in parameterization
- `/api/users` and `/api/invite` use service role key with no additional auth check on the endpoint itself

---

## Build Phase Status

| Phase | Status | Deliverables |
|-------|--------|-------------|
| 1 — Foundation | ✅ **Done** | Auth, DB (10 tables), venues CRUD, workshops CRUD, dashboard overview, contacts/companies CRUD, user management, RLS policies |
| 2 — Curriculum | ❌ **Planned** | Programs CRUD, WorkshopProgram linking, sessions CRUD, room display page |
| 3 — Enrollment & Attendance | ❌ **Planned** | Batch enrollment, payment tracking, attendance marking, realtime |
| 4 — Reporting | ❌ **Planned** | Certificates, client portal, reports |

---

## Tech Debt Quick Reference

- No test framework, no linting, no typechecking, no CI/CD
- `manage/programs.vue` and `manage/enrollments.vue` are UI shells (hardcoded data)
- 3 `console.log` statements in production code (`AppFooter.vue:106`, `manage/users.vue:62,66`)
- No `.env.example` file
- `manage/venues/index.vue` `hasWorkshop()` always returns `false`
- `manage/workshops/index.vue` `dayCount` hardcoded to `3`
- `manage/settings.vue` uses hardcoded "Admin User" / "admin@example.com"
- `manage/users.vue` edit/delete buttons only call `console.log`
- Chart.js + vue-chartjs installed but unused
