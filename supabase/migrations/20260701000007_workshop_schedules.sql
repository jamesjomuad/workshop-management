-- ============================================
-- Workshop schedules: per-range date + time
-- ============================================

CREATE TABLE workshop_schedules (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workshop_id UUID NOT NULL REFERENCES workshops(id) ON DELETE CASCADE,
  date_start DATE NOT NULL,
  date_end DATE NOT NULL,
  time_start TIME,
  time_end TIME,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_workshop_schedules_workshop ON workshop_schedules(workshop_id);
CREATE INDEX idx_workshop_schedules_dates ON workshop_schedules(date_start, date_end);

-- Migrate existing time data into schedules if present
INSERT INTO workshop_schedules (workshop_id, date_start, date_end, time_start, time_end)
SELECT id, date_start, date_end, time_start, time_end
FROM workshops
WHERE time_start IS NOT NULL OR time_end IS NOT NULL;

-- Drop time columns from workshops (no longer needed at workshop level)
ALTER TABLE workshops
  DROP COLUMN IF EXISTS time_start,
  DROP COLUMN IF EXISTS time_end;
