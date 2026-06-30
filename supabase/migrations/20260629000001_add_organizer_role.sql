-- ============================================
-- Add 'organizer' role to CHECK constraint
-- ============================================
ALTER TABLE user_roles DROP CONSTRAINT IF EXISTS user_roles_role_check;
ALTER TABLE user_roles ADD CONSTRAINT user_roles_role_check
  CHECK (role IN ('admin', 'staff', 'trainer', 'facilitator', 'trainee', 'client', 'organizer'));

-- ============================================
-- Recreate policies to include 'organizer'
-- ============================================

-- Companies
DROP POLICY IF EXISTS "Admin and staff can insert companies" ON companies;
DROP POLICY IF EXISTS "Admin and staff can update companies" ON companies;
CREATE POLICY "Admin, staff, and organizers can insert companies"
  ON companies FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can update companies"
  ON companies FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

-- Venues
DROP POLICY IF EXISTS "Admin and staff can insert venues" ON venues;
DROP POLICY IF EXISTS "Admin and staff can update venues" ON venues;
CREATE POLICY "Admin, staff, and organizers can insert venues"
  ON venues FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can update venues"
  ON venues FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

-- Workshops
DROP POLICY IF EXISTS "Admin and staff can insert workshops" ON workshops;
DROP POLICY IF EXISTS "Admin and staff can update workshops" ON workshops;
CREATE POLICY "Admin, staff, and organizers can insert workshops"
  ON workshops FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can update workshops"
  ON workshops FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

-- Programs
DROP POLICY IF EXISTS "Admin, staff, and trainers can insert programs" ON programs;
DROP POLICY IF EXISTS "Admin, staff, and trainers can update programs" ON programs;
CREATE POLICY "Admin, staff, trainers, and organizers can insert programs"
  ON programs FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update programs"
  ON programs FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

-- WorkshopProgram
DROP POLICY IF EXISTS "Admin and staff can insert workshop_programs" ON workshop_programs;
DROP POLICY IF EXISTS "Admin and staff can update workshop_programs" ON workshop_programs;
CREATE POLICY "Admin, staff, and organizers can insert workshop_programs"
  ON workshop_programs FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can update workshop_programs"
  ON workshop_programs FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

-- Sessions
DROP POLICY IF EXISTS "Admin, staff, and trainers can insert sessions" ON sessions;
DROP POLICY IF EXISTS "Admin, staff, and trainers can update sessions" ON sessions;
CREATE POLICY "Admin, staff, trainers, and organizers can insert sessions"
  ON sessions FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));
CREATE POLICY "Admin, staff, trainers, and organizers can update sessions"
  ON sessions FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'organizer'));

-- Enrollments
DROP POLICY IF EXISTS "Admin, staff, and facilitators can view all enrollments" ON enrollments;
DROP POLICY IF EXISTS "Admin and staff can insert enrollments" ON enrollments;
DROP POLICY IF EXISTS "Admin and staff can update enrollments" ON enrollments;
CREATE POLICY "Admin, staff, facilitators, and organizers can view all enrollments"
  ON enrollments FOR SELECT TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'facilitator', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can insert enrollments"
  ON enrollments FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));
CREATE POLICY "Admin, staff, and organizers can update enrollments"
  ON enrollments FOR UPDATE TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

-- Attendance
DROP POLICY IF EXISTS "Admin, staff, trainers, and facilitators can view all attendance" ON attendance;
DROP POLICY IF EXISTS "Trainers and facilitators can mark attendance" ON attendance;
DROP POLICY IF EXISTS "Trainers and facilitators can update attendance" ON attendance;
CREATE POLICY "Admin, staff, trainers, facilitators, and organizers can view all attendance"
  ON attendance FOR SELECT TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'trainer', 'facilitator', 'organizer'));
CREATE POLICY "Trainers, facilitators, and organizers can mark attendance"
  ON attendance FOR INSERT TO authenticated
  WITH CHECK (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff', 'organizer'));
CREATE POLICY "Trainers, facilitators, and organizers can update attendance"
  ON attendance FOR UPDATE TO authenticated
  USING (get_user_role() IN ('trainer', 'facilitator', 'admin', 'staff', 'organizer'));
