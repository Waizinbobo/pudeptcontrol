-- Create timetables table
CREATE TABLE IF NOT EXISTS timetables (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  subject TEXT NOT NULL,
  teacher TEXT NOT NULL,
  day TEXT NOT NULL,
  start_time TEXT NOT NULL,
  end_time TEXT NOT NULL,
  room TEXT NOT NULL,
  department_id UUID REFERENCES departments(id) ON DELETE SET NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE timetables ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Timetables are viewable by authenticated users" ON timetables
    FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Timetables are insertable by authenticated users" ON timetables
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Timetables are updatable by authenticated users" ON timetables
    FOR UPDATE USING (auth.role() = 'authenticated');

CREATE POLICY "Timetables are deletable by authenticated users" ON timetables
    FOR DELETE USING (auth.role() = 'authenticated');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_timetables_day ON timetables(day);
CREATE INDEX IF NOT EXISTS idx_timetables_department_id ON timetables(department_id);
CREATE INDEX IF NOT EXISTS idx_timetables_is_active ON timetables(is_active);
CREATE INDEX IF NOT EXISTS idx_timetables_start_time ON timetables(start_time);

-- Grant permissions
GRANT ALL ON timetables TO authenticated;
GRANT SELECT ON timetables TO anon;
