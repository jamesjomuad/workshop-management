# Workshop Training Management System

## Quick start

```bash
npm install
npm run dev         # http://localhost:3000
```

No lint, typecheck, or test scripts exist in `package.json`. Run `npm run build` to verify compilation.

## Architecture

**Nuxt 4 + Vue 3 + Vuetify 4 + Supabase + Pinia.** File-based routing (`app/pages/`), file-based server API (`server/api/`), Supabase Auth + PostgreSQL with RLS.

### Pages & routing

| Route | Layout | Middleware | Notes |
|-------|--------|--------|-------|
| `/`, `/login`, `/signup`, `/confirm`, `/about` | `default` | none | Public |
| `/manage/*` | `dashboard` | `auth` | Auth required |
| *(future admin-only)* | `dashboard` | `admin` | Checks role in `user_roles` table |

Every page **must** declare `definePageMeta({ layout: ..., middleware: ... })`.

### Data sources

- **Mock (hardcoded):** `/api/venues`, `/api/workshops`, `/api/stats` return static JS objects
- **Live Supabase:** `/api/admin/*` queries real tables via `useAdminClient()` (service role key, bypasses RLS)
- **Supabase Admin Auth API:** `/api/users` (list users), `/api/invite` (invite by email)
- **Hardcoded demo data in pages:** `manage/index.vue`, `manage/programs.vue`, `manage/enrollments.vue` use local arrays, not server endpoints

### Server API conventions

```typescript
// File-based: rooms.get.ts, rooms.post.ts, rooms/[id].put.ts, rooms/[id].delete.ts
export default defineEventHandler(async (event): Promise<Type> => {
  const supabase = useAdminClient()  // or direct createClient for auth.admin ops
  const body = await readBody(event)
  const id = getRouterParam(event, 'id')
  // ... supabase query, return data or throw createError({ statusCode: 500, message })
})
```

Admin endpoints use `useAdminClient()` (`server/utils/supabase.ts`) which uses `SUPABASE_SERVICE_ROLE_KEY`. Auth admin endpoints (`/api/users`, `/api/invite`) use direct `createClient` with the same service key.

### Composables

Public: `useAuth`, `useVenues`, `useWorkshops`
Admin: `useAdminWorkshops`, `useConferenceRooms`, `useUsers`, `useStats`, `useAdmin` (role checks), `useCompanies`, `useContacts`

Admin facades call `/api/admin/*` server endpoints. `useAdmin()` queries the `user_roles` table directly via anon client (client-side).

### DB schema (10 tables)

Migration: `supabase/migrations/20260627000001_training_system_core.sql`, `20260628000001_contacts.sql`, etc.

```
companies → user_roles (FK to auth.users) → venues / workshops / programs
  contacts (FK to companies)
  workshops → venues (nullable), facilitator_id, client_id
  workshop_programs (junction: workshop_id + program_id, unique) → sessions (per day)
  enrollments (workshop_id + trainee_id, unique) → attendance (per session, per enrollment)
```

RLS enabled on all tables with a `get_user_role()` helper function. Service role bypasses RLS in admin API routes.

### Types

Manual interfaces in `types/index.ts` (18 types). Not auto-generated — `supabase.types: false` in config. `types/database.types.ts` is a stub. Type aliases: `~`/`@` → `app/`.

### Vuetify conventions

- Theme: amber primary (`#F59E0B`), teal secondary (`#0D9488`), navy (`#1B2A4A`), charcoal (`#2D3436`)
- Dark mode via `@nuxtjs/color-mode` (`.dark` class on `<html>`)
- CSS custom properties: `rgb(var(--v-theme-*))`
- Use Vuetify 4 components: `v-app`, `v-navigation-drawer`, `v-card`, `v-data-table`, etc.

### Required env vars (`.env`, gitignored)

- `SUPABASE_URL` — project URL
- `SUPABASE_KEY` — anon/publishable key (client-side)
- `SUPABASE_SERVICE_ROLE_KEY` — service role key (server-side only)

### Notable quirks

- No `updated_at` trigger on any table — must be set manually in code if needed
- Demo landing page (`/api/venues`, `/api/workshops`) serves **different data** than the admin system — it's a venue marketplace concept, not the same workshops
- The `useWorkshops.ts` composable references a `Category` type that is **not defined** in `types/index.ts` — it's inferred from the mock API response
- `cookie` vite alias in `nuxt.config.ts`: `'cookie': 'cookie/dist/index.js'`
- `postinstall` hook runs `nuxt prepare` (generates `.nuxt/`)
- Table was renamed `conference_rooms` → `venues` via migration `20260628000002`
- The `Contact` type in `types/index.ts` has `company_name` as optional but the server API maps it from a join — `companies` is not in the base `ConferenceRoom` type despite being used in queries
- `manage/index.vue`, `manage/programs.vue`, `manage/enrollments.vue` use entirely hardcoded local data arrays — no API calls

### Build phases (from project plan)

| Phase | Status | Key deliverables |
|-------|--------|----------------|
| 1 — Foundation | ✅ Done | Auth, DB, rooms CRUD, workshops CRUD, dashboard overview, contacts/companies CRUD |
| 2 — Curriculum | ❌ Planned | Programs CRUD, WorkshopProgram linking, sessions CRUD, room display page |
| 3 — Enrollment & Attendance | ❌ Planned | Batch enrollment, payment tracking, attendance marking, realtime |
| 4 — Reporting | ❌ Planned | Certificates, client portal, reports |

HTML/CSS mockups for future features in `docs/ui/`.

### Coding standards

- Use `definePageMeta` on every page with explicit `layout` and `middleware`
- API handlers return typed responses with `defineEventHandler`
- Admin API endpoints use `useAdminClient()` from `server/utils/supabase.ts`
- Composables return reactive state and action functions
- Use `useFetch` for API calls with typed generics
- Use `reactive()` for form state, `ref()` for primitive values
- No CSS framework other than Vuetify 4 — use Vuetify components and utility classes
- Type imports via `~/types` alias
- All UI text in English (no i18n setup)


### Knowledge Base

The following documents define the full system context:

- Architecture → ./docs/ARCHITECTURE.md
- API Specification → ./docs/API_SPEC.md
- Code Guidelines → ./docs/CODE_GUIDELINES.md
- Codebase Summary → ./docs/CODEBASE_SUMMARY.md
- AI Context → ./docs/AI_CONTEXT.md