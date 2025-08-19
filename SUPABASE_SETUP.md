# 🔧 Supabase Setup Guide - Fix Signup Issues

## 🎯 **Current Issue Analysis**

Your signup is actually **working correctly**! The logs show:
```
Signup response: {data: {...}, error: null}
```

This means the user account is being created in Supabase. The issue is likely one of these:

## 🔍 **Potential Issues & Solutions**

### **Issue 1: Email Confirmation Required**
**Symptom**: User can't login immediately after signup
**Solution**: Disable email confirmation in Supabase

### **Issue 2: Database Triggers Not Working**
**Symptom**: User profile not created in database
**Solution**: Check and fix database triggers

### **Issue 3: User Not Redirected After Signup**
**Symptom**: Stays on signup screen after successful signup
**Solution**: Fix navigation flow

## ✅ **Step 1: Disable Email Confirmation (Recommended for Development)**

1. **Go to Supabase Dashboard**:
   - Visit: https://supabase.com/dashboard/project/cgbxudfgeqoydckpdxuk
   - Login to your account

2. **Navigate to Authentication Settings**:
   - Click **"Authentication"** in left sidebar
   - Click **"Settings"** tab
   - Scroll to **"User Signups"** section

3. **Disable Email Confirmation**:
   - Find **"Enable email confirmations"**
   - **Turn OFF** this toggle
   - Click **"Save"**

4. **Set Auto-confirm Users**:
   - Find **"Enable automatic confirmation"**
   - **Turn ON** this toggle
   - Click **"Save"**

## ✅ **Step 2: Check Database Schema is Applied**

1. **Go to SQL Editor**:
   - Click **"SQL Editor"** in left sidebar
   - Click **"New query"**

2. **Check if Tables Exist**:
   ```sql
   -- Check if user_profiles table exists
   SELECT * FROM user_profiles LIMIT 1;
   
   -- Check if categories table exists
   SELECT * FROM categories LIMIT 1;
   
   -- Check if triggers exist
   SELECT trigger_name, event_manipulation, event_object_table 
   FROM information_schema.triggers 
   WHERE trigger_schema = 'public';
   ```

3. **If Tables Don't Exist**:
   - Copy the entire content from `database_schema.sql`
   - Paste it in SQL Editor
   - Click **"Run"**

## ✅ **Step 3: Test Signup Flow**

After making the changes above:

1. **Try Signup Again**:
   - Use a new email address
   - Fill all fields correctly
   - Click "Sign Up"

2. **Expected Console Logs**:
   ```
   🔄 Starting signup process...
   Attempting signup with: {email: 'test@eastdelta.edu.bd', hasPassword: true, additionalData: {...}}
   Signup payload: {...}
   Signup response: {data: {...}, error: null}
   ✅ Signup successful!
   ```

3. **Expected Behavior**:
   - Success alert appears
   - Redirected to login screen
   - Can immediately login with new credentials

## ✅ **Step 4: Verify Database Records**

After successful signup, check if data is created:

1. **Check Auth Users**:
   ```sql
   SELECT id, email, email_confirmed_at, created_at 
   FROM auth.users 
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

2. **Check User Profiles**:
   ```sql
   SELECT id, email, full_name, student_id, semester, total_coins
   FROM user_profiles 
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

3. **Check User Settings**:
   ```sql
   SELECT user_id, push_notifications, profile_visible
   FROM user_settings 
   ORDER BY created_at DESC 
   LIMIT 5;
   ```

## 🚨 **Common Issues & Quick Fixes**

### **Issue: "User already registered" Error**
**Solution**: The email is already used. Try a different email or delete the existing user:
```sql
-- Delete user (be careful!)
DELETE FROM auth.users WHERE email = 'your-email@eastdelta.edu.bd';
```

### **Issue: Database Trigger Not Working**
**Solution**: Recreate the trigger:
```sql
-- Drop and recreate the trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### **Issue: Categories Not Found**
**Solution**: Insert default categories:
```sql
INSERT INTO categories (name, description, icon) VALUES
('Computer Science', 'Programming and software development', 'code'),
('Mathematics', 'Mathematical concepts and formulas', 'calculator'),
('Physics', 'Physics principles and experiments', 'atom'),
('Chemistry', 'Chemical reactions and lab reports', 'flask'),
('Biology', 'Life sciences and biological processes', 'dna')
ON CONFLICT (name) DO NOTHING;
```

## 🧪 **Testing Checklist**

- [ ] Email confirmation disabled in Supabase
- [ ] Database schema applied successfully
- [ ] Categories table has data
- [ ] User profile trigger exists
- [ ] Signup creates user in auth.users
- [ ] Signup creates profile in user_profiles
- [ ] Signup creates settings in user_settings
- [ ] User can login immediately after signup
- [ ] User is redirected to main app after login

## 🎯 **Expected Complete Flow**

1. **User fills signup form** → Form validation passes
2. **Clicks "Sign Up"** → API call to Supabase
3. **Supabase creates user** → Returns success response
4. **Database trigger fires** → Creates user_profile and user_settings
5. **Success alert shows** → "Account Created Successfully!"
6. **User clicks "Sign In Now"** → Redirected to login screen
7. **User enters credentials** → Can login immediately
8. **Login successful** → Redirected to main app tabs

## 🚀 **After Setup**

Your signup should work perfectly with:
- ✅ Immediate account creation
- ✅ No email verification required
- ✅ Automatic profile creation
- ✅ Instant login capability
- ✅ Proper navigation flow

The key is disabling email confirmation for development/demo purposes!