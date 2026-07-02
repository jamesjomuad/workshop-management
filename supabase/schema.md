# Database Schema

Migrations:
- `supabase/migrations/00000000000000_setup.sql` — types, `companies`, `user_roles`, helper function
- `supabase/migrations/00000000000001_venues.sql`
- `supabase/migrations/00000000000002_contacts.sql`
- `supabase/migrations/00000000000003_workshops.sql`
- `supabase/migrations/00000000000004_workshop_schedules.sql`
- `supabase/migrations/00000000000005_programs.sql`
- `supabase/migrations/00000000000006_program_topics.sql`
- `supabase/migrations/00000000000007_workshop_programs.sql`
- `supabase/migrations/00000000000008_enrollments.sql`
- `supabase/migrations/00000000000009_attendance.sql`
Table seed data is included in the respective table migrations; curriculum seed data is in `supabase/seed.sql`.

## Table `companies`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` | Not null |
| `slug` | `text` | Unique, nullable |
| `logo_url` | `text` | Nullable |
| `status` | `company_status` | Default `active` |
| `contact_email` | `text` | Nullable |
| `contact_phone` | `text` | Nullable |
| `website` | `text` | Nullable |
| `address` | `text` | Nullable |
| `city` | `text` | Nullable |
| `state` | `text` | Nullable |
| `country` | `text` | Nullable |
| `postal_code` | `text` | Nullable |
| `industry` | `text` | Nullable |
| `size` | `company_size` | Nullable |
| `registration_number` | `text` | Nullable |
| `tax_number` | `text` | Nullable |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |

## Table `user_roles`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` | Unique, references `auth.users(id)` on delete cascade |
| `role` | `text` | Check: `admin`, `staff`, `trainer`, `facilitator`, `trainee`, `client`, `organizer` |
| `company_id` | `uuid` | Nullable, references `companies(id)` |
| `created_at` | `timestamptz` | Default `now()` |

## Table `venues`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` | Not null |
| `type` | `text` | Not null, default `other`, check: `hotel`, `convention_center`, `office`, `other` |
| `address` | `text` | Nullable |
| `city` | `text` | Nullable |
| `province` | `text` | Nullable |
| `country` | `text` | Default `Philippines` |
| `postal_code` | `text` | Nullable |
| `latitude` | `double precision` | Nullable |
| `longitude` | `double precision` | Nullable |
| `contact_person` | `text` | Nullable |
| `contact_phone` | `text` | Nullable |
| `contact_email` | `text` | Nullable |
| `logo_url` | `text` | Nullable |
| `cover_image_url` | `text` | Nullable |
| `notes` | `text` | Nullable |
| `is_active` | `boolean` | Not null, default `true` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |

## Table `contacts`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `company_id` | `uuid` | Nullable, references `companies(id)` on delete cascade |
| `first_name` | `text` | Not null |
| `last_name` | `text` | Not null |
| `email` | `text` | Nullable |
| `phone` | `text` | Nullable |
| `position` | `text` | Nullable |
| `notes` | `text` | Nullable |
| `deleted_at` | `timestamptz` | Nullable |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |

## Table `workshops`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `title` | `text` | Not null |
| `description` | `text` | Nullable |
| `date_start` | `date` | Not null |
| `date_end` | `date` | Not null |
| `conference_room_id` | `uuid` | Nullable, references `venues(id)` |
| `facilitator_id` | `uuid` | Nullable, references `user_roles(id)` |
| `client_id` | `uuid` | Nullable, references `companies(id)` |
| `status` | `text` | Not null, default `draft`, check: `draft`, `published`, `ongoing`, `completed`, `cancelled` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |

## Table `workshop_schedules`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_id` | `uuid` | Not null, references `workshops(id)` on delete cascade |
| `date_start` | `date` | Not null |
| `date_end` | `date` | Not null |
| `time_start` | `time` | Nullable |
| `time_end` | `time` | Nullable |
| `created_at` | `timestamptz` | Default `now()` |

## Table `programs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `title` | `text` | Not null |
| `description` | `text` | Nullable |
| `content` | `jsonb` | Nullable |
| `slug` | `text` | Unique where not null |
| `order_index` | `integer` | Not null, default `0` |
| `status` | `text` | Not null, default `upcoming`, check: `upcoming`, `ongoing`, `completed` |
| `created_by` | `uuid` | Nullable, references `user_roles(id)` |
| `created_at` | `timestamptz` | Default `now()` |
| `updated_at` | `timestamptz` | Default `now()` |
| `deleted_at` | `timestamptz` | Nullable |

## Table `program_topics`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `program_id` | `uuid` | Not null, references `programs(id)` on delete cascade |
| `title` | `text` | Not null |
| `content` | `jsonb` | Nullable |
| `status` | `text` | Not null, default `upcoming`, check: `upcoming`, `ongoing`, `completed` |
| `sort_order` | `integer` | Not null, default `0` |
| `created_at` | `timestamptz` | Default `now()` |

## Table `workshop_programs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_id` | `uuid` | Not null, references `workshops(id)` on delete cascade |
| `program_id` | `uuid` | Not null, references `programs(id)` on delete cascade |
| `trainer_id` | `uuid` | Nullable, references `user_roles(id)` |
| `notes` | `text` | Nullable |
| | | Unique `(workshop_id, program_id)` |

## Table `enrollments`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_id` | `uuid` | Not null, references `workshops(id)` on delete cascade |
| `trainee_id` | `uuid` | Not null, references `user_roles(id)` on delete cascade |
| `enrolled_by` | `text` | Not null, check: `self`, `company` |
| `payment_status` | `text` | Not null, default `pending`, check: `paid`, `pending`, `waived` |
| `created_at` | `timestamptz` | Default `now()` |
| | | Unique `(workshop_id, trainee_id)` |

## Table `attendance`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `session_id` | `uuid` | Not null |
| `enrollment_id` | `uuid` | Not null, references `enrollments(id)` on delete cascade |
| `status` | `text` | Not null, check: `present`, `absent`, `late` |
| `marked_at` | `timestamptz` | Default `now()` |
| `marked_by` | `uuid` | Nullable, references `user_roles(id)` |
| | | Unique `(session_id, enrollment_id)` |

> **Note:** `attendance.session_id` is intentionally not a foreign key. The legacy `sessions` table was removed; session semantics will be defined when attendance tracking is implemented in Phase 3.
