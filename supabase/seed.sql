-- Seed data for curriculum (5 programs, 2-3 topics each via sections/lessons)
-- Requires an existing auth user + user_roles entry; use the first admin found

DO $$
DECLARE
  admin_id UUID;
  prog_id UUID;
  section_id UUID;
  lesson_id UUID;
  topic_id UUID;
BEGIN
  -- Find an existing admin user
  SELECT user_id INTO admin_id FROM user_roles WHERE role = 'admin' LIMIT 1;
  IF admin_id IS NULL THEN
    RAISE NOTICE 'No admin user found; skipping seed.';
    RETURN;
  END IF;

  -- 1. Project Management Fundamentals
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Project Management Fundamentals', 'Core project management principles including scope, time, and cost management.', 'ongoing', 0, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Introduction to PM', 0) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'What is a Project?', 'completed', 0) RETURNING id INTO lesson_id;
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Project vs Operations', 'completed', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Triple Constraint', 'completed', 1);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'PM Lifecycle', 'ongoing', 1) RETURNING id INTO lesson_id;
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Initiation Phase', 'ongoing', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Planning Phase', 'upcoming', 1);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Execution & Closure', 'upcoming', 2);

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Tools & Techniques', 1) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Work Breakdown Structure', 'upcoming', 0) RETURNING id INTO lesson_id;
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Creating a WBS', 'upcoming', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'WBS Dictionary', 'upcoming', 1);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Gantt Charts & Scheduling', 'upcoming', 1);

  -- 2. Safety Training Program
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Workplace Safety Training', 'OSHA-aligned safety training covering hazard identification, PPE, and emergency response.', 'ongoing', 1, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Hazard Identification', 0) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Common Workplace Hazards', 'completed', 0) RETURNING id INTO lesson_id;
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Physical Hazards', 'completed', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Chemical Hazards', 'completed', 1);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Ergonomic Risks', 'completed', 2);

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Emergency Response', 1) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Fire Safety & Evacuation', 'ongoing', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'First Aid Fundamentals', 'upcoming', 1);

  -- 3. Leadership Excellence
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Leadership Excellence', 'Develop leadership skills including communication, delegation, and team motivation.', 'upcoming', 2, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Core Leadership Skills', 0) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Communication Mastery', 'upcoming', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Delegation & Empowerment', 'upcoming', 1);

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Team Dynamics', 1) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Building Trust', 'upcoming', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Conflict Resolution', 'upcoming', 1);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Mediation Techniques', 'upcoming', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Giving Constructive Feedback', 'upcoming', 1);

  -- 4. Digital Literacy
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Digital Literacy for Professionals', 'Essential digital skills including productivity tools, online collaboration, and data basics.', 'upcoming', 3, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Productivity Tools', 0) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Spreadsheets & Data', 'upcoming', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Document Collaboration', 'upcoming', 1);

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Online Collaboration', 1) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Virtual Meetings', 'upcoming', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Project Management Tools', 'upcoming', 1);

  -- 5. HR Fundamentals
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('HR Fundamentals', 'Foundational HR knowledge including recruitment, performance management, and labor law compliance.', 'completed', 4, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Recruitment & Onboarding', 0) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Job Analysis & Descriptions', 'completed', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Writing Effective JD''s', 'completed', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Interviewing Techniques', 'completed', 1);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Behavioral Interviewing', 'completed', 0);
  INSERT INTO program_topics (lesson_id, title, status, sort_order) VALUES (lesson_id, 'Legal Compliance in Interviews', 'completed', 1);

  INSERT INTO program_sections (program_id, title, sort_order) VALUES (prog_id, 'Performance Management', 1) RETURNING id INTO section_id;
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Setting KPIs & OKRs', 'completed', 0);
  INSERT INTO program_lessons (section_id, title, status, sort_order) VALUES (section_id, 'Performance Reviews', 'completed', 1);

  RAISE NOTICE 'Seed completed: 5 programs inserted.';
END $$;
