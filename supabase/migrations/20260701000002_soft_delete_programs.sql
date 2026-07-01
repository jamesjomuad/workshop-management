-- Soft delete support for programs
ALTER TABLE programs ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_programs_deleted_at ON programs(deleted_at);
