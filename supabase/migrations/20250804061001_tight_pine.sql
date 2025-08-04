/*
  # Add user_type column to user_profiles

  1. Schema Changes
    - Add `user_type` column to `user_profiles` table with values 'public' or 'paid'
    - Set default value to 'public'
    - Add check constraint to ensure only valid values

  2. Data Migration
    - Update existing users to have 'public' user_type by default
*/

-- Add user_type column to user_profiles table
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'user_profiles' AND column_name = 'user_type'
  ) THEN
    ALTER TABLE user_profiles ADD COLUMN user_type text DEFAULT 'public' NOT NULL;
  END IF;
END $$;

-- Add check constraint for user_type values
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.check_constraints
    WHERE constraint_name = 'user_profiles_user_type_check'
  ) THEN
    ALTER TABLE user_profiles ADD CONSTRAINT user_profiles_user_type_check 
    CHECK (user_type = ANY (ARRAY['public'::text, 'paid'::text]));
  END IF;
END $$;

-- Update existing users to have 'public' user_type (if any exist)
UPDATE user_profiles SET user_type = 'public' WHERE user_type IS NULL;