-- Allow contacts without a company
ALTER TABLE contacts ALTER COLUMN company_id DROP NOT NULL;
