/*
  # Breez+ Initial Data Seeding
  
  This file contains initial data for categories, achievements,
  and other reference data needed for the application to function.
*/

-- =============================================
-- SEED CATEGORIES
-- =============================================

INSERT INTO categories (name, description, icon, color) VALUES
('Mathematics', 'Mathematical concepts, formulas, and problem-solving resources', 'calculator', '#2563EB'),
('Physics', 'Physics principles, experiments, and theoretical concepts', 'atom', '#7C3AED'),
('Chemistry', 'Chemical reactions, molecular structures, and lab procedures', 'flask', '#059669'),
('Biology', 'Life sciences, anatomy, genetics, and biological processes', 'dna', '#DC2626'),
('Computer Science', 'Programming, algorithms, data structures, and software development', 'code', '#EA580C'),
('Engineering', 'Engineering principles, design, and technical specifications', 'cog', '#0891B2'),
('Literature', 'Literary analysis, writing techniques, and language studies', 'book', '#BE185D'),
('History', 'Historical events, timelines, and cultural studies', 'scroll', '#A16207'),
('Economics', 'Economic theories, market analysis, and financial concepts', 'trending-up', '#16A34A'),
('Psychology', 'Human behavior, cognitive processes, and psychological theories', 'brain', '#9333EA');

-- =============================================
-- SEED ACHIEVEMENTS
-- =============================================

INSERT INTO achievements (name, description, icon, color, condition_type, condition_value, coin_reward) VALUES
-- Upload-based achievements
('First Upload', 'Upload your first academic resource', 'upload', '#10B981', 'upload_count', 1, 10),
('Knowledge Sharer', 'Upload 5 academic resources', 'share', '#10B981', 'upload_count', 5, 25),
('Content Creator', 'Upload 10 academic resources', 'file-plus', '#10B981', 'upload_count', 10, 50),
('Academic Contributor', 'Upload 25 academic resources', 'award', '#10B981', 'upload_count', 25, 100),
('Resource Master', 'Upload 50 academic resources', 'crown', '#F59E0B', 'upload_count', 50, 200),

-- Download-based achievements
('First Download', 'Download your first academic resource', 'download', '#2563EB', 'download_count', 1, 5),
('Knowledge Seeker', 'Download 10 academic resources', 'search', '#2563EB', 'download_count', 10, 20),
('Study Enthusiast', 'Download 25 academic resources', 'book-open', '#2563EB', 'download_count', 25, 40),
('Learning Machine', 'Download 50 academic resources', 'graduation-cap', '#2563EB', 'download_count', 50, 75),
('Academic Explorer', 'Download 100 academic resources', 'compass', '#2563EB', 'download_count', 100, 150),

-- Coin-based achievements
('Coin Collector', 'Earn your first 50 coins', 'coins', '#F59E0B', 'coins_earned', 50, 10),
('Wealth Builder', 'Earn 100 coins through uploads', 'piggy-bank', '#F59E0B', 'coins_earned', 100, 25),
('Coin Master', 'Earn 500 coins through uploads', 'dollar-sign', '#F59E0B', 'coins_earned', 500, 100),
('Economic Powerhouse', 'Earn 1000 coins through uploads', 'trending-up', '#F59E0B', 'coins_earned', 1000, 200),

-- Balance-based achievements
('Saver', 'Maintain a balance of 100 coins', 'wallet', '#8B5CF6', 'total_coins', 100, 15),
('Investor', 'Maintain a balance of 250 coins', 'chart-line', '#8B5CF6', 'total_coins', 250, 35),
('Tycoon', 'Maintain a balance of 500 coins', 'gem', '#8B5CF6', 'total_coins', 500, 75);

-- =============================================
-- SEED SAMPLE ADMIN USER (for testing)
-- =============================================

-- Note: This would typically be done through Supabase Auth
-- This is just for reference - actual user creation happens through auth flow

-- INSERT INTO profiles (
--   id, 
--   email, 
--   full_name, 
--   university_id, 
--   role, 
--   total_coins
-- ) VALUES (
--   gen_random_uuid(),
--   'admin@eastdelta.edu.bd',
--   'System Administrator',
--   'ADMIN001',
--   'admin',
--   1000
-- );

-- =============================================
-- SAMPLE RESOURCES (for testing/demo)
-- =============================================

-- Note: These would be created through the app interface
-- This is just for reference of the data structure

-- INSERT INTO resources (
--   title,
--   description,
--   category_id,
--   uploader_id,
--   file_path,
--   file_name,
--   file_type,
--   file_size,
--   coin_cost,
--   status,
--   tags
-- ) VALUES (
--   'Calculus II Study Guide',
--   'Comprehensive study guide covering integration techniques, series, and applications',
--   (SELECT id FROM categories WHERE name = 'Mathematics'),
--   (SELECT id FROM profiles WHERE email = 'student@eastdelta.edu.bd' LIMIT 1),
--   'resources/calculus-ii-guide.pdf',
--   'calculus-ii-guide.pdf',
--   'application/pdf',
--   2048576,
--   5,
--   'approved',
--   ARRAY['calculus', 'integration', 'mathematics', 'study-guide']
-- );