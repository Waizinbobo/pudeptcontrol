-- Remove head_name column from departments table
ALTER TABLE departments DROP COLUMN IF EXISTS head_name;

-- Update department service to remove head_name references
-- Note: You'll need to update the DepartmentService in your Flutter code
-- to remove head_name parameters from create and update methods
