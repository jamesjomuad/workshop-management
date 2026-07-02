-- ============================================
-- Table: workshop_schedules
-- ============================================
DROP TABLE IF EXISTS workshop_schedules CASCADE;

CREATE TABLE workshop_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID NOT NULL REFERENCES workshops(id) ON DELETE CASCADE,
  date_start DATE NOT NULL,
  date_end DATE NOT NULL,
  time_start TIME,
  time_end TIME,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE workshop_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view workshop_schedules"
  ON workshop_schedules FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and organizers can insert workshop_schedules"
  ON workshop_schedules FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update workshop_schedules"
  ON workshop_schedules FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Only admin can delete workshop_schedules"
  ON workshop_schedules FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE INDEX idx_workshop_schedules_workshop ON workshop_schedules(workshop_id);
CREATE INDEX idx_workshop_schedules_dates ON workshop_schedules(date_start, date_end);
