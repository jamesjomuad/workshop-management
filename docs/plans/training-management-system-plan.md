# Workshop Training Management System — Project Plan

## Overview

A web-based training management system for a single training company that manages multi-day workshops held at hotel venues. Built on **Nuxt 3 + Supabase** (PostgreSQL, Auth, Storage, Realtime).

---

## Entity Hierarchy

```
Workshop  (the event — "PM Training, Jun 24–27")
  ├── Conference Room  (optional — can be assigned later)
  ├── Trainer / Facilitator
  ├── Client Company
  ├── WorkshopProgram  (junction — links programs to this workshop)
  │     └── Session  (Module 1 · Day 1 · 8:00–12:00)
  └── Enrollments
        └── Attendance  (per session)

Program  (curriculum — lives independently, reusable)
  └── WorkshopProgram  (scheduled instances of this program)
```

The **Workshop** is the central entity — the event you sell, schedule, and staff. The conference room is a detail attached to it, not the other way around.

The **`WorkshopProgram`** junction table is what makes programs reusable. A program like "PM Fundamentals" is defined once and can be linked to multiple workshops. One-off programs are simply programs with a single link.

---

## User Roles

| Role | Description |
|---|---|
| **Admin** | Full access — manages everything |
| **Staff** | Operational — schedules, enrollments, logistics |
| **Trainer** | Owns course content, marks attendance |
| **Facilitator** | On-site coordinator at the venue |
| **Trainee** | Self-enrolls or company-sponsored |
| **Client (Company)** | Sponsors employees, views team progress |

Access control enforced via Supabase Row Level Security (RLS).

---

## Core Modules

### 1. Workshops
The central event entity. Can span multiple days.

- Title, description, date range (start – end)
- Conference room assignment (optional — can be booked later)
- Assigned facilitator
- Linked to a client company (or open for self-enrollment)
- Can hold multiple programs simultaneously or sequentially
- Status: Draft → Published → Ongoing → Completed → Cancelled

### 2. Conference Rooms
Physical spaces at hotel venues (ballrooms, function rooms, boardrooms). Optional on a workshop — assigned when the venue is confirmed.

- Room name, venue name, address, floor, capacity
- Availability status: Available / Booked / In use
- One room hosts one workshop at a time

### 3. Programs
Reusable curriculum definitions that exist independently of any workshop.

- Title and description
- Can be linked to many workshops via WorkshopProgram
- One-off programs are just programs used once
- Trainer is assigned per workshop run, not per program definition

### 4. WorkshopProgram
The junction between a workshop and a program — represents one scheduled run of a curriculum.

- Links a program to a specific workshop
- Assigns the trainer for that run
- Holds the sessions for that run

### 5. Sessions
Individual modules or topics within a WorkshopProgram, tied to a specific day and time slot.

- Day number (Day 1, Day 2, etc.)
- Time start and end
- Status: Upcoming → Ongoing → Completed

### 6. Enrollments
Tracks who is attending a workshop.

- Self-enrolled (individual pays) or company-sponsored (batch)
- Payment status: Paid / Pending / Waived
- Enrollment approval workflow (optional)

### 7. Attendance
Per-session attendance records for each enrolled trainee.

- Status: Present / Absent / Late
- Marked by trainer or facilitator
- Realtime updates via Supabase Realtime

---

## Database Schema

```sql
-- Physical hotel spaces (optional on workshop)
conference_rooms
  id, name, venue_name, venue_address, floor, capacity, notes

-- The central event entity
workshops
  id, title, description
  date_start, date_end
  conference_room_id → conference_rooms  (nullable)
  facilitator_id → users
  client_id → companies
  status  -- draft | published | ongoing | completed | cancelled

-- Reusable curriculum definitions (independent of workshops)
programs
  id, title, description
  created_by → users

-- A program scheduled inside a specific workshop (junction)
workshop_programs
  id, workshop_id → workshops
  program_id → programs
  trainer_id → users  (trainer assigned per run)
  notes

-- Sessions belong to a workshop_program run
sessions
  id, workshop_program_id → workshop_programs
  title, day_number
  time_start, time_end
  status  -- upcoming | ongoing | completed

-- Workshop participants
enrollments
  id, workshop_id → workshops
  trainee_id → users
  enrolled_by  -- self | company
  payment_status  -- paid | pending | waived

-- Per-session attendance
attendance
  id, session_id → sessions
  enrollment_id → enrollments
  status  -- present | absent | late

-- Supporting tables
users, user_roles, companies
```

