-- ============================================
-- Table: attendance
-- Per-learner attendance. session_id is intentionally not a foreign key;
-- the legacy sessions table was removed and session semantics will be
-- defined when attendance tracking is implemented in Phase 3.
-- ============================================
DROP TABLE IF EXISTS attendance CASCADE;

CREATE TABLE attendance (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID NOT NULL,
  enrollment_id UUID REFERENCES enrollments(id) ON DELETE CASCADE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'late')),
  marked_at TIMESTAMPTZ DEFAULT NOW(),
  marked_by UUID REFERENCES user_roles(id),
  UNIQUE(session_id, enrollment_id)
);

ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;

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

CREATE INDEX idx_attendance_session ON attendance(session_id);
CREATE INDEX idx_attendance_enrollment ON attendance(enrollment_id);
