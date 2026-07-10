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

  static Future<Notification?> fetchNotificationById(String notificationId) async {
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

  static Future<Notification?> createNotification(Notification notification) async {
    try {
      final data = notification.toJson();
      if (notification.id.startsWith('notif_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;
      return Notification.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  static Future<Notification?> updateNotification(String notificationId, Map<String, dynamic> data) async {
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
