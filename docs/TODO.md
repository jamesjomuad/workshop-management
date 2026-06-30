# Project TODO

## Legend

- **Status:** ✅ Completed | 🔄 In Progress | 📋 Backlog | ❌ Blocked
- **Priority:** P0 (Critical) | P1 (High) | P2 (Medium) | P3 (Low)

---

## Phase 2 — Curriculum (📋 Backlog)

The database schema is fully prepared (tables: `programs`, `workshop_programs`, `sessions`), and the project plan defines these as Phase 2 deliverables. The UI pages (`manage/programs.vue`) exist but use hardcoded data.

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Programs CRUD (create, edit, delete) | P1 | 📋 Backlog | DB ready; no API endpoints or composable |
| WorkshopProgram linking UI | P1 | 📋 Backlog | Wire existing `manage/workshops/new.vue` program section to live API |
| Sessions CRUD (per workshop-program) | P1 | 📋 Backlog | DB ready; no API endpoints |
| Conference room display page (`/display?room=UUID`) | P2 | 📋 Backlog | HTML mockup at `docs/ui/session-display.html` |
| Replace hardcoded data in `manage/programs.vue` with live API calls | P1 | 📋 Backlog | Currently uses local array |

## Phase 3 — Enrollment & Attendance (📋 Backlog)

Database schema is fully prepared (tables: `enrollments`, `attendance`). The `manage/enrollments.vue` page exists with hardcoded data.

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Enrollment CRUD (individual + batch) | P1 | 📋 Backlog | DB ready; no API endpoints for enrollment |
| Payment status tracking UI | P2 | 📋 Backlog | Field exists in DB (`payment_status`) |
| Attendance marking (per-session, per-trainee) | P1 | 📋 Backlog | DB ready; no API endpoints |
| Realtime attendance updates via Supabase Realtime | P2 | 📋 Backlog | Supabase Realtime is enabled in config |
| Replace hardcoded data in `manage/enrollments.vue` with live API calls | P1 | 📋 Backlog | Currently uses local array |

## Phase 4 — Reporting & Client Portal (📋 Backlog)

| Item | Priority | Status | Notes |
|------|----------|--------|-------|
| Attendance summary per workshop | P2 | 📋 Backlog | No API or UI |
| Client company portal (view sponsored trainees) | P2 | 📋 Backlog | No API or UI |
| Certificate generation (PDF via Edge Function) | P3 | 📋 Backlog | Planned in project plan |
| Admin dashboard overview stats (live) | P2 | 📋 Backlog | `/api/admin/stats` exists but `manage/index.vue` uses hardcoded data |

## Technical Debt

| Item | Priority | Status | Category | Notes |
|------|----------|--------|----------|-------|
| Replace hardcoded dashboard (`manage/index.vue`) with live API calls | P1 | 📋 Backlog | `manage/index.vue` uses local arrays, not `/api/admin/stats` | 
| Implement `updated_at` trigger on all tables | P2 | 📋 Backlog | Database | All tables have the column but no auto-update |
| Auto-generate Supabase database types | P2 | 📋 Backlog | Types | `types/database.types.ts` is a stub; enable `supabase.types` or use `supabase gen types` |
| Fix `Category` type — missing in `types/index.ts` | P2 | 📋 Backlog | Types | `useWorkshops.ts` imports `Category` from `~/types` but it's not defined |
| Rename `ConferenceRoom` type → `Venue` (or vice versa) | P2 | 📋 Backlog | Naming | Table was renamed `conference_rooms` → `venues` but TypeScript type and API routes still say `ConferenceRoom`/`rooms` |
| Wire `manage/venues/index.vue` `hasWorkshop()` to real data | P2 | 📋 Backlog | UI | Currently always returns `false` |
| Compute `dayCount` dynamically in `manage/workshops/index.vue` | P3 | 📋 Backlog | UI | Currently hardcoded to `3` |
| Remove `console.log` statements from production code | P3 | 📋 Backlog | Cleanup | `AppFooter.vue:106`, `manage/users.vue:62,66` |
| Add delete/confirm dialog to `manage/workshops/index.vue` | P2 | 📋 Backlog | UI | Venue index has delete dialog; workshops index does not |
| Implement user edit and delete in `manage/users.vue` | P2 | 📋 Backlog | UI | Buttons exist but only call `console.log` |
| Replace `manage/settings.vue` hardcoded values with real user data | P2 | 📋 Backlog | UI | Uses hardcoded "Admin User" / "admin@example.com" |
| Missing no-data/empty states on `manage/workshops/new.vue` venue dropdown | P3 | 📋 Backlog | UX | `v-autocomplete` has a `no-data` slot but it's minimal |
| Add delete functionality to `manage/workshops/[id].vue` | P2 | 📋 Backlog | UI | Can edit but not delete a workshop from edit page |

## Missing Tests (📋 Backlog)

No test framework or test files were found in the project. The following should be considered:

| Item | Priority | Notes |
|------|----------|-------|
| No test runner configured in `package.json` | P1 | No `vitest`, `jest`, or `playwright` dependency |
| No Playwright config found (only `check-login.mjs` script) | P2 | Ad-hoc script has no test assertions |
| No API endpoint tests | P1 | All 17+ API endpoints have zero coverage |
| No component tests | P2 | 14 Vue components with zero coverage |
| No E2E tests | P1 | Critical flows (login, venue CRUD, workshop CRUD) are untested |

## Improvements & Opportunities

| Item | Priority | Category | Notes |
|------|----------|----------|-------|
| Add linting (ESLint) | P2 | DX | Recommended for Nuxt projects |
| Add type checking (vue-tsc) | P2 | DX | Currently no typecheck script |
| Add pre-commit hooks (husky/lint-staged) | P3 | DX | Not configured |
| Set up CI/CD pipeline | P2 | DevOps | No `.github/` or CI config found |
| Add `.env.example` file | P1 | DX | Missing — `.env` exists but is gitignored; no template |
| Install and configure `@nuxtjs/supabase` database types | P2 | DX | Enable `supabase.types` or use Supabase CLI |
| Consider adding proper error boundaries | P2 | UX | Most errors just show snackbar messages |
| Add loading skeleton states to data tables | P3 | UX | Loading states use `:loading` prop on `v-data-table` but no skeleton UI |
| Implement role-based route protection with `admin` middleware | P1 | Security | Middleware exists but is not used on any `definePageMeta` |

## Summary

| Category | Count |
|----------|-------|
| Phase 2 items (Curriculum) | 4 |
| Phase 3 items (Enrollment & Attendance) | 5 |
| Phase 4 items (Reporting & Client Portal) | 4 |
| Technical debt items | 12 |
| Missing tests | 5 |
| Improvements & opportunities | 9 |
| **Total** | **39** |
