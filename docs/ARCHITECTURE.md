# Workshop Training Management System — Architecture

## High-level Overview

A full-stack web application for a training company to manage multi-day workshops held at hotel venues. The system combines a public venue marketplace landing page with a private admin dashboard for managing workshops, venues, programs, enrollments, contacts, and users.

The project has **two distinct functional domains** sharing the same codebase:

1. **Public venue marketplace** — Landing page (`/`) displaying mock venue listings, event types, and testimonials. Serves demonstration/pitch content.
2. **Admin training management** — Authenticated dashboard (`/manage/*`) for CRUD operations on workshops, venues (conference rooms), programs, enrollments, contacts, companies, and users.

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend Framework | Nuxt 4 + Vue 3 | SSR/SPA hybrid, file-based routing |
| UI Library | Vuetify 4 | Material Design components |
| State Management | Pinia (via `@pinia/nuxt`) | Global state (auto-setup) |
| Backend | Nitro (Nuxt server) | File-based API endpoints |
| Database | PostgreSQL (Supabase) | All persistent data |
| Auth | Supabase Auth | Email/password, session management |
| Authorization | Supabase RLS | Row-level security policies |
| Dark Mode | `@nuxtjs/color-mode` | CSS class toggle on `<html>` |
| Charts | Chart.js + vue-chartjs | Dashboard visualizations (imported but unused in code) |

## Directory Structure

```
workshop/
├── app/                          # Nuxt application (frontend)
│   ├── app.vue                   # Root component (<NuxtLayout> + <NuxtPage>)
│   ├── components/               # Reusable Vue components (14 files)
│   ├── composables/              # Shared reactive logic (9 files)
│   ├── layouts/                  # Page layouts
│   │   ├── default.vue           # Public pages (header + footer)
│   │   └── dashboard.vue         # Admin pages (sidebar + app bar)
│   ├── middleware/                # Route guards
│   │   ├── auth.ts               # Redirects to /login if unauthenticated
│   │   └── admin.ts              # Checks for admin/staff role
│   ├── pages/                    # File-based routing
│   │   ├── index.vue             # Landing page (venue marketplace)
│   │   ├── login.vue             # Sign-in form
│   │   ├── signup.vue            # Registration form
│   │   ├── confirm.vue           # Post-confirmation password set
│   │   ├── about.vue             # Placeholder about page
│   │   └── manage/               # Admin routes (auth-protected)
│   │       ├── index.vue         # Dashboard overview
│   │       ├── venues/           # Venue CRUD (list, new, edit)
│   │       ├── workshops/        # Workshop CRUD (list, new, edit)
│   │       ├── contacts.vue      # Contacts & Companies (tabs)
│   │       ├── programs.vue      # Programs & Sessions (hardcoded demo)
│   │       ├── enrollments.vue   # Enrollments & Attendance (hardcoded demo)
│   │       ├── users.vue         # User list
│   │       └── settings.vue      # Profile & app settings (hardcoded form)
│   └── types/                    # App-specific types (empty directory)
├── server/                       # Nitro server (backend)
│   ├── api/                      # File-based API endpoints
│   │   ├── venues.get.ts         # Mock venue marketplace data
│   │   ├── workshops.get.ts      # Mock workshop marketplace data
│   │   ├── stats.get.ts          # Mock admin stats
│   │   ├── users.get.ts          # List Supabase auth users
│   │   ├── invite.post.ts        # Invite user via email
│   │   └── admin/                # Live Supabase admin endpoints
│   │       ├── rooms.get/post/   # Venue CRUD
│   │       ├── rooms/[id].put/delete/
│   │       ├── workshops.get/post/
│   │       ├── workshops/[id].put/delete/
│   │       ├── companies.get/post/
│   │       ├── companies/[id].put/delete/
│   │       ├── contacts.get/post/
│   │       ├── contacts/[id].put/delete/
│   │       └── stats.get.ts      # Aggregate counts from DB
│   └── utils/
│       └── supabase.ts           # useAdminClient() helper
├── supabase/                     # Supabase configuration
│   ├── config.toml               # Local dev config (ports, auth, storage)
│   └── migrations/               # SQL migrations (4 files)
├── types/                        # TypeScript type definitions
│   ├── index.ts                  # 18 manual interfaces
│   └── database.types.ts         # Stub — not auto-generated
├── docs/
│   ├── plans/                    # Project plan document
│   └── ui/                       # HTML/CSS mockups (3 files)
├── public/
│   ├── favicon.ico
│   └── robots.txt
└── nuxt.config.ts                # Nuxt configuration
```

