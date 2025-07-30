/*
  # Breez+ Analytics Views and Helper Functions
  
  This file creates database views and functions for analytics,
  leaderboards, and reporting functionality.
*/

-- =============================================
-- LEADERBOARD VIEWS
-- =============================================

-- Top contributors by coins earned
CREATE OR REPLACE VIEW leaderboard_coins_earned AS
SELECT 
  p.id,
  p.full_name,
  p.university_id,
  p.coins_earned,
  p.uploaded_files,
  p.downloaded_files,
  p.created_at,
  ROW_NUMBER() OVER (ORDER BY p.coins_earned DESC, p.created_at ASC) as rank
FROM profiles p
WHERE p.show_stats = true
  AND p.profile_visible = true
ORDER BY p.coins_earned DESC, p.created_at ASC;

-- Top contributors by upload count
CREATE OR REPLACE VIEW leaderboard_uploads AS
SELECT 
  p.id,
  p.full_name,
  p.university_id,
  p.uploaded_files,
  p.coins_earned,
  p.created_at,
  ROW_NUMBER() OVER (ORDER BY p.uploaded_files DESC, p.coins_earned DESC, p.created_at ASC) as rank
FROM profiles p
WHERE p.show_stats = true
  AND p.profile_visible = true
ORDER BY p.uploaded_files DESC, p.coins_earned DESC, p.created_at ASC;

-- Most downloaded resources
CREATE OR REPLACE VIEW popular_resources AS
SELECT 
  r.id,
  r.title,
  r.description,
  r.download_count,
  r.coin_cost,
  r.created_at,
  c.name as category_name,
  c.color as category_color,
  p.full_name as uploader_name,
  p.university_id as uploader_id
FROM resources r
JOIN categories c ON r.category_id = c.id
JOIN profiles p ON r.uploader_id = p.id
WHERE r.status = 'approved'
ORDER BY r.download_count DESC, r.created_at DESC;

-- =============================================
-- ANALYTICS VIEWS
-- =============================================

-- Daily resource upload statistics
CREATE OR REPLACE VIEW daily_upload_stats AS
SELECT 
  DATE(created_at) as upload_date,
  COUNT(*) as total_uploads,
  COUNT(CASE WHEN status = 'approved' THEN 1 END) as approved_uploads,
  COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_uploads,
  COUNT(CASE WHEN status = 'rejected' THEN 1 END) as rejected_uploads
FROM resources
GROUP BY DATE(created_at)
ORDER BY upload_date DESC;

-- Daily download statistics
CREATE OR REPLACE VIEW daily_download_stats AS
SELECT 
  DATE(downloaded_at) as download_date,
  COUNT(*) as total_downloads,
  SUM(coins_spent) as total_coins_spent,
  AVG(coins_spent) as avg_coins_per_download
FROM downloads
GROUP BY DATE(downloaded_at)
ORDER BY download_date DESC;

-- Category popularity statistics
CREATE OR REPLACE VIEW category_stats AS
SELECT 
  c.id,
  c.name,
  c.color,
  COUNT(r.id) as total_resources,
  COUNT(CASE WHEN r.status = 'approved' THEN 1 END) as approved_resources,
  COALESCE(SUM(r.download_count), 0) as total_downloads,
  COALESCE(AVG(r.download_count), 0) as avg_downloads_per_resource
FROM categories c
LEFT JOIN resources r ON c.id = r.category_id
WHERE c.is_active = true
GROUP BY c.id, c.name, c.color
ORDER BY total_downloads DESC;

-- User activity summary
CREATE OR REPLACE VIEW user_activity_summary AS
SELECT 
  p.id,
  p.full_name,
  p.university_id,
  p.total_coins,
  p.coins_earned,
  p.coins_spent,
  p.uploaded_files,
  p.downloaded_files,
  p.created_at as joined_date,
  p.last_active,
  COUNT(ua.id) as total_achievements,
  COALESCE(recent_uploads.count, 0) as uploads_last_30_days,
  COALESCE(recent_downloads.count, 0) as downloads_last_30_days
