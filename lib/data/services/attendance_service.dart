import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';

class AttendanceService {
  static const String _tableName = 'attendance';

  static Future<List<Attendance>> getAllAttendance() async {
    try {
      print('📅 [ATTENDANCE SERVICE] Fetching all attendance records...');
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('date', ascending: false)
          .order('check_in_time', ascending: false);

      print('📅 [ATTENDANCE SERVICE] Raw response type: ${response.runtimeType}');
      print('📅 [ATTENDANCE SERVICE] Raw response: $response');

      if (response == null) {
        print('⚠️  [ATTENDANCE SERVICE] Response is null');
        return [];
      }
      
      if (response is! List) {
        print('⚠️  [ATTENDANCE SERVICE] Response is not a List: ${response.runtimeType}');
        return [];
      }

      print('📅 [ATTENDANCE SERVICE] Found ${response.length} attendance records');
      
      final attendanceList = (response)
          .map((item) {
            print('📅 [ATTENDANCE SERVICE] Processing attendance item: ${item['id']}');
            return Attendance.fromJson(item as Map<String, dynamic>);
          })
          .toList();
      
      print('✅ [ATTENDANCE SERVICE] Successfully parsed ${attendanceList.length} records');
      return attendanceList;
    } catch (e) {
      print('❌ [ATTENDANCE SERVICE] Error fetching attendance: $e');
      throw Exception('Failed to fetch attendance records: $e');
    }
  }

  static Future<List<Attendance>> getAttendanceForEmployee(String employeeId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('employee_id', employeeId)
          .order('date', ascending: false);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => Attendance.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch attendance for employee: $e');
    }
  }

  static Future<Attendance?> createAttendance(Attendance attendance) async {
    try {
      final data = attendance.toJson();
      if (attendance.id.startsWith('att_')) {
        data.remove('id'); // let Postgres generate UUID
      }

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;
      return Attendance.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to insert attendance record: $e');
    }
  }

  static Future<Attendance?> updateAttendance(String attendanceId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', attendanceId)
          .select()
          .single();

      if (response == null) return null;
      return Attendance.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update attendance record: $e');
    }
  }

  static Future<bool> deleteAttendance(String attendanceId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', attendanceId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete attendance record: $e');
    }
  }
}
