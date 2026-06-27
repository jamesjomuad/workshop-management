-- ============================================
-- Companies
-- ============================================
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  contact_email TEXT,
  contact_phone TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- User Roles (extending auth.users)
-- ============================================
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'staff', 'trainer', 'facilitator', 'trainee', 'client')),
  company_id UUID REFERENCES companies(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Conference Rooms
-- ============================================
CREATE TABLE conference_rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  venue_name TEXT NOT NULL,
  venue_address TEXT,
  floor TEXT,
  capacity INTEGER NOT NULL,
  notes TEXT,
  status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'booked', 'in_use')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Workshops (central event entity)
-- ============================================
CREATE TABLE workshops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  date_start DATE NOT NULL,
  date_end DATE NOT NULL,
  conference_room_id UUID REFERENCES conference_rooms(id),
  facilitator_id UUID REFERENCES user_roles(id),
  client_id UUID REFERENCES companies(id),
  status TEXT NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'ongoing', 'completed', 'cancelled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Programs (reusable curriculum)
-- ============================================
CREATE TABLE programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  created_by UUID REFERENCES user_roles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- WorkshopProgram (junction)
-- ============================================
CREATE TABLE workshop_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID REFERENCES workshops(id) ON DELETE CASCADE NOT NULL,
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  trainer_id UUID REFERENCES user_roles(id),
  notes TEXT,
  UNIQUE(workshop_id, program_id)
);

-- ============================================
-- Sessions (per workshop_program, per day)
-- ============================================
CREATE TABLE sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_program_id UUID REFERENCES workshop_programs(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  day_number INTEGER NOT NULL,
  time_start TIME NOT NULL,
  time_end TIME NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Enrollments
-- ============================================
CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID REFERENCES workshops(id) ON DELETE CASCADE NOT NULL,
  trainee_id UUID REFERENCES user_roles(id) ON DELETE CASCADE NOT NULL,
  enrolled_by TEXT NOT NULL CHECK (enrolled_by IN ('self', 'company')),
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('paid', 'pending', 'waived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workshop_id, trainee_id)
);

-- ============================================
-- Attendance (per session per enrollment)
-- ============================================
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES sessions(id) ON DELETE CASCADE NOT NULL,
  enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late')),
  marked_at TIMESTAMPTZ DEFAULT NOW(),
  marked_by UUID REFERENCES user_roles(id),
  UNIQUE(session_id, enrollment_id)
);

-- ============================================
-- RLS: Enable row-level security on all tables
-- ============================================
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE conference_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshops ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshop_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

-- ============================================
-- Helper: get current user's role
-- ============================================
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT
LANGUAGE SQL STABLE
AS $$
  SELECT role FROM user_roles WHERE user_id = auth.uid()
$$;

-- ============================================
-- RLS Policies: Companies
-- ============================================
CREATE POLICY "All authenticated users can view companies"
  ON companies FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin and staff can insert companies"
  ON companies FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update companies"
  ON companies FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete companies"
  ON companies FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: User Roles
-- ============================================
CREATE POLICY "Users can view their own role"
  ON user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Admin can view all roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Only admin can insert roles"
  ON user_roles FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Only admin can update roles"
  ON user_roles FOR UPDATE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Only admin can delete roles"
  ON user_roles FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Conference Rooms
-- ============================================
CREATE POLICY "All authenticated users can view rooms"
  ON conference_rooms FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin and staff can insert rooms"
  ON conference_rooms FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update rooms"
  ON conference_rooms FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete rooms"
  ON conference_rooms FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Workshops
-- ============================================
CREATE POLICY "All authenticated users can view workshops"
  ON workshops FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin and staff can insert workshops"
  ON workshops FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update workshops"
  ON workshops FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete workshops"
  ON workshops FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Programs
-- ============================================
CREATE POLICY "All authenticated users can view programs"
  ON programs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and trainers can insert programs"
  ON programs FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer'));

CREATE POLICY "Admin, staff, and trainers can update programs"
  ON programs FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer'));

CREATE POLICY "Only admin can delete programs"
  ON programs FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: WorkshopProgram
-- ============================================
CREATE POLICY "All authenticated users can view workshop_programs"
  ON workshop_programs FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin and staff can insert workshop_programs"
  ON workshop_programs FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update workshop_programs"
  ON workshop_programs FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete workshop_programs"
  ON workshop_programs FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Sessions
-- ============================================
CREATE POLICY "All authenticated users can view sessions"
  ON sessions FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and trainers can insert sessions"
  ON sessions FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer'));

CREATE POLICY "Admin, staff, and trainers can update sessions"
  ON sessions FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer'));

CREATE POLICY "Only admin can delete sessions"
  ON sessions FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Enrollments
-- ============================================
CREATE POLICY "Users can view their own enrollments"
  ON enrollments FOR SELECT
  TO authenticated
  USING (trainee_id = auth.uid());

CREATE POLICY "Admin, staff, and facilitators can view all enrollments"
  ON enrollments FOR SELECT
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'facilitator'));

CREATE POLICY "Admin and staff can insert enrollments"
  ON enrollments FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update enrollments"
  ON enrollments FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete enrollments"
  ON enrollments FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Attendance
-- ============================================
CREATE POLICY "Users can view their own attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM enrollments e
      WHERE e.id = attendance.enrollment_id AND e.trainee_id = auth.uid()
    )
  );

CREATE POLICY "Admin, staff, trainers, and facilitators can view all attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'facilitator'));

CREATE POLICY "Trainers and facilitators can mark attendance"
  ON attendance FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff'));

CREATE POLICY "Trainers and facilitators can update attendance"
  ON attendance FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff'));

CREATE POLICY "Only admin can delete attendance"
  ON attendance FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_workshops_status ON workshops(status);
CREATE INDEX idx_workshops_date_start ON workshops(date_start);
CREATE INDEX idx_workshops_conference_room ON workshops(conference_room_id);
CREATE INDEX idx_workshop_programs_workshop ON workshop_programs(workshop_id);
CREATE INDEX idx_workshop_programs_program ON workshop_programs(program_id);
CREATE INDEX idx_sessions_program ON sessions(workshop_program_id);
CREATE INDEX idx_enrollments_workshop ON enrollments(workshop_id);
CREATE INDEX idx_enrollments_trainee ON enrollments(trainee_id);
CREATE INDEX idx_attendance_session ON attendance(session_id);
CREATE INDEX idx_attendance_enrollment ON attendance(enrollment_id);

-- ============================================
-- Seed data
-- ============================================
INSERT INTO companies (id, name, contact_email) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Internal Training Co', 'admin@trainingco.com');
