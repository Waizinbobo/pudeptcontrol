import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class TimetableService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Create Timetable Entry
  static Future<Map<String, dynamic>?> createTimetable({
    required String subject,
    required String teacher,
    required String day,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String room,
    String? departmentId,
    String? description,
    String? semester,
    String? staffId,
  }) async {
    try {
      print('📅 Creating timetable entry: $subject');
      
      final timetableData = {
        'subject': subject.trim(),
        'teacher': teacher.trim(),
        'day': day.trim(),
        'start_time': '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
        'end_time': '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
        'room': room.trim(),
        'department_id': departmentId,
        'description': description?.trim(),
        'semester': semester?.trim(),
        'staff_id': staffId,
        'is_active': true,
      };

      print('📝 Timetable data to insert: $timetableData');

      final response = await _supabase
          .from('timetables')
          .insert(timetableData)
          .select()
          .single();

      print('✅ Timetable entry created successfully: $response');
      return response;
    } catch (e) {
      print('❌ Error creating timetable entry: $e');
      return null;
    }
  }

  // Get All Timetables
  static Future<List<Map<String, dynamic>>> getAllTimetables() async {
    try {
      print('📋 Fetching all timetables...');
      
      final response = await _supabase
          .from('timetables')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('is_active', true)
          .order('day', ascending: true)
          .order('start_time', ascending: true);

      print('✅ Retrieved ${response.length} timetable entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching timetables: $e');
      return [];
    }
  }

  // Get Timetable by ID
  static Future<Map<String, dynamic>?> getTimetableById(String id) async {
    try {
      print('🔍 Fetching timetable: $id');
      
      final response = await _supabase
          .from('timetables')
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

      print('✅ Timetable retrieved: $response');
      return response;
    } catch (e) {
      print('❌ Error fetching timetable: $e');
      return null;
    }
  }

  // Update Timetable
  static Future<bool> updateTimetable({
    required String id,
    String? subject,
    String? teacher,
    String? day,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? room,
    String? departmentId,
    String? description,
    String? semester,
    String? staffId,
  }) async {
    try {
      print('📝 Updating timetable: $id');
      
      final updateData = <String, dynamic>{};
      if (subject != null) updateData['subject'] = subject.trim();
      if (teacher != null) updateData['teacher'] = teacher.trim();
      if (day != null) updateData['day'] = day.trim();
      if (startTime != null) updateData['start_time'] = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
      if (endTime != null) updateData['end_time'] = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
      if (room != null) updateData['room'] = room.trim();
      if (departmentId != null) updateData['department_id'] = departmentId;
      if (description != null) updateData['description'] = description.trim();
      if (semester != null) updateData['semester'] = semester.trim();
      if (staffId != null) updateData['staff_id'] = staffId;

      print('📊 Update data: $updateData');

      await _supabase
          .from('timetables')
          .update(updateData)
          .eq('id', id);

      print('✅ Timetable updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating timetable: $e');
      return false;
    }
  }

  // Delete Timetable (Soft Delete)
  static Future<bool> deleteTimetable(String id) async {
    try {
      print('🗑️ Deleting timetable: $id');
      
      await _supabase
          .from('timetables')
          .update({
            'is_active': false,
          })
          .eq('id', id);

      print('✅ Timetable deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting timetable: $e');
      return false;
    }
  }

  // Search Timetables
  static Future<List<Map<String, dynamic>>> searchTimetables(String query) async {
    try {
      print('🔍 Searching timetables: $query');
      
      final response = await _supabase
          .from('timetables')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('is_active', true)
          .or('subject.ilike.%$query%,teacher.ilike.%$query%,room.ilike.%$query%')
          .order('day', ascending: true)
          .order('start_time', ascending: true);

      print('✅ Found ${response.length} matching timetable entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error searching timetables: $e');
      return [];
    }
  }

  // Get Timetables by Day
  static Future<List<Map<String, dynamic>>> getTimetablesByDay(String day) async {
    try {
      print('📅 Fetching timetables for day: $day');
      
      final response = await _supabase
          .from('timetables')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('day', day)
          .eq('is_active', true)
          .order('start_time', ascending: true);

      print('✅ Retrieved ${response.length} timetable entries for $day');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching timetables by day: $e');
      return [];
    }
  }

  // Get Timetables by Department
  static Future<List<Map<String, dynamic>>> getTimetablesByDepartment(String departmentId) async {
    try {
      print('🏢 Fetching timetables for department: $departmentId');
      
      final response = await _supabase
          .from('timetables')
          .select('''
            *,
            departments (
              id,
              name
            )
          ''')
          .eq('department_id', departmentId)
          .eq('is_active', true)
          .order('day', ascending: true)
          .order('start_time', ascending: true);

      print('✅ Retrieved ${response.length} timetable entries for department');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Error fetching timetables by department: $e');
      return [];
    }
  }

  // Get Timetable Statistics
  static Future<Map<String, dynamic>> getTimetableStats() async {
    try {
      print('📊 Fetching timetable statistics...');
      
      final response = await _supabase
          .from('timetables')
          .select('day, department_id')
          .eq('is_active', true);

      final timetables = List<Map<String, dynamic>>.from(response);
      final totalTimetables = timetables.length;
      
      // Count timetables per day
      final dayCounts = <String, int>{};
      for (final entry in timetables) {
        final day = entry['day'] as String?;
        if (day != null) {
          dayCounts[day] = (dayCounts[day] ?? 0) + 1;
        }
      }

      // Count timetables per department
      final departmentCounts = <String, int>{};
      for (final entry in timetables) {
        final deptId = entry['department_id'] as String?;
        if (deptId != null) {
          departmentCounts[deptId] = (departmentCounts[deptId] ?? 0) + 1;
        }
      }

      final stats = {
        'total_timetables': totalTimetables,
        'timetables_per_day': dayCounts,
        'timetables_per_department': departmentCounts,
        'days_with_timetables': dayCounts.length,
        'departments_with_timetables': departmentCounts.length,
      };

      print('✅ Timetable statistics: $stats');
      return stats;
    } catch (e) {
      print('❌ Error fetching timetable stats: $e');
      return {
        'total_timetables': 0,
        'timetables_per_day': <String, int>{},
        'timetables_per_department': <String, int>{},
        'days_with_timetables': 0,
        'departments_with_timetables': 0,
      };
    }
  }
}