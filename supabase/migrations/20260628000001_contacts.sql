-- ============================================
-- Contacts (people at client companies)
-- ============================================
CREATE TABLE contacts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID REFERENCES companies(id) ON DELETE CASCADE NOT NULL,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT,
  phone TEXT,
  position TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE contacts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view contacts"
  ON contacts FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin and staff can insert contacts"
  ON contacts FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Admin and staff can update contacts"
  ON contacts FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff'));

CREATE POLICY "Only admin can delete contacts"
  ON contacts FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE INDEX idx_contacts_company ON contacts(company_id);
