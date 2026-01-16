-- Drop existing RLS policies
DROP POLICY IF EXISTS "Timetables are viewable by authenticated users" ON timetables;
DROP POLICY IF EXISTS "Timetables are insertable by authenticated users" ON timetables;
DROP POLICY IF EXISTS "Timetables are updatable by authenticated users" ON timetables;
DROP POLICY IF EXISTS "Timetables are deletable by authenticated users" ON timetables;

-- Disable RLS temporarily (for testing)
ALTER TABLE timetables DISABLE ROW LEVEL SECURITY;

-- OR create more permissive RLS policies
ALTER TABLE timetables ENABLE ROW LEVEL SECURITY;

-- Create simple RLS policies
CREATE POLICY "Enable all operations for authenticated users" ON timetables
    FOR ALL USING (auth.role() = 'authenticated')
    WITH CHECK (auth.role() = 'authenticated');

-- Alternative: Disable RLS completely if you don't need it
-- ALTER TABLE timetables DISABLE ROW LEVEL SECURITY;

-- Grant permissions
GRANT ALL ON timetables TO authenticated;
GRANT SELECT ON timetables TO anon;
