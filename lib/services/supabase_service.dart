import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static const _storage = FlutterSecureStorage();

  /// LOGIN
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    // users table မှာ login check
    final user = await _client
        .from('users')
        .select()
        .eq('email', email)
        .eq('password', password)
        .eq('is_active', true)
        .maybeSingle();

    if (user != null) {
      // ✅ Login successful -> save info to secure storage
      await _storage.write(key: 'user_id', value: user['id'].toString());
      await _storage.write(key: 'user_email', value: user['email']);
      await _storage.write(key: 'user_role', value: user['role'] ?? 'user');
      await _storage.write(key: 'user_department', value: user['department']);
      await _storage.write(key: 'user_name', value: user['name']); // 🔹 save user name
    }

    return user;
  }

  /// SIGNUP
  static Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String department,
  }) async {
    // allowed_users မှာ email ရှိ/မရှိစစ်
    final allowedUser = await _client
        .from('allowed_users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (allowedUser == null) {
      throw Exception('This email is not allowed to sign up.');
    }

    final role = allowedUser['role'];

    // users table ထဲသို့ insert
    await _client.from('users').insert({
      'email': email,
      'password': password,
      'name': name,
      'department': department,
      'role': role,
      'is_active': true,
    });
  }

  // ================= DEPARTMENT CRUD =================

  static Future<List<Map<String, dynamic>>> getDepartments() async {
    final res = await _client
        .from('departments')
        .select()
        .eq('is_active', true)
        .order('id');

    return List<Map<String, dynamic>>.from(res);
  }

  static Future<void> addDepartment({
    required String name,
    required String code,
    required String description,
  }) async {
    await _client.from('departments').insert({
      'name': name,
      'code': code,
      'description': description,
      'is_active': true,
    });
  }

  static Future<void> updateDepartment({
    required int id,
    required String name,
    required String code,
    required String description,
  }) async {
    await _client.from('departments').update({
      'name': name,
      'code': code,
      'description': description,
    }).eq('id', id);
  }

  static Future<void> deleteDepartment(int id) async {
    await _client
        .from('departments')
        .update({'is_active': false})
        .eq('id', id);
  }

  /// ADD STAFF
  static Future<void> addStaff({
    required String name,
    required String staffId,
    required String email,
    required String phone,
    required String department,
    required String role,
    required bool isActive,
  }) async {
    await _client.from('users').insert({
      'name': name,
      'staff_id': staffId,
      'email': email,
      'phone': phone,
      'department': department,
      'role': role,
      'is_active': isActive,
    });
  }

  /// UPDATE STAFF
  static Future<void> updateStaff({
    required int id,
    required String name,
    required String staffId,
    required String email,
    required String phone,
    required String department,
    required String role,
    required bool isActive,
  }) async {
    await _client.from('users').update({
      'name': name,
      'staff_id': staffId,
      'email': email,
      'phone': phone,
      'department': department,
      'role': role,
      'is_active': isActive,
    }).eq('id', id);
  }

  /// DELETE STAFF
  static Future<void> deleteStaff(int id) async {
    await _client.from('users').delete().eq('id', id);
  }

  /// GET ALL STAFF
  static Future<List<Map<String, dynamic>>> getAllStaff() async {
    final res = await _client.from('users').select().order('id');
    return List<Map<String, dynamic>>.from(res);
  }

  /// LOGOUT
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// CHECK LOGIN
  static Future<bool> isLoggedIn() async {
    return await _storage.read(key: 'user_email') != null;
  }
}