---

## Tech Architecture

```
Nuxt 4
├── /manage             Dashboard & admin pages
│   ├── /               Overview, users, settings
│   └── /admin/         Training management (rooms, workshops, programs)
├── /server/api         Server routes (CRUD + admin endpoints)
├── /composables        useAdminWorkshops, useConferenceRooms, useAuth
└── /middleware         auth, admin (role-based guards)

Supabase
├── Auth                Magic link + email/password
├── PostgreSQL          All data + RLS policies
├── Storage             Certificates, course materials
├── Edge Functions      Certificate PDF generation
└── Realtime            Live attendance updates
```

---

## UI Deliverables

### Admin Dashboard (`/manage/admin`)

Sidebar navigation with five sections (available from the Dashboard sidebar under "Training Mgmt"):

| Section | Description |
|---|---|
| **Overview** | Stat cards, today's session timeline, attendance rates, recent enrollments |
| **Conference Rooms** | Room grid — venue, capacity, current workshop booking, availability status |
| **Workshops** | Chronological list with date, room, trainer, client, enrollment count |
| **Programs & Sessions** | Collapsible cards grouped by workshop; session rows with day, time, status |
| **Enrollments & Attendance** | Filterable table — trainee, workshop, type, payment, progress, attendance flags |

### Conference Room Display Page (`/display?room=UUID`)

Public-facing TV display mounted outside the conference room.

- Shows the workshop currently booked in that room
- Displays the active program and today's session agenda
- Live clock and date
- Trainer, facilitator, and client company
- Venue and room details
- Auto-refreshes every 30 seconds from Supabase
- Also accessible via QR code for trainees on mobile

---

## Build Phases

### Phase 1 — Foundation ✅
- [x] Nuxt 4 + Supabase project setup
- [x] Auth (email/password, forgot password, signup)
- [x] Role system (`user_roles` table) + RLS policies on all tables
- [x] Database migration (9 tables: companies, user_roles, conference_rooms, workshops, programs, workshop_programs, sessions, enrollments, attendance)
- [x] Conference rooms CRUD (`/manage/admin/rooms`) — list, create, edit, delete
- [x] Workshops CRUD (`/manage/admin/workshops`) — list, create, edit, delete
- [x] Admin overview dashboard (`/manage/admin`) — stat cards, recent workshops, quick actions
- [x] Sidebar navigation with Training Mgmt section
- [x] TypeScript types matching the schema
- [x] Server API routes with Supabase service-role client

### Phase 2 — Curriculum
- Programs CRUD (reusable)
- WorkshopProgram linking (assign programs to workshops)
- Sessions CRUD (per workshop_program, per day)
- Conference room display page (live data)

### Phase 3 — Enrollment & Attendance
- Individual and batch enrollment
- Payment status tracking
- Per-session attendance marking (trainer/facilitator)
- Realtime attendance updates

### Phase 4 — Reporting & Client Portal
- Attendance summary per workshop
- Client company portal (view sponsored trainees)
- Certificate generation (PDF via Edge Function)
- Admin dashboard overview stats

---

## Key Design Decisions

- **Workshop is the anchor** — everything hangs off the workshop event, not the room
- **Conference room is optional** — workshops can be created before a venue is confirmed
- **Programs are reusable** — defined once, scheduled many times via `workshop_programs`; one-off programs are just programs used once
- **Multiple programs per workshop** — a workshop can run several programs simultaneously or sequentially across its days
- **Trainer assigned per run** — the same program can be delivered by different trainers in different workshops
- **Single training company** — no multi-tenancy required
- **Mixed enrollment** — supports both company-sponsored and self-enrolled trainees
- **Supabase RLS** enforces data access at the database level — no role checks scattered across the API layer
- **Display page is public** (no auth required) — identified by room UUID in the URL
