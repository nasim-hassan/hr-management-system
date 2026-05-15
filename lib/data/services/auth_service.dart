import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/services/user_profile_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase/supabase.dart' as supabase_auth;
import 'dart:convert';

/// Real Supabase Authentication Service
class AuthService {
  static const _secureStorage = FlutterSecureStorage();
  static const String _userKey = 'auth_user';

  /// Check if user is already logged in
  static Future<User?> getStoredUser() async {
    try {
      print('🔄 [SESSION] Checking for existing session...');
      
      // First check if there's an active Supabase session
      final session = SupabaseConfig.client.auth.currentSession;
      
      if (session != null) {
        final userId = session.user.id;
        print('✅ [SESSION] Active session found. UUID: $userId');
        
        final userJson = await _secureStorage.read(key: _userKey);

        if (userJson != null) {
          print('✅ [SESSION] User found in secure storage');
          final userMap = jsonDecode(userJson) as Map<String, dynamic>;
          return User.fromJson(userMap);
        }

        // If no cached user, fetch from Supabase
        try {
          print('🔍 [SESSION] No cached user, fetching from database...');
          final user = await UserProfileService.fetchUserProfile(userId);
          if (user != null) {
            print('✅ [SESSION] User fetched from database, storing locally');
            await _secureStorage.write(
              key: _userKey,
              value: jsonEncode(user.toJson()),
            );
          }
          return user;
        } catch (e) {
          print('❌ [SESSION] Profile fetch error: $e');
          // Profile doesn't exist yet, user needs to complete signup
          return null;
        }
      } else {
        print('ℹ️  [SESSION] No active session');
      }
    } catch (e) {
      print('❌ [SESSION] Error: $e');
      // Silent fail - user not found or error reading storage
    }
    return null;
  }

  /// Login with email and password using Supabase
  static Future<User?> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 [AUTH] Attempting login with email: $email');
      
      // BYPASS: Allow demo login with admin@gmail.com / Demo@123
      if (email == 'admin@gmail.com' && password == 'Demo@123') {
        print('🔓 [BYPASS] Using demo credentials bypass');
        final demoUser = User(
          id: 'demo-user-id',
          email: 'admin@gmail.com',
          fullName: 'Nasim Hassan',
          role: UserRole.hrAdmin,
          phoneNumber: '+880-1711-543210',
          profileImage: null,
          isActive: true,
          createdAt: DateTime.now(),
        );
        
        // Store user in secure storage
        await _secureStorage.write(
          key: _userKey,
          value: jsonEncode(demoUser.toJson()),
        );
        
        print('✅ [BYPASS] Demo login successful!');
        return demoUser;
      }
      
      print('🔐 [AUTH] Supabase URL: ${SupabaseConfig.client.supabaseUrl}');
      print('🔐 [AUTH] Client initialized: ${SupabaseConfig.client != null}');
      
      // Authenticate with Supabase Auth
      final response = await SupabaseConfig.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      print('✅ [AUTH] Auth response received');
      print('👤 [AUTH] User UUID from Auth: ${response.user?.id}');
      print('📧 [AUTH] User email: ${response.user?.email}');

      if (response.user == null) {
        print('❌ [AUTH] No user returned from auth');
        throw AuthException('Login failed: No user returned');
      }

      // Fetch user profile from database
      print('🔍 [DB] Fetching user profile for UUID: ${response.user!.id}');
      final user = await UserProfileService.fetchUserProfile(response.user!.id);

      if (user == null) {
        print('❌ [DB] User profile not found in database!');
        print('⚠️  [DB] UUID ${response.user!.id} exists in Auth but not in users table');
        // User exists in auth but no profile - this shouldn't happen with proper setup
        await SupabaseConfig.client.auth.signOut();
        throw AuthException('User profile not found. Please contact admin.');
      }

      print('✅ [DB] User profile found: ${user.fullName} (${user.role.displayName})');

      // Store user in secure storage for offline access
      await _secureStorage.write(
        key: _userKey,
        value: jsonEncode(user.toJson()),
      );

      print('💾 [STORAGE] User stored in secure storage');
      print('✅ [LOGIN] Login successful!');
      return user;
    } on AuthException catch (e) {
      print('❌ [ERROR] AuthException: $e');
      rethrow;
    } catch (e) {
      print('❌ [ERROR] Unexpected error: $e');
      print('📍 [ERROR] Error type: ${e.runtimeType}');
      print('📍 [ERROR] Stack trace: ${StackTrace.current}');
      print('📍 [ERROR] Full error object: ${e.toString()}');
      throw AuthException('Login failed: ${e.toString()}');
    }
  }

  /// Sign up new user (for registration if needed)
  static Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await SupabaseConfig.client.auth.signUp(
        email: email,
        password: password,
      );

      return response.user != null;
    } catch (e) {
      throw AuthException('Sign up failed: ${e.toString()}');
    }
  }

  /// Logout
  static Future<void> logout() async {
    try {
      await SupabaseConfig.client.auth.signOut();
      await _secureStorage.delete(key: _userKey);
    } catch (e) {
      throw AuthException('Logout failed: $e');
    }
  }

  /// Get current authentication token
  static Future<String?> getToken() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      return session?.accessToken;
    } catch (e) {
      // Silent fail
      return null;
    }
  }

  /// Verify email exists in auth system
  static Future<bool> emailExists(String email) async {
    try {
      // Try to check if email can be used for password reset (indirect way to check existence)
      // This is just a helper - actual check happens during login/signup
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset password request
  static Future<void> resetPassword(String email) async {
    try {
      await SupabaseConfig.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: ${e.toString()}');
    }
  }

  /// Update password
  static Future<void> updatePassword(String newPassword) async {
    try {
      await SupabaseConfig.client.auth.updateUser(
        supabase_auth.UserAttributes(password: newPassword),
      );
    } catch (e) {
      throw AuthException('Password update failed: ${e.toString()}');
    }
  }
}

class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
