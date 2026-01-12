import 'package:supabase_flutter/supabase_flutter.dart';

class DepartmentService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create Department
  static Future<Map<String, dynamic>?> createDepartment({
    required String name,
    required String code,
    required String description,
    required String headName,
  }) async {
    try {
      print('🏢 Creating department: $name');
      
      final departmentData = {
        'name': name.trim(),
        'code': code.trim().toUpperCase(),
        'description': description.trim(),
        'head_name': headName.trim(),
        'staff_count': 0,
        'is_active': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📝 Department data to insert: $departmentData');

      final response = await _supabase
          .from('departments')
          .insert(departmentData)
          .select()
          .single();

      print('✅ Department created successfully: $response');
      return response;
    } catch (e) {
      print('❌ Error creating department: $e');
      return null;
    }
  }

  // Get All Departments
  static Future<List<Map<String, dynamic>>> getAllDepartments() async {
    try {
      print('📋 Fetching all departments...');
      
      final response = await _supabase
          .from('departments')
          .select('*')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('✅ Retrieved ${response.length} departments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching departments: $e');
      return [];
    }
  }

  // Get Department by ID
  static Future<Map<String, dynamic>?> getDepartmentById(String id) async {
    try {
      print('🔍 Fetching department: $id');
      
      final response = await _supabase
          .from('departments')
          .select('*')
          .eq('id', id)
          .eq('is_active', true)
          .single();

      print('✅ Department retrieved: $response');
      return response;
    } catch (e) {
      print('❌ Error fetching department: $e');
      return null;
    }
  }

  // Update Department
  static Future<bool> updateDepartment({
    required String id,
    String? name,
    String? code,
    String? description,
    String? headName,
  }) async {
    try {
      print('📝 Updating department: $id');
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name.trim();
      if (code != null) updateData['code'] = code.trim().toUpperCase();
      if (description != null) updateData['description'] = description.trim();
      if (headName != null) updateData['head_name'] = headName.trim();
      updateData['updated_at'] = DateTime.now().toIso8601String();

      print('📊 Update data: $updateData');

      await _supabase
          .from('departments')
          .update(updateData)
          .eq('id', id);

      print('✅ Department updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating department: $e');
      return false;
    }
  }

  // Delete Department (Soft Delete)
  static Future<bool> deleteDepartment(String id) async {
    try {
      print('🗑️ Deleting department: $id');
      
      await _supabase
          .from('departments')
          .update({
            'is_active': false,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id);

      print('✅ Department deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting department: $e');
      return false;
    }
  }

  // Search Departments
  static Future<List<Map<String, dynamic>>> searchDepartments(String query) async {
    try {
      print('🔍 Searching departments: $query');
      
      final response = await _supabase
          .from('departments')
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$query%,code.ilike.%$query%,head_name.ilike.%$query%')
          .order('created_at', ascending: false);

      print('✅ Found ${response.length} matching departments');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching departments: $e');
      return [];
    }
  }

  // Update Staff Count
  static Future<bool> updateStaffCount(String departmentId, int count) async {
    try {
      print('📊 Updating staff count for department $departmentId: $count');
      
      await _supabase
          .from('departments')
          .update({
            'staff_count': count,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', departmentId);

      print('✅ Staff count updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating staff count: $e');
      return false;
    }
  }

  // Get Department Statistics
  static Future<Map<String, dynamic>> getDepartmentStats() async {
    try {
      print('📊 Fetching department statistics...');
      
      final response = await _supabase
          .from('departments')
          .select('staff_count')
          .eq('is_active', true);

      final departments = List<Map<String, dynamic>>.from(response);
      final totalDepartments = departments.length;
      final totalStaff = departments.fold<int>(
        0, 
        (sum, dept) => sum + (dept['staff_count'] as int? ?? 0),
      );

      final stats = {
        'total_departments': totalDepartments,
        'total_staff': totalStaff,
        'average_staff_per_department': totalDepartments > 0 ? (totalStaff / totalDepartments).round() : 0,
      };

      print('✅ Department statistics: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching department stats: $e');
      return {
        'total_departments': 0,
        'total_staff': 0,
        'average_staff_per_department': 0,
      };
    }
  }

  // Check if Department Code Exists
  static Future<bool> departmentCodeExists(String code, {String? excludeId}) async {
    try {
      print('🔍 Checking if department code exists: $code');
      
      var query = _supabase
          .from('departments')
          .select('id')
          .eq('code', code.trim().toUpperCase())
          .eq('is_active', true);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query.maybeSingle();

      final exists = response != null;
      print('📊 Department code exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking department code: $e');
      return false;
    }
  }

  // Check if Department Name Exists
  static Future<bool> departmentNameExists(String name, {String? excludeId}) async {
    try {
      print('🔍 Checking if department name exists: $name');
      
      var query = _supabase
          .from('departments')
          .select('id')
          .eq('name', name.trim())
          .eq('is_active', true);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query.maybeSingle();

      final exists = response != null;
      print('📊 Department name exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking department name: $e');
      return false;
    }
  }
}
