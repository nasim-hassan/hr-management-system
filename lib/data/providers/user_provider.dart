import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/data/services/user_profile_service.dart';
import 'package:hr_management_system/data/services/auth_service.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

class UserListState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  UserListState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserListState copyWith({
    List<User>? users,
    bool? isLoading,
    String? error,
  }) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class UserListNotifier extends StateNotifier<UserListState> {
  UserListNotifier() : super(UserListState()) {
    loadUsers();
  }

  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await UserProfileService.getAllUsers();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addUser({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? phoneNumber,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Sign up the user in Supabase Auth to get an auth ID
      final authId = await AuthService.signUp(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (authId == null) {
        state = state.copyWith(isLoading: false, error: 'Failed to create user in authentication system');
        return false;
      }

      // 2. Create the user profile in the database
      final newUser = await UserProfileService.createUser(
        id: authId,
        email: email,
        fullName: fullName,
        role: role,
        phoneNumber: phoneNumber,
      );

      if (newUser != null) {
        state = state.copyWith(
          users: [newUser, ...state.users],
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to create user profile');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateUser(User user) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedUser = await UserProfileService.updateUserProfile(user.id, {
        'email': user.email,
        'full_name': user.fullName,
        'phone_number': user.phoneNumber,
        'role': user.role.toStringValue(),
        'is_active': user.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (updatedUser != null) {
        state = state.copyWith(
          users: state.users.map((u) => u.id == user.id ? updatedUser : u).toList(),
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to update user profile');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await UserProfileService.deactivateUser(userId);
      if (success) {
        state = state.copyWith(
          users: state.users.where((u) => u.id != userId).toList(),
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to deactivate user');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final userProvider = StateNotifierProvider<UserListNotifier, UserListState>((ref) {
  return UserListNotifier();
});
