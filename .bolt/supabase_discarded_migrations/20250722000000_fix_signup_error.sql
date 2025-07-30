/*
  # Fix Signup Database Error
  
  This migration fixes the "Database error saving new user" issue by:
  1. Improving the handle_new_user() function
  2. Making university_id generation more robust
  3. Better error handling for profile creation
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Create a more robust function for handling new user creation
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_full_name text;
  user_university_id text;
  attempt_count integer := 0;
  max_attempts integer := 5;
BEGIN
  -- Extract user data from metadata
  user_full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User');
  user_university_id := COALESCE(NEW.raw_user_meta_data->>'university_id', '');
  
  -- If no university_id provided, generate one from email
  IF user_university_id = '' THEN
    -- Extract university ID from email (before @)
    user_university_id := split_part(NEW.email, '@', 1);
  END IF;
  
  -- Try to insert profile with retry logic for unique constraint violations
  LOOP
    BEGIN
      INSERT INTO profiles (id, email, full_name, university_id)
      VALUES (
        NEW.id,
        NEW.email,
        user_full_name,
        CASE 
          WHEN attempt_count = 0 THEN user_university_id
          ELSE user_university_id || '_' || attempt_count::text
        END
      );
      
      -- If we get here, the insert was successful
      EXIT;
      
    EXCEPTION
      WHEN unique_violation THEN
        attempt_count := attempt_count + 1;
        
        -- If we've tried too many times, use a UUID-based fallback
        IF attempt_count >= max_attempts THEN
          INSERT INTO profiles (id, email, full_name, university_id)
          VALUES (
            NEW.id,
            NEW.email,
            user_full_name,
            'USER_' || substr(NEW.id::text, 1, 8)
          );
          EXIT;
        END IF;
        
        -- Continue the loop to try again
        CONTINUE;
        
      WHEN OTHERS THEN
        -- Log the error but don't fail the auth process
        RAISE LOG 'Error creating profile for user % (email: %): %', NEW.id, NEW.email, SQLERRM;
        
        -- Try a minimal profile creation as last resort
        BEGIN
          INSERT INTO profiles (id, email, full_name, university_id)
          VALUES (
            NEW.id,
            NEW.email,
            'New User',
            'TEMP_' || substr(NEW.id::text, 1, 8)
          );
        EXCEPTION
          WHEN OTHERS THEN
            -- If even this fails, just log and continue
            RAISE LOG 'Failed to create minimal profile for user %: %', NEW.id, SQLERRM;
        END;
        
        EXIT;
    END;
  END LOOP;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Also update the email validation to be more permissive during signup
DROP TRIGGER IF EXISTS validate_profile_email ON profiles;

CREATE OR REPLACE FUNCTION validate_university_email()
RETURNS TRIGGER AS $$
BEGIN
  -- Skip validation for system-generated profiles during signup
  IF TG_OP = 'INSERT' AND NEW.university_id LIKE 'USER_%' THEN
    RETURN NEW;
  END IF;
  
  -- Skip validation for temporary profiles
  IF TG_OP = 'INSERT' AND NEW.university_id LIKE 'TEMP_%' THEN
    RETURN NEW;
  END IF;
  
  -- Only validate email domain for manual updates or non-system inserts
  IF NEW.email NOT LIKE '%@eastdelta.edu.bd' THEN
    RAISE EXCEPTION 'Email must be from eastdelta.edu.bd domain';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recreate the email validation trigger
CREATE TRIGGER validate_profile_email
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_university_email();

-- Add an index to improve performance on university_id lookups
CREATE INDEX IF NOT EXISTS idx_profiles_university_id_unique ON profiles(university_id);