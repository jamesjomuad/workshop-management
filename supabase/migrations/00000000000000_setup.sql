-- ============================================
-- Setup: shared types, base tables, helper function
-- ============================================
-- This migration must run first. It creates the enum types,
-- the companies and user_roles tables, and the get_user_role()
-- helper function that later table migrations use in their RLS policies.
--
-- WARNING: This migration drops and recreates these objects.
-- Use only for fresh databases.
-- ============================================

-- Drop dependent objects first
DROP TABLE IF EXISTS user_roles CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TYPE IF EXISTS company_status CASCADE;
DROP TYPE IF EXISTS company_size CASCADE;

-- ============================================
-- Types
-- ============================================
CREATE TYPE company_status AS ENUM ('active', 'inactive', 'suspended');
CREATE TYPE company_size AS ENUM ('1-10', '11-50', '51-200', '200+');

-- ============================================
-- Companies
-- ============================================
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE,
  logo_url TEXT,
  status company_status DEFAULT 'active',
  contact_email TEXT,
  contact_phone TEXT,
  website TEXT,
  address TEXT,
  city TEXT,
  state TEXT,
  country TEXT,
  postal_code TEXT,
  industry TEXT,
  size company_size,
  registration_number TEXT,
  tax_number TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO companies (id, name, contact_email) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Internal Training Co', 'admin@trainingco.com');

-- ============================================
-- User Roles (extends auth.users)
-- ============================================
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('admin', 'staff', 'trainer', 'facilitator', 'trainee', 'client', 'organizer')),
  company_id UUID REFERENCES companies(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- Helper: current user's role
-- ============================================
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT
LANGUAGE SQL STABLE
AS $$
  SELECT role FROM user_roles WHERE user_id = auth.uid()
$$;

-- ============================================
-- RLS: companies and user_roles
-- ============================================
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All authenticated users can view companies"
  ON companies FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admin, staff, and organizers can insert companies"
  ON companies FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Admin, staff, and organizers can update companies"
  ON companies FOR UPDATE
  TO authenticated
  USING (get_user_role() IN ('admin', 'staff', 'organizer'));

CREATE POLICY "Only admin can delete companies"
  ON companies FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Users can view their own role"
  ON user_roles FOR SELECT
  TO authenticated
  USING (user_id = auth.uid());

CREATE POLICY "Admin can view all roles"
  ON user_roles FOR SELECT
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Only admin can insert roles"
  ON user_roles FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'admin');

CREATE POLICY "Only admin can update roles"
  ON user_roles FOR UPDATE
  TO authenticated
  USING (get_user_role() = 'admin');

CREATE POLICY "Only admin can delete roles"
  ON user_roles FOR DELETE
  TO authenticated
  USING (get_user_role() = 'admin');

-- ============================================
-- Indexes
-- ============================================
CREATE INDEX idx_user_roles_user_id ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role);
CREATE INDEX idx_companies_slug ON companies(slug) WHERE slug IS NOT NULL;