## Backend Architecture (Nitro Server)

### Pattern: File-based API Routing

Each HTTP method + path combination is a single file:
- `server/api/rooms.get.ts` → `GET /api/rooms`
- `server/api/rooms.post.ts` → `POST /api/rooms`
- `server/api/rooms/[id].put.ts` → `PUT /api/rooms/:id`
- `server/api/rooms/[id].delete.ts` → `DELETE /api/rooms/:id`

### Two Data Source Strategies

| Endpoint | Strategy | Key |
|----------|----------|-----|
| `/api/venues`, `/api/workshops`, `/api/stats` | Static JS data | None (public) |
| `/api/admin/*` | `useAdminClient()` → Supabase service role | `SUPABASE_SERVICE_ROLE_KEY` |
| `/api/users`, `/api/invite` | `createClient` with service role | `SUPABASE_SERVICE_ROLE_KEY` |

### API Endpoint Inventory

**Public mock endpoints:**
- `GET /api/venues` — Returns 6 venues, 6 event types, 4 testimonials (hardcoded)
- `GET /api/workshops` — Returns 6 workshops, 8 categories, 4 testimonials (hardcoded)
- `GET /api/stats` — Returns 4 dashboard stat cards (hardcoded)

**Auth admin endpoints (uses `createClient` with service role key):**
- `GET /api/users` — Lists all Supabase Auth users
- `POST /api/invite` — Sends email invitation

**Admin CRUD endpoints (uses `useAdminClient()`):**
- `GET /api/admin/rooms` — List all venues
- `POST /api/admin/rooms` — Create venue
- `PUT /api/admin/rooms/:id` — Update venue
- `DELETE /api/admin/rooms/:id` — Delete venue
- `GET /api/admin/workshops` — List workshops (with venue + client joins)
- `POST /api/admin/workshops` — Create workshop
- `PUT /api/admin/workshops/:id` — Update workshop
- `DELETE /api/admin/workshops/:id` — Delete workshop
- `GET /api/admin/companies` — List companies
- `POST /api/admin/companies` — Create company
- `PUT /api/admin/companies/:id` — Update company
- `DELETE /api/admin/companies/:id` — Delete company
- `GET /api/admin/contacts` — List contacts (with company name join)
- `POST /api/admin/contacts` — Create contact
- `PUT /api/admin/contacts/:id` — Update contact
- `DELETE /api/admin/contacts/:id` — Delete contact
- `GET /api/admin/stats` — Aggregate counts (rooms, workshops, programs, enrollments)

### Error Handling

All admin API handlers follow this pattern:
```typescript
if (error) throw createError({ statusCode: 500, message: error.message })
return data  // or { success: true }
```

## Frontend Architecture

### Nuxt Modules

| Module | Purpose |
|--------|---------|
| `vuetify-nuxt-module` | Vuetify 4 integration |
| `@pinia/nuxt` | Pinia state management |
| `@nuxtjs/color-mode` | Dark/light mode toggle |
| `@nuxtjs/supabase` | Supabase client, auth, and user composables |

### Composables Layer

All composables live in `app/composables/` and follow a consistent pattern — they return reactive refs and async action functions:

