-- ============================================
-- Table: programs
-- ============================================
DROP TABLE IF EXISTS programs CASCADE;

CREATE TABLE programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  content JSONB,
  slug TEXT,
  order_index INTEGER NOT NULL DEFAULT 0,
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed')),
  created_by UUID REFERENCES user_roles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ
);

ALTER TABLE programs ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_programs_order ON programs(order_index);
CREATE UNIQUE INDEX idx_programs_slug ON programs(slug) WHERE slug IS NOT NULL;
CREATE INDEX idx_programs_deleted_at ON programs(deleted_at);
