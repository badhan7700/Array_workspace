/*
  # Breez+ Database Functions and Triggers
  
  This file contains PostgreSQL functions and triggers that automate
  business logic for the Breez+ academic resource sharing platform.
*/

-- =============================================
-- UTILITY FUNCTIONS
-- =============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to validate university email domain
CREATE OR REPLACE FUNCTION validate_university_email()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.email NOT LIKE '%@eastdelta.edu.bd' THEN
    RAISE EXCEPTION 'Email must be from eastdelta.edu.bd domain';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================
-- COIN MANAGEMENT FUNCTIONS
-- =============================================

-- Function to transfer coins between users
CREATE OR REPLACE FUNCTION transfer_coins(
  from_user_id uuid,
  to_user_id uuid,
  amount integer,
  description text,
  reference_id uuid DEFAULT NULL,
  reference_type text DEFAULT NULL
)
RETURNS boolean AS $$
DECLARE
  from_user_coins integer;
BEGIN
  -- Check if sender has enough coins
  SELECT total_coins INTO from_user_coins
  FROM profiles
  WHERE id = from_user_id;
  
  IF from_user_coins < amount THEN
    RAISE EXCEPTION 'Insufficient coins. Available: %, Required: %', from_user_coins, amount;
  END IF;
  
  -- Deduct coins from sender
  UPDATE profiles
  SET total_coins = total_coins - amount,
      coins_spent = coins_spent + amount,
      updated_at = now()
  WHERE id = from_user_id;
  
  -- Add coins to receiver
  UPDATE profiles
  SET total_coins = total_coins + amount,
      coins_earned = coins_earned + amount,
      updated_at = now()
  WHERE id = to_user_id;
  
  -- Record transactions
  INSERT INTO transactions (user_id, type, amount, description, reference_id, reference_type)
  VALUES 
    (from_user_id, 'spent', amount, description, reference_id, reference_type),
    (to_user_id, 'earned', amount, description, reference_id, reference_type);
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to award coins to user
CREATE OR REPLACE FUNCTION award_coins(
  user_id uuid,
  amount integer,
  description text,
  reference_id uuid DEFAULT NULL,
  reference_type text DEFAULT NULL
)
RETURNS boolean AS $$
BEGIN
  -- Add coins to user
  UPDATE profiles
  SET total_coins = total_coins + amount,
      coins_earned = coins_earned + amount,
      updated_at = now()
  WHERE id = user_id;
  
  -- Record transaction
  INSERT INTO transactions (user_id, type, amount, description, reference_id, reference_type)
  VALUES (user_id, 'earned', amount, description, reference_id, reference_type);
  
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- RESOURCE MANAGEMENT FUNCTIONS
-- =============================================

-- Function to handle resource download
CREATE OR REPLACE FUNCTION download_resource(
  resource_id uuid,
  downloader_id uuid
)
RETURNS jsonb AS $$
DECLARE
  resource_record resources%ROWTYPE;
  downloader_coins integer;
  download_id uuid;
