# Feature: Curriculum Structure (Program → Topic)

## Context
Building a Workshop Training Management System with Nuxt 3, Supabase (Postgres + RLS), 
Vuetify 3. Simplified 2-level content hierarchy:

Program
 └── Topic

- A Program contains many Topics.
- Topics cannot exist without a parent Program (no orphan topics).
- A Program can have zero Topics (Program-only content is valid).
- No Course wrapper, no Sections layer — just these two levels.

## Data Model

### Tables

**Programs**
- id (uuid, pk)
- title (text, not null)
- description (text)
- content (text/jsonb — rich text body)
- slug (text, unique)
- status (enum: draft, published, archived)
- order_index (integer, not null) -- controls top-level Program ordering
- created_by (uuid, fk -> auth.users)
- created_at, updated_at (timestamptz)

**topics**
- id (uuid, pk)
- Program_id (uuid, fk -> Programs.id, not null, on delete cascade)
- title (text, not null)
- content (text/jsonb — rich text body)
- order_index (integer, not null) -- controls position within Program
- status (enum: draft, published)
- created_at, updated_at (timestamptz)

### Constraints / Indexes
- Unique composite index on (Program_id, order_index) for topics
- Unique index on order_index for Programs (or scoped however Programs are grouped/filtered, e.g. by category)
- Cascade delete: deleting a Program deletes its topics

### RLS Policies
- Authenticated staff/admin roles: full CRUD on both tables
- Trainees: read-only access to published Programs/topics they are enrolled in / assigned
- Use existing `workshop_members` or role table to scope access (match existing project RLS pattern)

## API / Composables
- `usePrograms()` — list, get, create, update, delete, reorder Programs
- `useTopics(ProgramId)` — list topics for a Program ordered by order_index; create/update/delete/reorder

Reordering: implement `reorderPrograms(orderedIds[])` and `reorderTopics(ProgramId, orderedIds[])` 
that batch-update order_index values in a single transaction/RPC call.

## UI Components (Vuetify 3)
- `ProgramList.vue` — top-level page listing all Programs, draggable to reorder
- `ProgramItem.vue` — expandable/collapsible row showing Program title + nested Topic list
- `TopicItem.vue` — row within a Program showing topic title, drag handle, edit/delete actions
- Use vuedraggable or @vueuse/integrations useSortable for drag-and-drop reordering
- Inline "Add Topic" button per Program; "Add Program" button at top level
- Inline-editable titles; content body opens in a separate editor view/modal

## Acceptance Criteria
1. Creating a Topic requires an existing parent Program — UI must not allow topic creation without one
2. Drag-reordering Programs updates order_index for all affected rows atomically
3. Drag-reordering topics is scoped to siblings within the same Program only
4. Deleting a Program cascades and removes its Topics (with a confirmation dialog warning of cascade)
5. Program list view loads Programs + topics in a single nested query (avoid N+1 — use Supabase 
   nested select: `Programs(*, topics(*))`)
6. RLS prevents non-staff users from creating/editing either table

## Deliverables
1. SQL migration file(s) for the two tables, enums, indexes, and RLS policies
2. TypeScript types/interfaces for Program, Topic (matching DB schema)
3. Composables: usePrograms, useTopics with full CRUD + reorder methods
4. Vue components: ProgramList.vue, ProgramItem.vue, TopicItem.vue with drag-and-drop reordering
5. Seed script with 4-5 sample Programs, 2-3 topics each for local testing