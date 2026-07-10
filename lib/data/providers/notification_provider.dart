import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/notification_model.dart';
import 'package:hr_management_system/data/services/notification_service.dart';

class NotificationState {
  final List<Notification> notifications;
  final bool isLoading;
  final String? error;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationState copyWith({
    List<Notification>? notifications,
    bool? isLoading,
    String? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await NotificationService.getAllNotifications();
      state = state.copyWith(notifications: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final notification = state.notifications.firstWhere((n) => n.id == notificationId);
      final updated = await NotificationService.updateNotification(notificationId, {
        'is_read': true,
        'read_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (updated != null) {
        state = state.copyWith(
          notifications: state.notifications.map((item) => item.id == notificationId ? updated : item).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update notification');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await NotificationService.deleteNotification(notificationId);
      if (success) {
        state = state.copyWith(
          notifications: state.notifications.where((item) => item.id != notificationId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete notification');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});
