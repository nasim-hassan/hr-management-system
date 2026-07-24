import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/core/utils/leave_request_validation.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/notification_model.dart';
import 'package:hr_management_system/data/services/notification_service.dart';
import 'package:hr_management_system/data/services/employee_service.dart';

class LeaveRequestService {
  static const String _tableName = 'leave_requests';

  static Future<List<LeaveRequest>> getAllLeaveRequests() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => LeaveRequest.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch leave requests: $e');
    }
  }

  static Future<LeaveRequest?> fetchLeaveRequestById(String requestId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', requestId)
          .maybeSingle();

      if (response == null) return null;
      return LeaveRequest.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch leave request: $e');
    }
  }

  static Future<LeaveRequest?> createLeaveRequest(
      LeaveRequest leaveRequest) async {
    try {
      final existing = await getAllLeaveRequests();
      final validationResult = validateLeaveRequestRange(
        employeeId: leaveRequest.employeeId,
        startDate: leaveRequest.startDate,
        endDate: leaveRequest.endDate,
        existingRequests: existing,
        currentRequestId: null,
      );

      if (validationResult != null && !validationResult.isValid) {
        throw Exception(validationResult.message);
      }

      final data = leaveRequest.toJson();
      if (leaveRequest.id.startsWith('leave_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;

      final createdRequest =
          LeaveRequest.fromJson(response as Map<String, dynamic>);
      if (createdRequest.status == LeaveStatus.approved) {
        await _triggerLeaveApprovedNotifications(createdRequest);
      }

      return createdRequest;
    } catch (e) {
      throw Exception('Failed to create leave request: $e');
    }
  }

  static Future<LeaveRequest?> updateLeaveRequest(
      String requestId, Map<String, dynamic> data) async {
    try {
      final existing = await getAllLeaveRequests();
      final requestToUpdate =
          existing.firstWhere((item) => item.id == requestId);
      final validationResult = validateLeaveRequestRange(
        employeeId:
            data['employee_id']?.toString() ?? requestToUpdate.employeeId,
        startDate: DateTime.parse(data['start_date'].toString()),
        endDate: DateTime.parse(data['end_date'].toString()),
        existingRequests:
            existing.where((item) => item.id != requestId).toList(),
        currentRequestId: requestId,
      );

      if (validationResult != null && !validationResult.isValid) {
        throw Exception(validationResult.message);
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', requestId)
          .select()
          .single();

      if (response == null) return null;

      final updatedRequest =
          LeaveRequest.fromJson(response as Map<String, dynamic>);
      if (updatedRequest.status == LeaveStatus.approved &&
          requestToUpdate.status != LeaveStatus.approved) {
        await _triggerLeaveApprovedNotifications(updatedRequest);
      }

      return updatedRequest;
    } catch (e) {
      throw Exception('Failed to update leave request: $e');
    }
  }

  static Future<bool> deleteLeaveRequest(String requestId) async {
    try {
      await SupabaseConfig.client.from(_tableName).delete().eq('id', requestId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete leave request: $e');
    }
  }

  static Future<void> _triggerLeaveApprovedNotifications(
      LeaveRequest request) async {
    try {
      final employee =
          await EmployeeService.fetchEmployeeById(request.employeeId);
      final employeeName = employee?.fullName ?? 'An employee';

      final existingNotificationsResponse = await SupabaseConfig.client
          .from('notifications')
          .select('id, user_id')
          .eq('related_id', request.id)
          .eq('type', NotificationType.leaveApproved.toStringValue());

      final existingNotificationsByUser = <String, List<String>>{};
      if (existingNotificationsResponse != null &&
          existingNotificationsResponse is List) {
        for (final notif in existingNotificationsResponse) {
          final userId = notif['user_id'] as String?;
          final notifId = notif['id'] as String?;
          if (userId != null && notifId != null) {
            existingNotificationsByUser
                .putIfAbsent(userId, () => [])
                .add(notifId);
          }
        }
      }

      final usersResponse = await SupabaseConfig.client
          .from('users')
          .select('id')
          .or('role.eq.hrAdmin,role.eq.manager');

      final userIds = <String>{};
      if (usersResponse != null && usersResponse is List) {
        for (final u in usersResponse) {
          final userId = u['id'] as String?;
          if (userId != null) {
            userIds.add(userId);
          }
        }
      }

      for (final userId in userIds) {
        final existingIds = existingNotificationsByUser[userId];
        if (existingIds != null && existingIds.isNotEmpty) {
          if (existingIds.length > 1) {
            // Remove duplicate notifications if they already exist for this user.
            for (final duplicateId in existingIds.skip(1)) {
              await SupabaseConfig.client
                  .from('notifications')
                  .delete()
                  .eq('id', duplicateId);
            }
          }
          continue;
        }

        await NotificationService.createNotification(
          Notification(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}_${userId.hashCode}',
            userId: userId,
            type: NotificationType.leaveApproved,
            title: 'Leave Approved',
            message: "$employeeName's leave request has been approved.",
            relatedId: request.id,
            relatedType: 'leave_request',
            isRead: false,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      print('Error triggering notifications: $e');
    }
  }
}
