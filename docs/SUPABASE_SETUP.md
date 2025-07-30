# Supabase Setup Guide

This guide will help you set up Supabase authentication for your React Native/Expo application.

## Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com))
- Node.js and npm/yarn installed
- Expo CLI installed

## Step 1: Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Choose your organization
4. Fill in your project details:
   - Name: Your app name
   - Database Password: Choose a strong password
   - Region: Choose the closest region to your users
5. Click "Create new project"

## Step 2: Get Your Project Credentials

1. In your Supabase dashboard, go to Settings > API
2. Copy the following values:
   - Project URL
   - Project API Key (anon, public)

## Step 3: Configure Environment Variables

1. Create a `.env` file in your project root (copy from `.env.example`)
2. Add your Supabase credentials:

```env
EXPO_PUBLIC_SUPABASE_URL=your_supabase_project_url
EXPO_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Step 4: Configure Authentication

1. In your Supabase dashboard, go to Authentication > Settings
2. Configure the following settings:

### Site URL
Set your site URL to your app's URL scheme:
- For development: `exp://localhost:19000`
- For production: Your app's custom URL scheme

### Additional Redirect URLs
Add any additional URLs where users might be redirected after authentication.

### Email Templates (Optional)
Customize the email templates for:
- Confirm signup
- Reset password
- Magic link

## Step 5: Set Up Authentication Policies (Optional)

If you plan to use Row Level Security (RLS), you can set up policies in the SQL Editor:

```sql
-- Enable RLS on your tables
ALTER TABLE your_table_name ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own data" ON your_table_name
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own data" ON your_table_name
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own data" ON your_table_name
  FOR UPDATE USING (auth.uid() = user_id);
```

## Step 6: Test Your Setup

1. Start your Expo development server:
   ```bash
   npm run dev
   ```

2. Try signing up with a new account
3. Check your Supabase dashboard under Authentication > Users to see if the user was created

## Troubleshooting

### Common Issues

1. **"Invalid API key" error**
   - Double-check your `EXPO_PUBLIC_SUPABASE_ANON_KEY` in the `.env` file
   - Make sure you're using the anon/public key, not the service role key

2. **"Invalid URL" error**
   - Verify your `EXPO_PUBLIC_SUPABASE_URL` is correct
   - Make sure it includes `https://` and ends with `.supabase.co`

3. **Email confirmation not working**
   - Check your Site URL settings in Supabase
   - Verify your redirect URLs are configured correctly

4. **Users not appearing in dashboard**
   - Check the Authentication > Users section in Supabase
   - Look for any error messages in the browser console

### Getting Help

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Discord Community](https://discord.supabase.com)
- [Expo Documentation](https://docs.expo.dev)

## Security Best Practices

1. **Never commit your `.env` file** - Add it to `.gitignore`
2. **Use Row Level Security** for database access control
3. **Validate user input** on both client and server side
4. **Use HTTPS** in production
5. **Regularly rotate your API keys** if compromised

## Next Steps

Once authentication is working, you can:

1. Set up user profiles and additional user data
2. Implement role-based access control
3. Add social authentication providers
4. Set up email templates and branding
5. Configure webhooks for user events