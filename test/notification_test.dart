import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/notification_model.dart';

void main() {
  group('Notification Model Tests', () {
    test('converts Notification to/from JSON correctly', () {
      final now = DateTime.now();
      final notification = Notification(
        id: 'test-123',
        userId: 'user-456',
        type: NotificationType.leaveApproved,
        title: 'Leave Approved',
        message: 'Your leave request has been approved.',
        relatedId: 'leave-789',
        relatedType: 'leave_request',
        isRead: false,
        createdAt: now,
      );

      final json = notification.toJson();
      expect(json['id'], 'test-123');
      expect(json['user_id'], 'user-456');
      expect(json['type'], 'leaveApproved');
      expect(json['is_read'], false);

      final fromJson = Notification.fromJson(json);
      expect(fromJson.id, notification.id);
      expect(fromJson.userId, notification.userId);
      expect(fromJson.type, notification.type);
      expect(fromJson.title, notification.title);
      expect(fromJson.message, notification.message);
      expect(fromJson.relatedId, notification.relatedId);
      expect(fromJson.relatedType, notification.relatedType);
      expect(fromJson.isRead, notification.isRead);
      expect(fromJson.createdAt.day, notification.createdAt.day);
    });

    test('NotificationType fromString converts correctly', () {
      expect(NotificationType.fromString('leaveApproved'), NotificationType.leaveApproved);
      expect(NotificationType.fromString('leaveRejected'), NotificationType.leaveRejected);
      expect(NotificationType.fromString('invalidEnum'), NotificationType.announcement);
    });
  });
}
