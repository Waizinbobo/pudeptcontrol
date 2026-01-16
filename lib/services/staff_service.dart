import 'package:supabase_flutter/supabase_flutter.dart';
import 'department_service.dart';

class StaffService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create Staff
  static Future<Map<String, dynamic>?> createStaff({
    required String name,
    required String email,
    String? position,
    String? departmentId,
    String? phone,
    DateTime? hireDate,
    double? salary,
  }) async {
    try {
      print('👥 Creating staff member: $name');
      
      final staffData = <String, dynamic>{
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'position': position?.trim(),
        'department_id': departmentId,
        'phone': phone?.trim(),
        'salary': salary,
        'is_active': true,
      };

      if (hireDate != null) {
        staffData['hire_date'] = hireDate.toIso8601String().split('T')[0];
      }

      print('📝 Staff data to insert: $staffData');

      final response = await _supabase
          .from('staff')
          .insert(staffData)
          .select()
          .single();

      print('✅ Staff created successfully: $response');

      // Update department staff count if department is assigned
      if (departmentId != null && departmentId.isNotEmpty) {
        await DepartmentService.updateDepartmentStaffCount(departmentId);
      }

      return response;
    } catch (e) {
      print('❌ Error creating staff: $e');
      return null;
    }
  }

  // Get All Staff
  static Future<List<Map<String, dynamic>>> getAllStaff() async {
    try {
      print('📋 Fetching all staff...');
      
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('✅ Retrieved ${response.length} staff members');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching staff: $e');
      return [];
    }
  }

  // Get Staff by ID
  static Future<Map<String, dynamic>?> getStaffById(String id) async {
    try {
      print('🔍 Fetching staff: $id');
      
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('id', id)
          .eq('is_active', true)
          .single();

      print('✅ Staff retrieved: $response');
      return response;
    } catch (e) {
      print('❌ Error fetching staff: $e');
      return null;
    }
  }

  // Update Staff
  static Future<bool> updateStaff({
    required String id,
    String? name,
    String? email,
    String? position,
    String? departmentId,
    String? phone,
    DateTime? hireDate,
    double? salary,
  }) async {
    try {
      print('📝 Updating staff: $id');
      
      // Get current staff data to check old department
      final currentStaff = await getStaffById(id);
      final oldDepartmentId = currentStaff?['department_id'] as String?;
      
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name.trim();
      if (email != null) updateData['email'] = email.trim().toLowerCase();
      if (position != null) updateData['position'] = position.trim();
      if (departmentId != null) updateData['department_id'] = departmentId;
      if (phone != null) updateData['phone'] = phone.trim();
      if (hireDate != null) updateData['hire_date'] = hireDate.toIso8601String().split('T')[0];
      if (salary != null) updateData['salary'] = salary;

      print('📊 Update data: $updateData');

      await _supabase
          .from('staff')
          .update(updateData)
          .eq('id', id);

      print('✅ Staff updated successfully');

      // Update department staff counts if department changed
      if (departmentId != oldDepartmentId) {
        if (oldDepartmentId != null && oldDepartmentId.isNotEmpty) {
          await DepartmentService.updateDepartmentStaffCount(oldDepartmentId);
        }
        if (departmentId != null && departmentId.isNotEmpty) {
          await DepartmentService.updateDepartmentStaffCount(departmentId);
        }
      }

      return true;
    } catch (e) {
      print('❌ Error updating staff: $e');
      return false;
    }
  }

  // Delete Staff (Soft Delete)
  static Future<bool> deleteStaff(String id) async {
    try {
      print('🗑️ Deleting staff: $id');
      
      // Get staff data before deletion to update department count
      final staff = await getStaffById(id);
      final departmentId = staff?['department_id'] as String?;
      
      await _supabase
          .from('staff')
          .update({
            'is_active': false,
          })
          .eq('id', id);

      print('✅ Staff deleted successfully');

      // Update department staff count if staff had a department
      if (departmentId != null && departmentId.isNotEmpty) {
        await DepartmentService.updateDepartmentStaffCount(departmentId);
      }

      return true;
    } catch (e) {
      print('❌ Error deleting staff: $e');
      return false;
    }
  }

  // Search Staff
  static Future<List<Map<String, dynamic>>> searchStaff(String query) async {
    try {
      print('🔍 Searching staff: $query');
      
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('is_active', true)
          .or('name.ilike.%$query%,email.ilike.%$query%,position.ilike.%$query%')
          .order('created_at', ascending: false);

      print('✅ Found ${response.length} matching staff members');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching staff: $e');
      return [];
    }
  }

  // Get Staff by Department
  static Future<List<Map<String, dynamic>>> getStaffByDepartment(String departmentId) async {
    try {
      print('🏢 Fetching staff for department: $departmentId');
      
      final response = await _supabase
          .from('staff')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('department_id', departmentId)
          .eq('is_active', true)
          .order('name', ascending: true);

      print('✅ Retrieved ${response.length} staff members for department');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching staff by department: $e');
      return [];
    }
  }

  // Get Staff Statistics
  static Future<Map<String, dynamic>> getStaffStats() async {
    try {
      print('📊 Fetching staff statistics...');
      
      final response = await _supabase
          .from('staff')
          .select('department_id')
          .eq('is_active', true);

      final staff = List<Map<String, dynamic>>.from(response);
      final totalStaff = staff.length;
      
      // Count staff per department
      final departmentCounts = <String, int>{};
      for (final member in staff) {
        final deptId = member['department_id'] as String?;
        if (deptId != null) {
          departmentCounts[deptId] = (departmentCounts[deptId] ?? 0) + 1;
        }
      }

      final stats = {
        'total_staff': totalStaff,
        'staff_per_department': departmentCounts,
        'departments_with_staff': departmentCounts.length,
      };

      print('✅ Staff statistics: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching staff stats: $e');
      return {
        'total_staff': 0,
        'staff_per_department': <String, int>{},
        'departments_with_staff': 0,
      };
    }
  }

  // Check if Email Exists
  static Future<bool> staffEmailExists(String email, {String? excludeId}) async {
    try {
      print('🔍 Checking if staff email exists: $email');
      
      var query = _supabase
          .from('staff')
          .select('id')
          .eq('email', email.trim().toLowerCase())
          .eq('is_active', true);

      if (excludeId != null) {
        query = query.neq('id', excludeId);
      }

      final response = await query.maybeSingle();

      final exists = response != null;
      print('📊 Staff email exists: $exists');
      return exists;
    } catch (e) {
      print('❌ Error checking staff email: $e');
      return false;
    }
  }

  // Update Department Staff Count
  static Future<void> updateAllDepartmentStaffCounts() async {
    try {
      print('📊 Updating all department staff counts...');
      
      // Get all active staff with their departments
      final staffResponse = await _supabase
          .from('staff')
          .select('department_id')
          .eq('is_active', true);

      final staff = List<Map<String, dynamic>>.from(staffResponse);
      
      // Count staff per department
      final departmentCounts = <String, int>{};
      for (final member in staff) {
        final deptId = member['department_id'] as String?;
        if (deptId != null) {
          departmentCounts[deptId] = (departmentCounts[deptId] ?? 0) + 1;
        }
      }

      // Update each department's staff count
      for (final entry in departmentCounts.entries) {
        await _supabase
            .from('departments')
            .update({
              'staff_count': entry.value,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', entry.key);
      }

      print('✅ Updated ${departmentCounts.length} department staff counts');
    } catch (e) {
      print('❌ Error updating department staff counts: $e');
    }
  }
}
