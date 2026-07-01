-- ============================================
-- Add time columns to workshops
-- ============================================

ALTER TABLE workshops
  ADD COLUMN time_start TIME,
  ADD COLUMN time_end TIME;
