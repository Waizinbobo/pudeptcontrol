import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;
  static const _secureStorage = FlutterSecureStorage();

  // Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://hvxciowwhkjuxijaajgq.supabase.co', // Replace with your Supabase URL
      anonKey: 'sb_publishable_d2Rq1gteZ2bxwxjU9b1BTw_bnGFfpmb', // Replace with your Supabase anon key
    );
  }

  // Check if email exists in allowed_users table
  static Future<bool> isEmailAllowed(String email) async {
    try {
      final response = await _supabase
          .from('allowed_users')
          .select('email')
          .eq('email', email)
          .single();
      
      return response != null;
    } catch (e) {
      // Email not found in allowed_users
      return false;
    }
  }

  // Register new user in users table
  static Future<Map<String, dynamic>?> registerUser({
    required String email,
    required String password,
    required String name,
    required String department,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .insert({
            'email': email,
            'password': password, // Note: In production, hash this password
            'name': name,
            'department': department,
            'created_at': DateTime.now().toIso8601String(),
          })
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error registering user: $e');
      return null;
    }
  }

  // Authenticate user against users table
  static Future<Map<String, dynamic>?> authenticateUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .eq('password', password) // Note: In production, use proper password verification
          .single();

      return response;
    } catch (e) {
      print('Error authenticating user: $e');
      return null;
    }
  }

  // Store session securely
  static Future<void> storeSession(Map<String, dynamic> user) async {
    await _secureStorage.write(key: 'user_session', value: user.toString());
    await _secureStorage.write(key: 'user_email', value: user['email']);
    await _secureStorage.write(key: 'user_name', value: user['name']);
  }

  // Get stored session
  static Future<Map<String, String>?> getStoredSession() async {
    final email = await _secureStorage.read(key: 'user_email');
    final name = await _secureStorage.read(key: 'user_name');
    
    if (email != null && name != null) {
      return {
        'email': email!,
        'name': name!,
      };
    }
    return null;
  }

  // Clear session
  static Future<void> clearSession() async {
    await _secureStorage.delete(key: 'user_session');
    await _secureStorage.delete(key: 'user_email');
    await _secureStorage.delete(key: 'user_name');
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final session = await getStoredSession();
    return session != null;
  }

  // Get user profile
  static Future<Map<String, dynamic>?> getUserProfile(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select('*')
          .eq('email', email)
          .single();

      return response;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // Update user profile
  static Future<bool> updateUserProfile({
    required String email,
    String? name,
    String? department,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (department != null) updateData['department'] = department;

      await _supabase
          .from('users')
          .update(updateData)
          .eq('email', email);

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }
}
