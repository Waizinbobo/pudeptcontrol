-- Add semester column to timetables table
ALTER TABLE timetables ADD COLUMN IF NOT EXISTS semester TEXT;

-- Update existing RLS policies to include semester
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON timetables;

CREATE POLICY "Enable all operations for authenticated users" ON timetables
    FOR ALL USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Grant permissions
GRANT ALL ON timetables TO authenticated;
GRANT SELECT ON timetables TO anon;
