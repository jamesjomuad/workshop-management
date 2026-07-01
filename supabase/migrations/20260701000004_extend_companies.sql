-- ============================================
-- Extend companies with full business profile
-- ============================================

-- Status enum
CREATE TYPE company_status AS ENUM ('active', 'inactive', 'suspended');

-- Size enum
CREATE TYPE company_size AS ENUM ('1-10', '11-50', '51-200', '200+');

ALTER TABLE companies
  -- Core identity
  ADD COLUMN slug TEXT UNIQUE,
  ADD COLUMN logo_url TEXT,
  ADD COLUMN status company_status DEFAULT 'active',

  -- Contact info (rename existing columns)
  ADD COLUMN website TEXT,
  ADD COLUMN address TEXT,
  ADD COLUMN city TEXT,
  ADD COLUMN state TEXT,
  ADD COLUMN country TEXT,
  ADD COLUMN postal_code TEXT,

  -- Business details
  ADD COLUMN industry TEXT,
  ADD COLUMN size company_size,
  ADD COLUMN registration_number TEXT,
  ADD COLUMN tax_number TEXT;
