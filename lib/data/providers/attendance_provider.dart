import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/services/attendance_service.dart';

class AttendanceState {
  final List<Attendance> attendanceList;
  final bool isLoading;
  final String? error;

  AttendanceState({
    this.attendanceList = const [],
    this.isLoading = false,
    this.error,
  });

  AttendanceState copyWith({
    List<Attendance>? attendanceList,
    bool? isLoading,
    String? error,
  }) {
    return AttendanceState(
      attendanceList: attendanceList ?? this.attendanceList,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier() : super(AttendanceState()) {
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    print('🔄 [ATTENDANCE PROVIDER] Loading attendance records...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await AttendanceService.getAllAttendance();
      print('✅ [ATTENDANCE PROVIDER] Loaded ${records.length} attendance records');
      state = state.copyWith(attendanceList: records, isLoading: false);
    } catch (e) {
      print('❌ [ATTENDANCE PROVIDER] Error loading attendance: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addAttendance(Attendance attendance) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRecord = await AttendanceService.createAttendance(attendance);
      if (newRecord != null) {
        state = state.copyWith(
          attendanceList: [newRecord, ...state.attendanceList],
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to save attendance record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateAttendance(Attendance attendance) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await AttendanceService.updateAttendance(attendance.id, {
        'employee_id': attendance.employeeId,
        'date': attendance.date.toIso8601String(),
        'check_in_time': attendance.checkInTime?.toIso8601String(),
        'check_out_time': attendance.checkOutTime?.toIso8601String(),
        'status': attendance.status.toStringValue(),
        'notes': attendance.notes,
        'location': attendance.location,
        'latitude': attendance.latitude,
        'longitude': attendance.longitude,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (updated != null) {
        state = state.copyWith(
          attendanceList: state.attendanceList.map((a) => a.id == attendance.id ? updated : a).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update attendance record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteAttendance(String attendanceId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await AttendanceService.deleteAttendance(attendanceId);
      if (success) {
        state = state.copyWith(
          attendanceList: state.attendanceList.where((a) => a.id != attendanceId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete attendance record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier();
});
