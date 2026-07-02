-- ============================================
-- Table: workshop_programs
-- Junction linking programs to workshops.
-- ============================================
DROP TABLE IF EXISTS workshop_programs CASCADE;

CREATE TABLE workshop_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID REFERENCES workshops(id) ON DELETE CASCADE NOT NULL,
  program_id UUID REFERENCES programs(id) ON DELETE CASCADE NOT NULL,
  trainer_id UUID REFERENCES user_roles(id),
  notes TEXT,
  UNIQUE(workshop_id, program_id)
);

ALTER TABLE workshop_programs ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_workshop_programs_workshop ON workshop_programs(workshop_id);
CREATE INDEX idx_workshop_programs_program ON workshop_programs(program_id);
