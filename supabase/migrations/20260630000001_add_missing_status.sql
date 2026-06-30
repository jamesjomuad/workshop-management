ALTER TABLE programs ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed'));

ALTER TABLE program_lessons ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed'));

ALTER TABLE program_topics ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed'));

ALTER TABLE program_quizzes ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'ongoing', 'completed'));
