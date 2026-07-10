import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';

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

  static Future<LeaveRequest?> createLeaveRequest(LeaveRequest leaveRequest) async {
    try {
      final data = leaveRequest.toJson();
      if (leaveRequest.id.startsWith('leave_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;
      return LeaveRequest.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create leave request: $e');
    }
  }

  static Future<LeaveRequest?> updateLeaveRequest(String requestId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', requestId)
          .select()
          .single();

      if (response == null) return null;
      return LeaveRequest.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update leave request: $e');
    }
  }

  static Future<bool> deleteLeaveRequest(String requestId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', requestId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete leave request: $e');
    }
  }
}
