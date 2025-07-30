# Backend Setup Guide for Breez+ Platform

This guide will help you set up the complete backend system for the Breez+ academic resource sharing platform using Supabase.

## Prerequisites

- Supabase account and project created
- Database credentials added to `.env` file
- Basic understanding of SQL and Supabase

## Step 1: Database Schema Setup

1. **Open your Supabase project dashboard**
2. **Navigate to SQL Editor**
3. **Copy and paste the entire content from `database_schema.sql`**
4. **Execute the SQL script**

This will create:
- All necessary tables with proper relationships
- Row Level Security (RLS) policies
- Triggers for automatic data handling
- Functions for coin transactions and achievements
- Indexes for optimal performance
- Sample data for categories and achievements

## Step 2: Configure Authentication

### Email Domain Restriction
Since we're restricting signups to `@eastdelta.edu.bd` emails, you have two options:

#### Option A: Client-side validation only (Current Implementation)
- The validation is handled in the app
- Users can still potentially bypass this on the client side

#### Option B: Server-side validation (Recommended for Production)
Add this SQL function to enforce email domain restriction:

```sql
-- Function to validate email domain during signup
CREATE OR REPLACE FUNCTION public.validate_email_domain()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.email NOT LIKE '%@eastdelta.edu.bd' THEN
        RAISE EXCEPTION 'Only East Delta University email addresses are allowed';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to validate email on user creation
CREATE TRIGGER validate_email_domain_trigger
    BEFORE INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.validate_email_domain();
```

### Authentication Settings
1. Go to **Authentication > Settings** in Supabase
2. Configure:
   - **Site URL**: Your app's URL scheme
   - **Redirect URLs**: Add your app's redirect URLs
   - **Email confirmation**: Enable if you want email verification

## Step 3: Storage Setup (For File Uploads)

1. **Navigate to Storage in Supabase**
2. **Create a new bucket called `resources`**
3. **Set up storage policies**:

```sql
-- Allow authenticated users to upload files
CREATE POLICY "Authenticated users can upload files" ON storage.objects
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- Allow users to view approved resource files
CREATE POLICY "Users can view resource files" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'resources' AND 
        EXISTS (
            SELECT 1 FROM resources 
            WHERE file_url = storage.objects.name 
            AND is_approved = true 
            AND is_active = true
        )
    );

-- Allow users to update their own uploaded files
CREATE POLICY "Users can update own files" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'resources' AND 
        EXISTS (
            SELECT 1 FROM resources 
            WHERE file_url = storage.objects.name 
            AND uploader_id = auth.uid()
        )
    );
```

## Step 4: Test the Setup

### Test User Registration
1. Try signing up with a valid `@eastdelta.edu.bd` email
2. Check if the user profile is created automatically
3. Verify that default settings are created

### Test Database Functions
Run these queries to verify everything is working:

```sql
-- Check if user profiles are created
SELECT * FROM user_profiles;

-- Check if categories are populated
SELECT * FROM categories;

-- Check if achievements are created
SELECT * FROM achievements;

-- Test leaderboard view
SELECT * FROM leaderboard LIMIT 10;
```

## Step 5: Environment Variables

Make sure your `.env` file contains:

```env
EXPO_PUBLIC_SUPABASE_URL=your_supabase_project_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Step 6: API Functions (Optional)

For more complex operations, you can create Edge Functions in Supabase:

### Example: File Upload Processing
```typescript
// supabase/functions/process-upload/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { title, description, categoryId, fileType, uploaderId } = await req.json()
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Process file upload and create resource record
  const { data, error } = await supabase
    .from('resources')
    .insert({
      title,
      description,
      category_id: categoryId,
      file_type: fileType,
      uploader_id: uploaderId,
      coin_price: calculateCoinPrice(fileType), // Custom logic
      is_approved: false // Requires admin approval
    })
  
  return new Response(JSON.stringify({ data, error }), {
    headers: { "Content-Type": "application/json" },
  })
})
```

## Step 7: Admin Panel (Optional)

Create admin functions for content moderation:

```sql
-- Function to approve resources (Admin only)
CREATE OR REPLACE FUNCTION approve_resource(resource_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE resources 
    SET is_approved = true, updated_at = NOW()
    WHERE id = resource_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get pending resources for approval
CREATE OR REPLACE FUNCTION get_pending_resources()
RETURNS TABLE (
    id UUID,
    title TEXT,
    description TEXT,
    uploader_name TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.id,
        r.title,
        r.description,
        up.full_name,
        r.created_at
    FROM resources r
    JOIN user_profiles up ON r.uploader_id = up.id
    WHERE r.is_approved = false AND r.is_active = true
    ORDER BY r.created_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

## Step 8: Testing Checklist

- [ ] User can sign up with EDU email
- [ ] User profile is created automatically
- [ ] User can sign in after email verification
- [ ] Categories are loaded properly
- [ ] File upload simulation works
- [ ] Coin transactions are recorded
- [ ] Leaderboard displays correctly
- [ ] Achievements are awarded automatically
- [ ] Settings can be updated
- [ ] RLS policies prevent unauthorized access

## Troubleshooting

### Common Issues

1. **"relation does not exist" error**
   - Make sure you've run the complete schema script
   - Check if all tables are created in the public schema

2. **RLS policy errors**
   - Verify that RLS is enabled on tables
   - Check if policies are created correctly
   - Ensure user is authenticated

3. **Trigger not firing**
   - Check if triggers are created
   - Verify function syntax
   - Look at Supabase logs for errors

4. **Authentication issues**
   - Verify environment variables
   - Check Supabase project settings
   - Ensure email domain validation is working

### Useful SQL Queries for Debugging

```sql
-- Check user profiles
SELECT * FROM user_profiles WHERE email LIKE '%@eastdelta.edu.bd';

-- Check recent transactions
SELECT * FROM coin_transactions ORDER BY created_at DESC LIMIT 10;

-- Check user achievements
SELECT 
    up.full_name,
    a.name as achievement_name,
    ua.earned_at
FROM user_achievements ua
JOIN user_profiles up ON ua.user_id = up.id
JOIN achievements a ON ua.achievement_id = a.id
ORDER BY ua.earned_at DESC;

-- Check resource statistics
SELECT 
    c.name as category,
    COUNT(r.id) as resource_count,
    AVG(r.download_count) as avg_downloads
FROM resources r
JOIN categories c ON r.category_id = c.id
WHERE r.is_approved = true
GROUP BY c.name;
```

## Next Steps

1. **Implement file upload functionality** using Supabase Storage
2. **Add real-time features** using Supabase Realtime
3. **Create admin dashboard** for content moderation
4. **Add push notifications** using Supabase Edge Functions
5. **Implement advanced search** with full-text search
6. **Add analytics and reporting** features

## Security Best Practices

1. **Never expose service role key** in client-side code
2. **Use RLS policies** for all data access
3. **Validate all inputs** on both client and server side
4. **Implement rate limiting** for API calls
5. **Regular security audits** of database policies
6. **Monitor for suspicious activities**

Your Breez+ platform is now ready with a robust backend system!