```
useAuth()          → user, loggedIn, login, signUp, logout, resetPassword, updatePassword
useVenues()        → venues, eventTypes, testimonials, filteredVenues, searchQuery, ...
useWorkshops()     → workshops, categories, testimonials, filteredWorkshops, ...
useAdmin()         → userRole, isAdmin, isStaff, isTrainer, isFacilitator, fetchRole
useAdminWorkshops() → workshops, venues, companies, createWorkshop, updateWorkshop, deleteWorkshop
useCompanies()     → companies, createCompany, updateCompany, deleteCompany
useContacts()      → contacts, createContact, updateContact, deleteContact
useUsers()         → users, activeUsers, inactiveUsers
useStats()         → stats, statList
```

### Component Tree

```
app.vue
├── default.vue layout (public)
│   ├── NuxtPage
│   │   ├── index.vue
│   │   │   ├── HeroSection
│   │   │   ├── EventTypeGrid
│   │   │   ├── VenueCard (×N)
│   │   │   ├── HowItWorks
│   │   │   ├── TestimonialCarousel
│   │   │   └── HotelCTA
│   │   │   └── AppFooter
│   │   ├── login.vue
│   │   ├── signup.vue
│   │   ├── confirm.vue
│   │   └── about.vue
│   └── public-header
│
└── dashboard.vue layout (admin)
    ├── AppHeader (app bar with theme toggle)
    ├── SidebarNav (navigation list with logout)
    ├── v-navigation-drawer
    └── NuxtPage
        ├── manage/index.vue (hardcoded dashboard)
        ├── manage/venues/* (live supabase)
        ├── manage/workshops/* (live supabase)
        ├── manage/contacts.vue (live supabase)
        ├── manage/programs.vue (hardcoded demo)
        ├── manage/enrollments.vue (hardcoded demo)
        ├── manage/users.vue (live supabase)
        └── manage/settings.vue (hardcoded form)
```

### State Management

Pinia is installed via `@pinia/nuxt` but is **not directly used** — all state management is done through Nuxt's `useFetch` composable and local `ref()`/`reactive()` state. The stores are auto-registered but empty (no explicit store definitions found).

### Routing & Middleware Flow

```
Request → NuxtPage → definePageMeta({ layout, middleware })
                          │
                    ┌─────┴─────┐
                    │            │
               auth.ts     admin.ts
                    │            │
              checks user    checks user
              via Supabase   via Supabase
                    │            │
               redirect or   checks role in
               proceed      user_roles table
                            redirect or proceed
```

## Database Design

### Entity Relationship Diagram

```
auth.users
    │ (FK: user_id)
    ▼
user_roles ──────────► companies
(id, user_id, role,     (id, name, contact_email,
 company_id FK)          contact_phone)
    │                         │
    │ (FK: facilitator_id)    │ (FK: client_id)
    │ (FK: created_by)        │
    │                         ▼
    ├─────────────────── workshops
    │                     (id, title, description,
    │                      date_start, date_end,
    │  (FK: conference     conference_room_id FK,
    │   _room_id)          facilitator_id FK,
    │         │            client_id FK, status)
    │         ▼               │
    │      venues             │ (FK: workshop_id)
    │      (id, name,         ▼
    │       venue_name,   workshop_programs
    │       capacity,     (id, workshop_id FK,
    │       status)        program_id FK, trainer_id FK)
    │      ▲                  │
    │      │                  │ (FK: workshop_program_id)
    │      │                  ▼
    │      │              sessions
    │      │              (id, title, day_number,
    │      │               time_start, time_end, status)
    │      │
    │      ├────────────────► enrollments
    │      │                 (id, workshop_id FK,
    │      │                  trainee_id FK,
    │      │                  enrolled_by, payment_status)
    │      │                        │
    │      │                        │ (FK: enrollment_id)
    │      │                        ▼
    │      │                    attendance
    │      │                    (id, session_id FK,
    │      │                     enrollment_id FK,
    │      │                     status, marked_by FK)
    │      │
    │      └────────────────► contacts
    │                        (id, company_id FK,
    │                         first_name, last_name,
    │                         email, phone, position)
    │
    └──────────────────► programs
                         (id, title, description,
                          created_by FK)
```

