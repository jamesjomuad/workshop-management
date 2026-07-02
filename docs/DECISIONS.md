# Architectural Decisions

This file records inferred and explicit architectural decisions made in this project. Entries marked "Assumed" are deduced from code patterns rather than documented elsewhere.

---

## AD-1: Workshop-Centered Data Model

**Date:** 2026-06-27 (original migration timestamp)  
**Status:** Confirmed  
**Source:** `docs/plans/training-management-system-plan.md`, `supabase/migrations/0000000000000*.sql`

The Workshop is the central entity. Everything (programs, sessions, enrollments, attendance) hangs off the workshop. Conference rooms are optional details attached to workshops, not the other way around.

**Rationale:** Workshops can be created before a venue is confirmed. The room is just one attribute of the event.

---

## AD-2: Supabase RLS as Primary Authorization Layer

**Date:** 2026-06-27 (original migration timestamp)  
**Status:** Confirmed  
**Source:** All RLS policies in `supabase/migrations/0000000000000*.sql`

Authorization is enforced at the database level via Row-Level Security policies on all 11 tables. The `get_user_role()` helper function reads from `user_roles` to determine permissions per operation.

**Rationale:** Keeps authorization logic close to the data, avoids scattering role checks across API handlers, and provides defense in depth even if an API handler is misconfigured.

---

## AD-3: Service Role Key for Admin API (Bypass RLS)

**Date:** 2026-06-27 (migration timestamp)  
**Status:** Confirmed  
**Source:** `server/utils/supabase.ts`, all `server/api/admin/*` files

Admin server endpoints use `useAdminClient()`, which authenticates with the `SUPABASE_SERVICE_ROLE_KEY`. This bypasses RLS entirely. Auth endpoints (`/api/users`, `/api/invite`) do the same with a direct `createClient` call.

**Rationale:** The server is a trusted environment. The service role key is never exposed to the client (`.env` is gitignored). This avoids complex RLS policies for admin operations and keeps admin API code simple.

---

## AD-4: Two Separate Domains in One Codebase

**Date:** 2026-06-27 (project inception)  
**Status:** Confirmed  
**Source:** `server/api/venues.get.ts` vs `server/api/admin/rooms.get.ts`, landing page vs admin pages

The project contains two conceptually different applications:
1. A public venue marketplace (landing page, mock data)
2. An admin training management system (authenticated, real Supabase data)

**Rationale:** The landing page serves as a demo/pitch for the broader platform concept. The mock data in `venues.get.ts` has different fields and semantics than the real `venues` table used by admin.

---

## AD-5: Manual TypeScript Types

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** `nuxt.config.ts` (`supabase.types: false`), `types/index.ts`, `types/database.types.ts`

TypeScript interfaces are hand-written in `types/index.ts` (18 types). The `supabase.types` option is disabled, and `types/database.types.ts` is a stub with empty `Tables`, `Views`, and `Enums` objects.

**Rationale:** Avoids auto-generation complexity. Manual types give full control over shape and naming. Trade-off: types can drift from actual database schema.

---

## AD-6: Composable-Based State Management (Not Pinia)

**Date:** 2026-06-27  
**Status:** Assumed  
**Source:** All `app/composables/*.ts` files, no explicit Pinia store files found

Pinia is installed via `@pinia/nuxt` but no store definitions exist. All state management is done through Nuxt 4 composables using `useFetch` and local `ref()`/`reactive()` state.

**Rationale:** Simpler mental model for this project's scope. Composables are tree-shakeable and don't require store registration. Pinia is available for future use if cross-component state sharing becomes more complex.

---

## AD-7: Conference Rooms Renamed to Venues

**Date:** 2026-06-28 (original migration timestamp)  
**Status:** Confirmed  
**Source:** `supabase/migrations/00000000000001_venues.sql`

The table was originally named `conference_rooms`; the final schema names it `venues`. The TypeScript type keeps `ConferenceRoom` as an alias of `Venue` and the API route prefix remains `/api/admin/rooms`.

**Rationale:** Likely a mid-development rename. The codebase has not been fully updated to reflect the new naming — types and routes retain the old `ConferenceRoom`/`rooms` naming.

---

## AD-8: Nuxt 4 (Not Nuxt 3)

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** `package.json` (`nuxt: ^4.4.8`, `vue-router: ^5.1.0`)

Uses Nuxt 4 with Vue Router 5, indicating this project started after Nuxt 4's release.

---

## AD-9: No Database Trigger for `updated_at`

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** All migration files

No `updated_at` trigger is defined on any table. Tables have `updated_at TIMESTAMPTZ DEFAULT NOW()` columns but no automatic update mechanism.

**Rationale:** Assumed to be intentional for simplicity. `updated_at` must be manually set in application code. This means `updated_at` values are only accurate when first created, not on subsequent updates.

---

## AD-10: Single Training Company (No Multi-Tenancy)

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** `docs/plans/training-management-system-plan.md`

The system is designed for a single training company. There's no tenant isolation (e.g., no `tenant_id` column on tables).

**Rationale:** Simplifies the data model and RLS policies. Multi-tenancy can be added later if needed.

---

## AD-11: File-based API Shared with Frontend Type Imports

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** All `server/api/*.ts` files import from `~/types`

Server API handlers use the same `~/types` alias as the frontend, importing TypeScript interfaces from `types/index.ts`. This is a Nuxt convention enabled by the `~` alias mapping to `app/`.

**Rationale:** Shared types ensure consistency between frontend data expectations and server response shapes.

---

## AD-12: Hardcoded Demo Data for Dashboard Pages

**Date:** 2026-06-27  
**Status:** Assumed  
**Source:** `manage/index.vue`, `manage/programs.vue`, `manage/enrollments.vue`

Three admin pages use entirely hardcoded local data arrays rather than calling API endpoints. These pages have fully functional UIs but no backend integration.

**Rationale:** Likely built as UI prototypes ahead of backend implementation (Phases 2-3). The data represents realistic training scenarios with Filipino names (Ana Mercado, Ben Ramos, etc.) suggesting a Philippines-based training context.

---

## AD-13: `cookie` Package Vite Alias Workaround

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** `nuxt.config.ts` (`'cookie': 'cookie/dist/index.js'`)

A Vite resolve alias maps `cookie` to `cookie/dist/index.js` to fix a known module resolution issue with the `cookie` package in Nuxt/Vite.

---

## AD-14: `app/types/` Directory is Empty

**Date:** 2026-06-27  
**Status:** Confirmed  
**Source:** File system — `app/types/` contains 0 files

There is an `app/types/` directory that is empty. All types live at the root `types/` directory.

**Rationale:** Likely created as a Nuxt convention but not populated. The root `types/` directory is the active types location.
