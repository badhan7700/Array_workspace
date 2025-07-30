/*
  # Breez+ Storage Configuration
  
  This file sets up Supabase Storage buckets for file uploads
  and configures appropriate access policies.
*/

-- =============================================
-- CREATE STORAGE BUCKETS
-- =============================================

-- Create bucket for academic resources
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'resources',
  'resources',
  false, -- Private bucket, access controlled by RLS
  52428800, -- 50MB limit
  ARRAY[
    'application/pdf',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'image/jpeg',
    'image/png',
    'image/gif',
    'text/plain'
  ]
);

-- Create bucket for user profile images (optional for future use)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true, -- Public bucket for profile images
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif']
);

-- =============================================
-- STORAGE RLS POLICIES
-- =============================================

-- Resources bucket policies
CREATE POLICY "Users can upload resources"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'resources' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can read approved resources"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'resources' AND
  EXISTS (
    SELECT 1 FROM resources
    WHERE file_path = storage.objects.name
    AND status = 'approved'
    AND (
      -- User has downloaded this resource
      EXISTS (
        SELECT 1 FROM downloads
        WHERE resource_id = resources.id
        AND downloader_id = auth.uid()
      )
      OR
      -- User is the uploader
      uploader_id = auth.uid()
      OR
      -- User is admin/moderator
      EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid()
        AND role IN ('admin', 'moderator')
      )
    )
  )
);

CREATE POLICY "Users can update own resources"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'resources' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own resources"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'resources' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Avatars bucket policies (for future use)
CREATE POLICY "Users can upload own avatar"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO authenticated
USING (bucket_id = 'avatars');

CREATE POLICY "Users can update own avatar"
ON storage.objects FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete own avatar"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars' AND
  auth.uid()::text = (storage.foldername(name))[1]
);