### Tables Summary (10 tables)

| Table | Purpose | Key FK References |
|-------|---------|-------------------|
| `user_roles` | Role assignment extending `auth.users` | `user_id → auth.users`, `company_id → companies` |
| `companies` | Client organizations | — |
| `venues` | Conference rooms at hotels | — |
| `workshops` | Central event entity | `conference_room_id → venues`, `facilitator_id → user_roles`, `client_id → companies` |
| `programs` | Reusable curriculum definitions | `created_by → user_roles` |
| `workshop_programs` | Junction: program scheduled in workshop | `workshop_id → workshops`, `program_id → programs`, `trainer_id → user_roles` |
| `sessions` | Individual day/time module within a workshop-program | `workshop_program_id → workshop_programs` |
| `enrollments` | Tracks trainee participation in a workshop | `workshop_id → workshops`, `trainee_id → user_roles` |
| `attendance` | Per-session attendance for each enrollment | `session_id → sessions`, `enrollment_id → enrollments`, `marked_by → user_roles` |
| `contacts` | People at client companies | `company_id → companies` |

### RLS Policies

All 10 tables have RLS enabled with a `get_user_role()` helper function. The policy pattern varies by sensitivity:

| Table | SELECT | INSERT | UPDATE | DELETE |
|-------|--------|--------|--------|--------|
| `companies` | All auth | admin/staff | admin/staff | admin only |
| `user_roles` | Own role or admin | admin only | admin only | admin only |
| `venues` | All auth | admin/staff | admin/staff | admin only |
| `workshops` | All auth | admin/staff | admin/staff | admin only |
| `programs` | All auth | admin/staff/trainer | admin/staff/trainer | admin only |
| `workshop_programs` | All auth | admin/staff | admin/staff | admin only |
| `sessions` | All auth | admin/staff/trainer | admin/staff/trainer | admin only |
| `enrollments` | Own or admin/staff/facilitator | admin/staff | admin/staff | admin only |
| `attendance` | Own or admin/staff/trainer/facilitator | trainer/facilitator/admin/staff | trainer/facilitator/admin/staff | admin only |
| `contacts` | All auth | admin/staff | admin/staff | admin only |

### Indexes

15 indexes created on foreign keys and frequently queried columns: `user_roles(user_id, role)`, `workshops(status, date_start, conference_room_id)`, `workshop_programs(workshop_id, program_id)`, `sessions(workshop_program_id)`, `enrollments(workshop_id, trainee_id)`, `attendance(session_id, enrollment_id)`, `contacts(company_id)`.

## Authentication and Authorization Flow

```
┌─────────────┐     ┌──────────────┐     ┌───────────────┐
│  User        │     │  Nuxt App    │     │  Supabase     │
│  (Browser)   │     │  (Nitro)     │     │  (Backend)    │
└──────┬───────┘     └──────┬───────┘     └───────┬───────┘
       │                    │                     │
       │  1. Login form     │                     │
       │───────────────────►│                     │
       │                    │  2. signInWithPass  │
       │                    │────────────────────►│
       │                    │                     │
       │                    │  3. session JWT     │
       │                    │◄────────────────────┤
       │                    │                     │
       │  4. Store session  │                     │
       │◄───────────────────┤                     │
       │                    │                     │
       │  5. Navigate to    │                     │
       │     /manage/*      │                     │
       │───────────────────►│                     │
       │                    │  6. auth middleware  │
       │                    │     checks user via  │
       │                    │     useSupabaseUser()│
       │                    │                     │
       │                    │  7. Page renders if  │
       │                    │     authenticated    │
       │◄───────────────────┤                     │
       │                    │                     │
       │  8. Page calls     │                     │
       │     /api/admin/*   │                     │
       │───────────────────►│                     │
       │                    │  9. useAdminClient() │
       │                    │     (service role)   │
       │                    │────────────────────►│
       │                    │     bypasses RLS     │
       │                    │◄────────────────────┤
       │◄───────────────────┤                     │
```