FROM profiles p
LEFT JOIN user_achievements ua ON p.id = ua.user_id
LEFT JOIN (
  SELECT uploader_id, COUNT(*) as count
  FROM resources
  WHERE created_at >= NOW() - INTERVAL '30 days'
  GROUP BY uploader_id
) recent_uploads ON p.id = recent_uploads.uploader_id
LEFT JOIN (
  SELECT downloader_id, COUNT(*) as count
  FROM downloads
  WHERE downloaded_at >= NOW() - INTERVAL '30 days'
  GROUP BY downloader_id
) recent_downloads ON p.id = recent_downloads.downloader_id
GROUP BY p.id, p.full_name, p.university_id, p.total_coins, p.coins_earned, 
         p.coins_spent, p.uploaded_files, p.downloaded_files, p.created_at, 
         p.last_active, recent_uploads.count, recent_downloads.count;

-- =============================================
-- HELPER FUNCTIONS
-- =============================================

-- Function to get user's leaderboard position
CREATE OR REPLACE FUNCTION get_user_leaderboard_position(user_id uuid)
RETURNS TABLE(
  coins_earned_rank integer,
  uploads_rank integer,
  total_users integer
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    (SELECT rank::integer FROM leaderboard_coins_earned WHERE id = user_id),
    (SELECT rank::integer FROM leaderboard_uploads WHERE id = user_id),
    (SELECT COUNT(*)::integer FROM profiles WHERE show_stats = true AND profile_visible = true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to search resources with full-text search
CREATE OR REPLACE FUNCTION search_resources(
  search_query text,
  category_filter uuid DEFAULT NULL,
  limit_count integer DEFAULT 20,
  offset_count integer DEFAULT 0
)
RETURNS TABLE(
  id uuid,
  title text,
  description text,
  category_name text,
  category_color text,
  uploader_name text,
  coin_cost integer,
  download_count integer,
  created_at timestamptz,
  rank real
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    r.id,
    r.title,
    r.description,
    c.name as category_name,
    c.color as category_color,
    p.full_name as uploader_name,
    r.coin_cost,
    r.download_count,
    r.created_at,
    ts_rank(
      to_tsvector('english', r.title || ' ' || r.description || ' ' || array_to_string(r.tags, ' ')),
      plainto_tsquery('english', search_query)
    ) as rank
  FROM resources r
  JOIN categories c ON r.category_id = c.id
  JOIN profiles p ON r.uploader_id = p.id
  WHERE r.status = 'approved'
    AND (category_filter IS NULL OR r.category_id = category_filter)
    AND (
      search_query = '' OR
      to_tsvector('english', r.title || ' ' || r.description || ' ' || array_to_string(r.tags, ' ')) 
      @@ plainto_tsquery('english', search_query)
    )
  ORDER BY 
    CASE WHEN search_query = '' THEN 0 ELSE rank END DESC,
    r.download_count DESC,
    r.created_at DESC
  LIMIT limit_count
  OFFSET offset_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get user's recent activity
CREATE OR REPLACE FUNCTION get_user_recent_activity(
  user_id uuid,
  limit_count integer DEFAULT 10
)
RETURNS TABLE(
  activity_type text,
  title text,
  description text,
  coins_change integer,
  created_at timestamptz,
  data jsonb
) AS $$
BEGIN
  RETURN QUERY
  (
    -- Recent uploads
    SELECT 
      'upload'::text as activity_type,
      r.title,
      'Uploaded resource'::text as description,
      r.coin_cost as coins_change,
      r.created_at,
      jsonb_build_object('resource_id', r.id, 'status', r.status) as data
    FROM resources r
    WHERE r.uploader_id = user_id
    ORDER BY r.created_at DESC
    LIMIT limit_count
  )
  UNION ALL
  (
    -- Recent downloads
    SELECT 
      'download'::text as activity_type,
      r.title,
      'Downloaded resource'::text as description,
      -d.coins_spent as coins_change,
      d.downloaded_at as created_at,
      jsonb_build_object('resource_id', r.id, 'download_id', d.id) as data
    FROM downloads d
    JOIN resources r ON d.resource_id = r.id
    WHERE d.downloader_id = user_id
    ORDER BY d.downloaded_at DESC
    LIMIT limit_count
  )
  UNION ALL
  (
    -- Recent achievements
    SELECT 
      'achievement'::text as activity_type,
      a.name as title,
      'Earned achievement'::text as description,
      a.coin_reward as coins_change,
      ua.earned_at as created_at,
      jsonb_build_object('achievement_id', a.id) as data
    FROM user_achievements ua
    JOIN achievements a ON ua.achievement_id = a.id
    WHERE ua.user_id = user_id
    ORDER BY ua.earned_at DESC
    LIMIT limit_count
  )
  ORDER BY created_at DESC
  LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;