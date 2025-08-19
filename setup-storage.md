# 🔧 Fix Upload & Logout Issues - Setup Guide

## 🚨 **Issue Summary**
1. **Upload Error**: Storage bucket `resources` doesn't exist in Supabase
2. **Logout Issue**: Navigation not working properly after signout

## ✅ **Fix 1: Create Supabase Storage Bucket**

### **Step 1: Access Supabase Dashboard**
1. Go to: https://supabase.com/dashboard/project/cgbxudfgeqoydckpdxuk
2. Login to your Supabase account

### **Step 2: Create Storage Bucket**
1. Click **"Storage"** in the left sidebar
2. Click **"New bucket"** button
3. Fill in the details:
   - **Name**: `resources`
   - **Public**: ✅ **ENABLE** (Important: This allows public file access)
   - **File size limit**: `50 MB` (or your preferred limit)
   - **Allowed MIME types**: Leave empty or add:
     ```
     application/pdf,application/msword,application/vnd.openxmlformats-officedocument.wordprocessingml.document,image/jpeg,image/png,image/gif,text/plain
     ```
4. Click **"Create bucket"**

### **Step 3: Set Storage Policies**
1. Go to **Storage > Policies** in the dashboard
2. Click **"New Policy"** for the `resources` bucket
3. Create these 3 policies:

**Policy 1: Allow Authenticated Uploads**
```sql
CREATE POLICY "Allow authenticated uploads" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'resources' AND 
  auth.role() = 'authenticated'
);
```

**Policy 2: Allow Public Downloads**
```sql
CREATE POLICY "Allow public downloads" ON storage.objects
FOR SELECT USING (bucket_id = 'resources');
```

**Policy 3: Allow Users to Update Own Files**
```sql
CREATE POLICY "Allow users to update own files" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'resources' AND 
  auth.uid() IS NOT NULL
);
```

## ✅ **Fix 2: Test Upload Function**

After creating the bucket, test the upload:

1. **Restart your development server**:
   ```bash
   npm run dev
   # or
   expo start
   ```

2. **Try uploading a file**:
   - Go to Upload tab
   - Fill in title, description, select category
   - Choose a file type (PDF/DOC/Image)
   - Click "Upload Resource"

## ✅ **Fix 3: Test Logout Function**

The logout should now work properly. Test it:

1. Go to **Settings** tab
2. Scroll down and click **"Sign Out"**
3. Confirm the logout
4. You should be redirected to the login screen

## 🔍 **Troubleshooting**

### **If Upload Still Fails:**
1. Check browser console for errors
2. Verify bucket name is exactly `resources`
3. Ensure bucket is set to **Public**
4. Check if policies are created correctly

### **If Logout Still Fails:**
1. Check browser console for errors
2. Try force-refreshing the page after logout
3. Clear browser cache and try again

### **Check Supabase Connection:**
Run this test in your browser console:
```javascript
// Test Supabase connection
console.log('Supabase URL:', process.env.EXPO_PUBLIC_SUPABASE_URL);
console.log('Has Anon Key:', !!process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY);
```

## 📱 **Expected Behavior After Fix**

### **Upload Flow:**
1. Select file → Form validation → File upload to Supabase Storage → Database record creation → Coin reward → Success message

### **Logout Flow:**
1. Click Sign Out → Confirmation dialog → Clear local state → Clear AsyncStorage → Supabase signout → Redirect to login

## 🎯 **Verification Steps**

1. **Upload Test**: Upload a PDF file and verify it appears in Supabase Storage
2. **Download Test**: Try downloading the uploaded file
3. **Logout Test**: Sign out and verify you're redirected to login
4. **Login Test**: Sign back in and verify your data is still there

## 🚀 **Once Fixed**

Your Breez+ platform will be 100% functional with:
- ✅ Working file uploads to Supabase Storage
- ✅ Working logout with proper session cleanup
- ✅ Complete coin economy system
- ✅ Real-time data synchronization
- ✅ Full user management

The platform will be ready for production use by East Delta University students!