## Table `companies`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  |
| `contact_email` | `text` |  Nullable |
| `contact_phone` | `text` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `user_roles`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `user_id` | `uuid` |  Unique |
| `role` | `text` |  |
| `company_id` | `uuid` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |

## Table `venues`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `name` | `text` |  |
| `venue_name` | `text` |  |
| `venue_address` | `text` |  Nullable |
| `floor` | `text` |  Nullable |
| `capacity` | `int4` |  |
| `notes` | `text` |  Nullable |
| `status` | `text` |  |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `workshops`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `title` | `text` |  |
| `description` | `text` |  Nullable |
| `date_start` | `date` |  |
| `date_end` | `date` |  |
| `conference_room_id` | `uuid` |  Nullable |
| `facilitator_id` | `uuid` |  Nullable |
| `client_id` | `uuid` |  Nullable |
| `status` | `text` |  |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `programs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `title` | `text` |  |
| `description` | `text` |  Nullable |
| `created_by` | `uuid` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `workshop_programs`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_id` | `uuid` |  |
| `program_id` | `uuid` |  |
| `trainer_id` | `uuid` |  Nullable |
| `notes` | `text` |  Nullable |

## Table `sessions`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_program_id` | `uuid` |  |
| `title` | `text` |  |
| `day_number` | `int4` |  |
| `time_start` | `time` |  |
| `time_end` | `time` |  |
| `status` | `text` |  |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

## Table `enrollments`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `workshop_id` | `uuid` |  |
| `trainee_id` | `uuid` |  |
| `enrolled_by` | `text` |  |
| `payment_status` | `text` |  |
| `created_at` | `timestamptz` |  Nullable |

## Table `attendance`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `session_id` | `uuid` |  |
| `enrollment_id` | `uuid` |  |
| `status` | `text` |  |
| `marked_at` | `timestamptz` |  Nullable |
| `marked_by` | `uuid` |  Nullable |

## Table `contacts`

### Columns

| Name | Type | Constraints |
|------|------|-------------|
| `id` | `uuid` | Primary |
| `company_id` | `uuid` |  |
| `first_name` | `text` |  |
| `last_name` | `text` |  |
| `email` | `text` |  Nullable |
| `phone` | `text` |  Nullable |
| `position` | `text` |  Nullable |
| `notes` | `text` |  Nullable |
| `created_at` | `timestamptz` |  Nullable |
| `updated_at` | `timestamptz` |  Nullable |