BEGIN
  -- Get resource details
  SELECT * INTO resource_record
  FROM resources
  WHERE id = resource_id AND status = 'approved';
  
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Resource not found or not approved';
  END IF;
  
  -- Check if user already downloaded this resource
  IF EXISTS (SELECT 1 FROM downloads WHERE resource_id = resource_id AND downloader_id = downloader_id) THEN
    RAISE EXCEPTION 'Resource already downloaded by this user';
  END IF;
  
  -- Check if user has enough coins
  SELECT total_coins INTO downloader_coins
  FROM profiles
  WHERE id = downloader_id;
  
  IF downloader_coins < resource_record.coin_cost THEN
    RAISE EXCEPTION 'Insufficient coins. Available: %, Required: %', downloader_coins, resource_record.coin_cost;
  END IF;
  
  -- Transfer coins from downloader to uploader
  PERFORM transfer_coins(
    downloader_id,
    resource_record.uploader_id,
    resource_record.coin_cost,
    'Downloaded: ' || resource_record.title,
    resource_id,
    'download'
  );
  
  -- Record the download
  INSERT INTO downloads (resource_id, downloader_id, coins_spent)
  VALUES (resource_id, downloader_id, resource_record.coin_cost)
  RETURNING id INTO download_id;
  
  -- Update resource download count
  UPDATE resources
  SET download_count = download_count + 1,
      updated_at = now()
  WHERE id = resource_id;
  
  -- Update user download count
  UPDATE profiles
  SET downloaded_files = downloaded_files + 1,
      updated_at = now()
  WHERE id = downloader_id;
  
  -- Create notifications
  INSERT INTO notifications (user_id, type, title, message, data)
  VALUES 
    (downloader_id, 'download', 'Download Successful', 
     'You successfully downloaded: ' || resource_record.title,
     jsonb_build_object('resource_id', resource_id, 'download_id', download_id)),
    (resource_record.uploader_id, 'download', 'Resource Downloaded',
     'Your resource "' || resource_record.title || '" was downloaded',
     jsonb_build_object('resource_id', resource_id, 'download_id', download_id));
  
  -- Check for achievements
  PERFORM check_user_achievements(downloader_id);
  PERFORM check_user_achievements(resource_record.uploader_id);
  
  RETURN jsonb_build_object(
    'success', true,
    'download_id', download_id,
    'coins_spent', resource_record.coin_cost
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- ACHIEVEMENT SYSTEM FUNCTIONS
-- =============================================

-- Function to check and award achievements
CREATE OR REPLACE FUNCTION check_user_achievements(user_id uuid)
RETURNS integer AS $$
DECLARE
  achievement_record achievements%ROWTYPE;
  user_stats record;
  achievements_awarded integer := 0;
BEGIN
  -- Get user statistics
  SELECT 
    total_coins,
    coins_earned,
    uploaded_files,
    downloaded_files
  INTO user_stats
  FROM profiles
  WHERE id = user_id;
  
  -- Check each achievement
  FOR achievement_record IN 
    SELECT * FROM achievements 
    WHERE is_active = true 
    AND id NOT IN (
      SELECT achievement_id 
      FROM user_achievements 
      WHERE user_achievements.user_id = check_user_achievements.user_id
    )
  LOOP
    DECLARE
      condition_met boolean := false;
    BEGIN
      -- Check achievement conditions
      CASE achievement_record.condition_type
        WHEN 'upload_count' THEN
          condition_met := user_stats.uploaded_files >= achievement_record.condition_value;
        WHEN 'download_count' THEN
          condition_met := user_stats.downloaded_files >= achievement_record.condition_value;
        WHEN 'coins_earned' THEN
          condition_met := user_stats.coins_earned >= achievement_record.condition_value;
        WHEN 'total_coins' THEN
          condition_met := user_stats.total_coins >= achievement_record.condition_value;
        ELSE
          condition_met := false;
      END CASE;
      
      -- Award achievement if condition is met
      IF condition_met THEN
        -- Record achievement
        INSERT INTO user_achievements (user_id, achievement_id)
        VALUES (user_id, achievement_record.id);
        
        -- Award coins if applicable
        IF achievement_record.coin_reward > 0 THEN
          PERFORM award_coins(
            user_id,
            achievement_record.coin_reward,
            'Achievement reward: ' || achievement_record.name,
            achievement_record.id,
            'achievement'
          );
        END IF;
        
        -- Create notification
        INSERT INTO notifications (user_id, type, title, message, data)
        VALUES (
          user_id,
          'achievement',
          'Achievement Unlocked!',
          'You earned the "' || achievement_record.name || '" achievement!',
          jsonb_build_object(
            'achievement_id', achievement_record.id,
            'coin_reward', achievement_record.coin_reward
          )
        );
        
        achievements_awarded := achievements_awarded + 1;
      END IF;
    END;
  END LOOP;
  
  RETURN achievements_awarded;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- TRIGGERS
-- =============================================

-- Update timestamps
CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_resources_updated_at
  BEFORE UPDATE ON resources
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Validate university email on profile creation/update
CREATE TRIGGER validate_profile_email
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_university_email();

-- Auto-update user stats when resource is approved
CREATE OR REPLACE FUNCTION update_user_upload_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- If resource status changed to approved
  IF OLD.status != 'approved' AND NEW.status = 'approved' THEN
    -- Update uploader's file count
    UPDATE profiles
    SET uploaded_files = uploaded_files + 1,
        updated_at = now()
    WHERE id = NEW.uploader_id;
    
    -- Award coins for upload
    PERFORM award_coins(
      NEW.uploader_id,
      NEW.coin_cost,
      'Resource approved: ' || NEW.title,
      NEW.id,
      'upload'
    );
    
    -- Create notification
    INSERT INTO notifications (user_id, type, title, message, data)
    VALUES (
      NEW.uploader_id,
      'upload_approved',
      'Resource Approved!',
      'Your resource "' || NEW.title || '" has been approved and is now available for download.',
      jsonb_build_object('resource_id', NEW.id, 'coins_earned', NEW.coin_cost)
    );
    
    -- Check for achievements
    PERFORM check_user_achievements(NEW.uploader_id);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER resource_approval_trigger
  AFTER UPDATE ON resources
  FOR EACH ROW
  EXECUTE FUNCTION update_user_upload_stats();

-- Auto-create profile when user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, university_id)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    COALESCE(NEW.raw_user_meta_data->>'university_id', 'TEMP_' || substr(NEW.id::text, 1, 8))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();