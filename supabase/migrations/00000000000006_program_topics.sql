-- ============================================
-- Table: program_topics
-- Flattened curriculum: each topic belongs directly to a program.
-- ============================================
DROP TABLE IF EXISTS program_topics CASCADE;

CREATE TABLE program_topics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  content JSONB,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE program_topics ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_program_topics_program ON program_topics(program_id);
