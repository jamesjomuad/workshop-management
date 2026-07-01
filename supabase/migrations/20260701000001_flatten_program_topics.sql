-- ============================================
-- Flatten curriculum: Program → Topic
-- Drops sections, lessons, quizzes.
-- Adds program_id directly to program_topics.
-- ============================================

-- Add program_id to program_topics
ALTER TABLE program_topics ADD COLUMN IF NOT EXISTS program_id UUID REFERENCES programs(id) ON DELETE CASCADE;

-- Backfill program_id from existing lesson → section → program chain
UPDATE program_topics pt
SET program_id = ps.program_id
FROM program_lessons pl
JOIN program_sections ps ON ps.id = pl.section_id
WHERE pt.lesson_id = pl.id AND pt.program_id IS NULL;

-- Make lesson_id nullable then drop it
ALTER TABLE program_topics ALTER COLUMN lesson_id DROP NOT NULL;
ALTER TABLE program_topics DROP COLUMN IF EXISTS lesson_id;

-- Add NOT NULL now that backfill is done
ALTER TABLE program_topics ALTER COLUMN program_id SET NOT NULL;

-- Drop old tables
DROP TABLE IF EXISTS program_quizzes CASCADE;
DROP TABLE IF EXISTS program_lessons CASCADE;
DROP TABLE IF EXISTS program_sections CASCADE;

-- Update index
DROP INDEX IF EXISTS idx_program_topics_lesson;
CREATE INDEX IF NOT EXISTS idx_program_topics_program ON program_topics(program_id);
