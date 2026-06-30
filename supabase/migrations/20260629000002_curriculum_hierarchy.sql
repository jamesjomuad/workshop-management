-- ============================================
-- Curriculum hierarchy: programs → sections
-- → lessons → topics → quizzes
-- Combines and supersedes earlier migrations.
-- ============================================

-- Drop old sessions table (if upgrading from earlier schema)
ALTER TABLE attendance DROP CONSTRAINT IF EXISTS attendance_session_id_fkey;
DROP INDEX IF EXISTS idx_sessions_program;
DROP TABLE IF EXISTS sessions CASCADE;

-- ============================================
-- Programs
-- ============================================
CREATE TABLE IF NOT EXISTS programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  created_by UUID REFERENCES user_roles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add columns added after initial creation
ALTER TABLE programs ADD COLUMN IF NOT EXISTS content JSONB;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS slug TEXT;
CREATE UNIQUE INDEX IF NOT EXISTS idx_programs_slug ON programs(slug) WHERE slug IS NOT NULL;
ALTER TABLE programs ADD COLUMN IF NOT EXISTS order_index INTEGER NOT NULL DEFAULT 0;

-- ============================================
-- Program Sections
-- ============================================
CREATE TABLE IF NOT EXISTS program_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE program_sections ADD COLUMN IF NOT EXISTS content JSONB;

-- ============================================
-- Program Lessons
-- ============================================
CREATE TABLE IF NOT EXISTS program_lessons (
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
CREATE TABLE IF NOT EXISTS program_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES program_lessons(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE program_topics ADD COLUMN IF NOT EXISTS content JSONB;

-- ============================================
-- Program Quizzes / Assignments
-- ============================================
CREATE TABLE IF NOT EXISTS program_quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id UUID REFERENCES program_topics(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('quiz', 'assignment')),
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- RLS
-- ============================================
ALTER TABLE programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_quizzes ENABLE ROW LEVEL SECURITY;

-- Programs
DROP POLICY IF EXISTS "All authenticated users can view programs" ON programs;
CREATE POLICY "All authenticated users can view programs"
  ON programs FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert programs" ON programs;
CREATE POLICY "Admin, staff, trainers, and organizers can insert programs"
  ON programs FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update programs" ON programs;
CREATE POLICY "Admin, staff, trainers, and organizers can update programs"
  ON programs FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Only admin can delete programs" ON programs;
CREATE POLICY "Only admin can delete programs"
  ON programs FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- Sections
DROP POLICY IF EXISTS "All authenticated users can view program sections" ON program_sections;
CREATE POLICY "All authenticated users can view program sections"
  ON program_sections FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert program sections" ON program_sections;
CREATE POLICY "Admin, staff, trainers, and organizers can insert program sections"
  ON program_sections FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update program sections" ON program_sections;
CREATE POLICY "Admin, staff, trainers, and organizers can update program sections"
  ON program_sections FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Only admin can delete program sections" ON program_sections;
CREATE POLICY "Only admin can delete program sections"
  ON program_sections FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- Lessons
DROP POLICY IF EXISTS "All authenticated users can view program lessons" ON program_lessons;
CREATE POLICY "All authenticated users can view program lessons"
  ON program_lessons FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert program lessons" ON program_lessons;
CREATE POLICY "Admin, staff, trainers, and organizers can insert program lessons"
  ON program_lessons FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update program lessons" ON program_lessons;
CREATE POLICY "Admin, staff, trainers, and organizers can update program lessons"
  ON program_lessons FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Only admin can delete program lessons" ON program_lessons;
CREATE POLICY "Only admin can delete program lessons"
  ON program_lessons FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- Topics
DROP POLICY IF EXISTS "All authenticated users can view program topics" ON program_topics;
CREATE POLICY "All authenticated users can view program topics"
  ON program_topics FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert program topics" ON program_topics;
CREATE POLICY "Admin, staff, trainers, and organizers can insert program topics"
  ON program_topics FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update program topics" ON program_topics;
CREATE POLICY "Admin, staff, trainers, and organizers can update program topics"
  ON program_topics FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Only admin can delete program topics" ON program_topics;
CREATE POLICY "Only admin can delete program topics"
  ON program_topics FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- Quizzes
DROP POLICY IF EXISTS "All authenticated users can view program quizzes" ON program_quizzes;
CREATE POLICY "All authenticated users can view program quizzes"
  ON program_quizzes FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can insert program quizzes" ON program_quizzes;
CREATE POLICY "Admin, staff, trainers, and organizers can insert program quizzes"
  ON program_quizzes FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Admin, staff, trainers, and organizers can update program quizzes" ON program_quizzes;
CREATE POLICY "Admin, staff, trainers, and organizers can update program quizzes"
  ON program_quizzes FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
DROP POLICY IF EXISTS "Only admin can delete program quizzes" ON program_quizzes;
CREATE POLICY "Only admin can delete program quizzes"
  ON program_quizzes FOR DELETE TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX IF NOT EXISTS idx_programs_order ON programs(order_index);
CREATE INDEX IF NOT EXISTS idx_program_sections_program ON program_sections(program_id);
CREATE INDEX IF NOT EXISTS idx_program_lessons_section ON program_lessons(section_id);
CREATE INDEX IF NOT EXISTS idx_program_topics_lesson ON program_topics(lesson_id);
CREATE INDEX IF NOT EXISTS idx_program_quizzes_topic ON program_quizzes(topic_id);

-- Set sequential order for existing programs
UPDATE programs SET order_index = sub.row_num
FROM (SELECT id, row_number() OVER (ORDER BY created_at) - 1 AS row_num FROM programs) sub
WHERE programs.id = sub.id AND programs.order_index = 0;
