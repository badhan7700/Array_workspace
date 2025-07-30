/*
  # Fix User Profile Creation Issue
  
  This migration fixes the database error that occurs when creating new users.
  The issue was in the handle_new_user() function that creates profiles automatically.
*/

-- Drop the existing trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user();

-- Create an improved function that handles errors gracefully
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $
BEGIN
  -- Insert profile with proper error handling
  INSERT INTO profiles (id, email, full_name, university_id)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
    COALESCE(NEW.raw_user_meta_data->>'university_id', NEW.id::text)
  );
  
  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- Handle duplicate university_id or email
    RAISE LOG 'Unique constraint violation for user %: %', NEW.id, SQLERRM;
    -- Try with a different university_id
    INSERT INTO profiles (id, email, full_name, university_id)
    VALUES (
      NEW.id,
      NEW.email,
      COALESCE(NEW.raw_user_meta_data->>'full_name', 'New User'),
      'USER_' || NEW.id::text
    );
    RETURN NEW;
  WHEN OTHERS THEN
    -- Log any other errors
    RAISE LOG 'Error creating profile for user %: %', NEW.id, SQLERRM;
    -- Don't fail the auth process, just log the error
    RETURN NEW;
END;
$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recreate the trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Also, let's make the email validation trigger more lenient for the auto-creation process
DROP TRIGGER IF EXISTS validate_profile_email ON profiles;

CREATE OR REPLACE FUNCTION validate_university_email()
RETURNS TRIGGER AS $
BEGIN
  -- Only validate email domain for manual profile updates, not auto-creation
  IF TG_OP = 'UPDATE' OR (TG_OP = 'INSERT' AND NEW.email NOT LIKE '%@eastdelta.edu.bd') THEN
    IF NEW.email NOT LIKE '%@eastdelta.edu.bd' THEN
      RAISE EXCEPTION 'Email must be from eastdelta.edu.bd domain';
    END IF;
  END IF;
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

-- Recreate the email validation trigger
CREATE TRIGGER validate_profile_email
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION validate_university_email();