-- Seed data for curriculum (5 programs, 2-4 topics each)
-- Requires an existing auth user + user_roles entry; uses the first admin found

DO $$
DECLARE
  admin_id UUID;
  prog_id UUID;
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

  INSERT INTO program_topics (program_id, title, status, sort_order) VALUES
    (prog_id, 'Project vs Operations', 'completed', 0),
    (prog_id, 'Triple Constraint', 'completed', 1),
    (prog_id, 'Initiation Phase', 'ongoing', 2),
    (prog_id, 'Planning Phase', 'upcoming', 3),
    (prog_id, 'Execution & Closure', 'upcoming', 4),
    (prog_id, 'Creating a WBS', 'upcoming', 5),
    (prog_id, 'WBS Dictionary', 'upcoming', 6);

  -- 2. Safety Training Program
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Workplace Safety Training', 'OSHA-aligned safety training covering hazard identification, PPE, and emergency response.', 'ongoing', 1, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_topics (program_id, title, status, sort_order) VALUES
    (prog_id, 'Physical Hazards', 'completed', 0),
    (prog_id, 'Chemical Hazards', 'completed', 1),
    (prog_id, 'Ergonomic Risks', 'completed', 2),
    (prog_id, 'Fire Safety & Evacuation', 'ongoing', 3),
    (prog_id, 'First Aid Fundamentals', 'upcoming', 4);

  -- 3. Leadership Excellence
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Leadership Excellence', 'Develop leadership skills including communication, delegation, and team motivation.', 'upcoming', 2, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_topics (program_id, title, status, sort_order) VALUES
    (prog_id, 'Communication Mastery', 'upcoming', 0),
    (prog_id, 'Delegation & Empowerment', 'upcoming', 1),
    (prog_id, 'Building Trust', 'upcoming', 2),
    (prog_id, 'Conflict Resolution', 'upcoming', 3),
    (prog_id, 'Mediation Techniques', 'upcoming', 4),
    (prog_id, 'Giving Constructive Feedback', 'upcoming', 5);

  -- 4. Digital Literacy
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('Digital Literacy for Professionals', 'Essential digital skills including productivity tools, online collaboration, and data basics.', 'upcoming', 3, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_topics (program_id, title, status, sort_order) VALUES
    (prog_id, 'Spreadsheets & Data', 'upcoming', 0),
    (prog_id, 'Document Collaboration', 'upcoming', 1),
    (prog_id, 'Virtual Meetings', 'upcoming', 2),
    (prog_id, 'Project Management Tools', 'upcoming', 3);

  -- 5. HR Fundamentals
  INSERT INTO programs (title, description, status, order_index, created_by) VALUES
    ('HR Fundamentals', 'Foundational HR knowledge including recruitment, performance management, and labor law compliance.', 'completed', 4, admin_id)
  RETURNING id INTO prog_id;

  INSERT INTO program_topics (program_id, title, status, sort_order) VALUES
    (prog_id, 'Writing Effective JDs', 'completed', 0),
    (prog_id, 'Behavioral Interviewing', 'completed', 1),
    (prog_id, 'Legal Compliance in Interviews', 'completed', 2),
    (prog_id, 'Setting KPIs & OKRs', 'completed', 3),
    (prog_id, 'Performance Reviews', 'completed', 4);

  RAISE NOTICE 'Seed completed: 5 programs inserted.';
END $$;
