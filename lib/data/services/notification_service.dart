import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/notification_model.dart';

class NotificationService {
  static const String _tableName = 'notifications';

  static Future<List<Notification>> getAllNotifications() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => Notification.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  static Future<Notification?> fetchNotificationById(
      String notificationId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', notificationId)
          .maybeSingle();

      if (response == null) return null;
      return Notification.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch notification: $e');
    }
  }

  static Future<Notification?> createNotification(
      Notification notification) async {
    try {
      final notificationData = notification.toJson();
      if (notification.id.startsWith('notif_')) notificationData.remove('id');

      final existingResponse = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', notification.userId)
          .eq('type', notification.type.toStringValue())
          .eq('related_id', notification.relatedId)
          .eq('related_type', notification.relatedType);

      if (existingResponse != null &&
          existingResponse is List &&
          existingResponse.isNotEmpty) {
        final existingNotifications = existingResponse
            .whereType<Map<String, dynamic>>()
            .map((item) => Notification.fromJson(item))
            .toList();

        if (existingNotifications.isNotEmpty) {
          if (existingNotifications.length > 1) {
            for (final duplicate in existingNotifications.skip(1)) {
              await SupabaseConfig.client
                  .from(_tableName)
                  .delete()
                  .eq('id', duplicate.id);
            }
          }
          return existingNotifications.first;
        }
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(notificationData)
          .select()
          .single();

      if (response == null) return null;
      return Notification.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Future<Notification?> updateNotification(
      String notificationId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', notificationId)
          .select()
          .single();

      if (response == null) return null;
      return Notification.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }

  static Future<bool> deleteNotification(String notificationId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', notificationId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
}
