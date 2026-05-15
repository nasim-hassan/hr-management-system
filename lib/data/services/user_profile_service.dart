import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

/// Service to handle user profile operations from Supabase
class UserProfileService {
  static const String _tableName = 'users';

  /// Fetch user profile from database by user ID
  static Future<User?> fetchUserProfile(String userId) async {
    try {
      print('🔍 [USER_PROFILE] Fetching profile for UUID: $userId');
      
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', userId)
          .single();

      print('✅ [USER_PROFILE] Response received from database');
      print('📦 [USER_PROFILE] Data: $response');

      if (response == null) {
        print('❌ [USER_PROFILE] Response is null');
        return null;
      }

      final user = User.fromJson(response as Map<String, dynamic>);
      print('✅ [USER_PROFILE] User parsed: ${user.fullName} (${user.role.displayName})');
      return user;
    } catch (e) {
      print('❌ [USER_PROFILE] Error: $e');
      print('📍 [USER_PROFILE] Error type: ${e.runtimeType}');
      throw UserProfileException('Failed to fetch user profile: $e');
    }
  }

  /// Fetch user profile by email
  static Future<User?> fetchUserProfileByEmail(String email) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('email', email)
          .single();

      if (response == null) return null;

      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw UserProfileException('Failed to fetch user profile by email: $e');
    }
  }

  /// Update user profile
  static Future<User?> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', userId)
          .select()
          .single();

      if (response == null) return null;

      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw UserProfileException('Failed to update user profile: $e');
    }
  }

  /// Get all users (admin only)
  static Future<List<User>> getAllUsers() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserProfileException('Failed to fetch users: $e');
    }
  }

  /// Get users by role
  static Future<List<User>> getUsersByRole(UserRole role) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('role', role.toStringValue())
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserProfileException('Failed to fetch users by role: $e');
    }
  }

  /// Get users by manager ID (for managers to view their team)
  static Future<List<User>> getTeamMembers(String managerId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('manager_id', managerId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response as List<dynamic>)
          .map((item) => User.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw UserProfileException('Failed to fetch team members: $e');
    }
  }

  /// Create new user (admin only)
  static Future<User?> createUser({
    required String email,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
    String? profileImage,
    String? department,
    String? designation,
    DateTime? joinDate,
    String? managerId,
  }) async {
    try {
      final userData = {
        'email': email,
        'full_name': fullName,
        'role': role.toStringValue(),
        'phone_number': phoneNumber,
        'profile_image': profileImage,
        'is_active': true,
        'department': department,
        'designation': designation,
        'join_date': joinDate?.toIso8601String(),
        'manager_id': managerId,
      };

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert([userData])
          .select()
          .single();

      if (response == null) return null;

      return User.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw UserProfileException('Failed to create user: $e');
    }
  }

  /// Deactivate user (admin only)
  static Future<bool> deactivateUser(String userId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .update({'is_active': false})
          .eq('id', userId);

      return true;
    } catch (e) {
      throw UserProfileException('Failed to deactivate user: $e');
    }
  }

  /// Check if email exists
  static Future<bool> emailExists(String email) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('email', email)
          .single();

      return response != null;
    } catch (e) {
      return false;
    }
  }
}

class UserProfileException implements Exception {
  final String message;

  UserProfileException(this.message);

  @override
  String toString() => message;
}
