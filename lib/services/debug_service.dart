import 'package:supabase_flutter/supabase_flutter.dart';

class DebugService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Test if table exists
  static Future<bool> doesTableExist(String tableName) async {
    try {
      print('🔍 Checking if table "$tableName" exists...');
      
      final response = await _supabase
          .from(tableName)
          .select('*')
          .limit(1);
      
      print('✅ Table "$tableName" exists');
      return true;
    } catch (e) {
      print('❌ Table "$tableName" does not exist or error: $e');
      return false;
    }
  }

  // List all tables
  static Future<void> listAllTables() async {
    try {
      print('📋 Listing all tables...');
      
      final response = await _supabase
          .rpc('get_tables'); // You'll need to create this function
      
      print('📊 Tables: $response');
    } catch (e) {
      print('❌ Error listing tables: $e');
      
      // Alternative method using information_schema
      try {
        final response = await _supabase
            .from('information_schema.tables')
            .select('table_name')
            .eq('table_schema', 'public');
        
        print('📊 Tables in public schema: $response');
      } catch (e2) {
        print('❌ Alternative method also failed: $e2');
      }
    }
  }

  // Test basic connection
  static Future<void> testConnection() async {
    try {
      print('🔌 Testing Supabase connection...');
      
      final response = await _supabase
          .from('departments')
          .select('count')
          .single();
      
      print('✅ Connection successful. Count: $response');
    } catch (e) {
      print('❌ Connection failed: $e');
    }
  }

  // Create a simple test department
  static Future<void> createTestDepartment() async {
    try {
      print('🧪 Creating test department...');
      
      final response = await _supabase
          .from('departments')
          .insert({
            'name': 'Test Department',
            'code': 'TEST-001',
            'description': 'This is a test department',
            'head_name': 'Test Manager',
            'staff_count': 0,
            'is_active': true,
          })
          .select()
          .single();
      
      print('✅ Test department created: $response');
    } catch (e) {
      print('❌ Failed to create test department: $e');
    }
  }

  // Get raw response
  static Future<void> getRawDepartments() async {
    try {
      print('🔍 Getting raw departments data...');
      
      final response = await _supabase
          .from('departments')
          .select('*');
      
      print('📊 Raw response: $response');
      print('📊 Response type: ${response.runtimeType}');
      print('📊 Response length: ${response.length}');
    } catch (e) {
      print('❌ Error getting raw departments: $e');
    }
  }
}
