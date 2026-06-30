-- ============================================
-- Replace old sessions table with program
-- hierarchy: sections → lessons → topics → quizzes
-- ============================================

-- Drop attendance FK to sessions first, then sessions
ALTER TABLE attendance DROP CONSTRAINT IF EXISTS attendance_session_id_fkey;
DROP INDEX IF EXISTS idx_sessions_program;
DROP TABLE IF EXISTS sessions CASCADE;

-- Drop old sessions policies
DROP POLICY IF EXISTS "All authenticated users can view sessions" ON sessions;
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert sessions" ON sessions;
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update sessions" ON sessions;
DROP POLICY IF EXISTS "Only admin can delete sessions" ON sessions;

-- Add status column to programs
ALTER TABLE programs ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'upcoming'
  CHECK (status IN ('upcoming', 'ongoing', 'completed'));

-- Program Sections
CREATE TABLE IF NOT EXISTS program_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Program Lessons
CREATE TABLE IF NOT EXISTS program_lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id UUID REFERENCES program_sections(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Program Topics
CREATE TABLE IF NOT EXISTS program_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES program_lessons(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Program Quizzes / Assignments
CREATE TABLE IF NOT EXISTS program_quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id UUID REFERENCES program_topics(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('quiz', 'assignment')),
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- RLS enables
ALTER TABLE program_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_quizzes ENABLE ROW LEVEL SECURITY;

-- RLS Policies: Program Sections
CREATE POLICY "All authenticated users can view program sections"
  ON program_sections FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admin, staff, trainers, and organizers can insert program sections"
  ON program_sections FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update program sections"
  ON program_sections FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Only admin can delete program sections"
  ON program_sections FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- RLS Policies: Program Lessons
CREATE POLICY "All authenticated users can view program lessons"
  ON program_lessons FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admin, staff, trainers, and organizers can insert program lessons"
  ON program_lessons FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update program lessons"
  ON program_lessons FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Only admin can delete program lessons"
  ON program_lessons FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- RLS Policies: Program Topics
CREATE POLICY "All authenticated users can view program topics"
  ON program_topics FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admin, staff, trainers, and organizers can insert program topics"
  ON program_topics FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update program topics"
  ON program_topics FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Only admin can delete program topics"
  ON program_topics FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- RLS Policies: Program Quizzes
CREATE POLICY "All authenticated users can view program quizzes"
  ON program_quizzes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admin, staff, trainers, and organizers can insert program quizzes"
  ON program_quizzes FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update program quizzes"
  ON program_quizzes FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Only admin can delete program quizzes"
  ON program_quizzes FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- Indexes
CREATE INDEX IF NOT EXISTS idx_program_sections_program ON program_sections(program_id);
CREATE INDEX IF NOT EXISTS idx_program_lessons_section ON program_lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_program_topics_lesson ON program_topics(lesson_id);
CREATE INDEX IF NOT EXISTS idx_program_quizzes_topic ON program_quizzes(topic_id);