**Key points:**
- Client-side auth: `@nuxtjs/supabase` provides `useSupabaseUser()` and `useSupabaseClient()`
- Server-side admin API: `useAdminClient()` uses `SUPABASE_SERVICE_ROLE_KEY` — bypasses RLS entirely
- RLS is the **primary authorization mechanism** at the database level
- The `admin.ts` middleware does a client-side check against `user_roles` table for admin/staff role
- The `auth.ts` middleware only checks for the presence of a user session

## Security Considerations

1. **Service role key** (`SUPABASE_SERVICE_ROLE_KEY`) is used in server-only code (`server/utils/supabase.ts`). It is never exposed to the client. The `.env` file is gitignored.
2. **RLS is the authorization layer** — all tables have `ENABLE ROW LEVEL SECURITY` and granular policies for each operation and role.
3. **No input sanitization** visible in API handlers — Supabase client parameterizes queries by default, but this should be verified.
4. **No CSRF protection** framework explicitly configured — Nuxt/Nitro provide some built-in protections.
5. **Auth endpoints** (`/api/users`, `/api/invite`) create a fresh `createClient` with the service role key on each request. No auth token validation is performed on these endpoints beyond the service role key being secret.

## Data Flow Diagrams

### Admin CRUD Flow (e.g., Creating a Venue)

```
manage/venues/new.vue
       │
       │ useFetch('/api/admin/rooms', { method: 'POST', body })
       ▼
server/api/admin/rooms.post.ts
       │
       │ useAdminClient() → supabase.from('venues').insert(body)
       ▼
Supabase PostgreSQL (bypasses RLS via service role)
       │
       │ Returns new row
       ▼
Response → Client shows success snackbar → Redirects to /manage/venues
```

### Dashboard Overview Flow

```
manage/index.vue
       │
       │ Uses hardcoded local arrays (NO API calls)
       ▼
Renders statCards, todaySessions, attendanceRates, recentEnrollments
(all compiled into JS bundle at build time)
```

### Contacts Page Flow (with Company join)

```
manage/contacts.vue
       │
       │ useCompanies() → useFetch('/api/admin/companies')
       │ useContacts()  → useFetch('/api/admin/contacts')
       ▼
server/api/admin/companies.get.ts → supabase.from('companies').select('*')
server/api/admin/contacts.get.ts  → supabase.from('contacts').select('*, companies(name)')
       │
       │ contacts.get.ts maps data:
       │   c.company_name = c.companies?.name ?? null
       │   delete c.companies
       ▼
Response → Client renders two tabs with expandable company rows
```

## Deployment Requirements

### Environment Variables
- `SUPABASE_URL` — Supabase project URL
- `SUPABASE_KEY` — Anon/publishable key (client-side)
- `SUPABASE_SERVICE_ROLE_KEY` — Service role key (server-side only)

### Build
```bash
npm install      # Also runs 'nuxt prepare' via postinstall hook
npm run build    # Generates .output/ for production
npm run preview  # Preview production build locally
```

### Database
Apply migrations via Supabase CLI:
```bash
npx supabase migration up
```

Or via Supabase Dashboard SQL editor. Migrations are in `supabase/migrations/` and must be applied in order by timestamp prefix.

## Notable Assumptions

- The `about.vue` page is a placeholder with minimal content
- `chart.js` and `vue-chartjs` are installed as dependencies but not imported in any component
- Pinia is installed but no explicit stores were found — Nuxt auto-registers it
- `manage/programs.vue` and `manage/enrollments.vue` have fully functional UIs but use hardcoded data arrays, not API endpoints
- The `manage/venues/index.vue` `hasWorkshop()` function always returns `false`
- The `manage/workshops/index.vue` `dayCount` is hardcoded to `3` instead of computed from dates
- `manage/settings.vue` profile form has hardcoded values
