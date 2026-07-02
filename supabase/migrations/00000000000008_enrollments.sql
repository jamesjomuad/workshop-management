-- ============================================
-- Table: enrollments
-- ============================================
DROP TABLE IF EXISTS enrollments CASCADE;

CREATE TABLE enrollments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID REFERENCES workshops(id) ON DELETE CASCADE NOT NULL,
  trainee_id UUID REFERENCES user_roles(id) ON DELETE CASCADE NOT NULL,
  enrolled_by TEXT NOT NULL CHECK (enrolled_by IN ('self', 'company')),
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('paid', 'pending', 'waived')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(workshop_id, trainee_id)
);

ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_enrollments_workshop ON enrollments(workshop_id);
CREATE INDEX idx_enrollments_trainee ON enrollments(trainee_id);
