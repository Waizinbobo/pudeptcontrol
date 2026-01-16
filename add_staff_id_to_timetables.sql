-- Add staff_id column to timetables table
ALTER TABLE timetables ADD COLUMN IF NOT EXISTS staff_id UUID REFERENCES staff(id);

-- Update existing RLS policies to include staff_id
DROP POLICY IF EXISTS "Enable all operations for authenticated users" ON timetables;

CREATE POLICY "Enable all operations for authenticated users" ON timetables
    FOR ALL USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Grant permissions
GRANT ALL ON timetables TO authenticated;
GRANT SELECT ON timetables TO anon;
