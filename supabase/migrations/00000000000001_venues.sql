-- ============================================
-- Table: venues
-- ============================================
DROP TABLE IF EXISTS venues CASCADE;

CREATE TABLE venues (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT NOT NULL DEFAULT 'other' CHECK (type IN ('hotel', 'convention_center', 'office', 'other')),
  address TEXT,
  city TEXT,
  province TEXT,
  country TEXT DEFAULT 'Philippines',
  postal_code TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  contact_person TEXT,
  contact_phone TEXT,
  contact_email TEXT,
  logo_url TEXT,
  cover_image_url TEXT,
  notes TEXT,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE venues ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view venues"
  ON venues FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and organizers can insert venues"
  ON venues FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update venues"
  ON venues FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Only admin can delete venues"
  ON venues FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE INDEX idx_venues_type ON venues(type);
CREATE INDEX idx_venues_city ON venues(city);

INSERT INTO venues (name, type, address, city, province, country, postal_code, notes, is_active) VALUES
  ('Grand Hyatt Hotel', 'hotel', '123 Main Street, Downtown', 'Makati', 'Metro Manila', 'Philippines', '1200', 'Full sound system, stage, and catering available', true),
  ('Business Center Plaza', 'office', '456 Commerce Drive, CBD', 'Taguig', 'Metro Manila', 'Philippines', '1634', 'Executive boardroom with video conferencing', true),
  ('Marina Tower', 'office', '789 Bayfront Avenue', 'Pasay', 'Metro Manila', 'Philippines', '1300', 'Panoramic city view, premium AV equipment', true),
  ('Royal Garden Resort', 'hotel', '321 Paradise Lane', 'Cebu City', 'Cebu', 'Philippines', '6000', 'Outdoor covered pavilion with garden access', true),
  ('Tech Park Complex', 'convention_center', '654 Innovation Drive, Tech Hub', 'Mandaue', 'Cebu', 'Philippines', '6014', 'Standing desks, whiteboard walls, prototyping tools', true),
  ('Waterfront Hotel', 'hotel', '987 Harbor Boulevard', 'Cebu City', 'Cebu', 'Philippines', '6000', 'Harbor view with built-in projector and breakout areas', true),
  ('City Center Tower', 'office', '147 Central Avenue', 'Makati', 'Metro Manila', 'Philippines', '1200', 'Premium executive space with lounge and kitchenette', true);
