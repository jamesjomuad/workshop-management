-- ============================================
-- Table: workshops
-- ============================================
DROP TABLE IF EXISTS workshops CASCADE;

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

ALTER TABLE workshops ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_workshops_status ON workshops(status);
CREATE INDEX idx_workshops_date_start ON workshops(date_start);
CREATE INDEX idx_workshops_conference_room ON workshops(conference_room_id);
