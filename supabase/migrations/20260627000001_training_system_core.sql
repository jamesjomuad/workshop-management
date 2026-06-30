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
  role TEXT NOT NULL CHECK (role IN ('admin', 'staff', 'trainer', 'facilitator', 'trainee', 'client', 'organizer')),
  company_id UUID REFERENCES companies(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Venues
-- ============================================
CREATE TABLE venues (
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
  conference_room_id UUID REFERENCES venues(id),
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
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  created_by UUID REFERENCES user_roles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Program Sections
-- ============================================
CREATE TABLE program_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Program Lessons
-- ============================================
CREATE TABLE program_lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id UUID REFERENCES program_sections(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Program Topics
-- ============================================
CREATE TABLE program_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES program_lessons(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Program Quizzes / Assignments
-- ============================================
CREATE TABLE program_quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id UUID REFERENCES program_topics(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('quiz', 'assignment')),
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
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
-- Attendance (per learner per session)
-- Note: FK to sessions removed; sessions table
-- was replaced by the program hierarchy.
-- Revisit attendance model when implementing
-- attendance tracking in Phase 3.
-- ============================================
CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL,
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
ALTER TABLE venues ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshops ENABLE ROW LEVEL SECURITY;
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE workshop_programs ENABLE ROW LEVEL SECURITY;
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

CREATE POLICY "Admin, staff, and organizers can insert companies"
  ON companies FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update companies"
  ON companies FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

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
-- RLS Policies: Venues
-- ============================================
CREATE POLICY "All authenticated users can view venues"
  ON venues FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and organizers can insert venues"
  ON venues FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update venues"
  ON venues FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Only admin can delete venues"
  ON venues FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Workshops
-- ============================================
CREATE POLICY "All authenticated users can view workshops"
  ON workshops FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and organizers can insert workshops"
  ON workshops FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update workshops"
  ON workshops FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

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

CREATE POLICY "Admin, staff, trainers, and organizers can insert programs"
  ON programs FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Admin, staff, trainers, and organizers can update programs"
  ON programs FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

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

CREATE POLICY "Admin, staff, and organizers can insert workshop_programs"
  ON workshop_programs FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update workshop_programs"
  ON workshop_programs FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Only admin can delete workshop_programs"
  ON workshop_programs FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Program Sections
-- ============================================
CREATE POLICY "All authenticated users can view program sections"
  ON program_sections FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, trainers, and organizers can insert program sections"
  ON program_sections FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Admin, staff, trainers, and organizers can update program sections"
  ON program_sections FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Only admin can delete program sections"
  ON program_sections FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Program Lessons
-- ============================================
CREATE POLICY "All authenticated users can view program lessons"
  ON program_lessons FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, trainers, and organizers can insert program lessons"
  ON program_lessons FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Admin, staff, trainers, and organizers can update program lessons"
  ON program_lessons FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Only admin can delete program lessons"
  ON program_lessons FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Program Topics
-- ============================================
CREATE POLICY "All authenticated users can view program topics"
  ON program_topics FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, trainers, and organizers can insert program topics"
  ON program_topics FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Admin, staff, trainers, and organizers can update program topics"
  ON program_topics FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Only admin can delete program topics"
  ON program_topics FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Program Quizzes
-- ============================================
CREATE POLICY "All authenticated users can view program quizzes"
  ON program_quizzes FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, trainers, and organizers can insert program quizzes"
  ON program_quizzes FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Admin, staff, trainers, and organizers can update program quizzes"
  ON program_quizzes FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

CREATE POLICY "Only admin can delete program quizzes"
  ON program_quizzes FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- RLS Policies: Enrollments
-- ============================================
CREATE POLICY "Users can view their own enrollments"
  ON enrollments FOR SELECT
  TO authenticated
  USING (trainee_id = auth.uid());

CREATE POLICY "Admin, staff, facilitators, and organizers can view all enrollments"
  ON enrollments FOR SELECT
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'facilitator', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can insert enrollments"
  ON enrollments FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update enrollments"
  ON enrollments FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

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

CREATE POLICY "Admin, staff, trainers, facilitators, and organizers can view all attendance"
  ON attendance FOR SELECT
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'facilitator', 'organizer'));

CREATE POLICY "Trainers, facilitators, and organizers can mark attendance"
  ON attendance FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff', 'organizer'));

CREATE POLICY "Trainers, facilitators, and organizers can update attendance"
  ON attendance FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff', 'organizer'));

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
CREATE INDEX idx_program_sections_program ON program_sections(program_id);
CREATE INDEX idx_program_lessons_section ON program_lessons(section_id);
CREATE INDEX idx_program_topics_lesson ON program_topics(lesson_id);
CREATE INDEX idx_program_quizzes_topic ON program_quizzes(topic_id);
CREATE INDEX idx_enrollments_workshop ON enrollments(workshop_id);
CREATE INDEX idx_enrollments_trainee ON enrollments(trainee_id);
CREATE INDEX idx_attendance_session ON attendance(session_id);
CREATE INDEX idx_attendance_enrollment ON attendance(enrollment_id);

-- ============================================
-- Seed data
-- ============================================
INSERT INTO companies (id, name, contact_email) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Internal Training Co', 'admin@trainingco.com');
