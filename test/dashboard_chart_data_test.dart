import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/presentation/screens/dashboard_screen.dart';

void main() {
  group('dashboard chart data helpers', () {
    test('buildAttendanceTrendSpots aggregates attendance by recent days', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));

      final attendanceList = [
        Attendance(
          id: '1',
          employeeId: '1001',
          date: today,
          status: AttendanceStatus.present,
          createdAt: now,
        ),
        Attendance(
          id: '2',
          employeeId: '1002',
          date: yesterday,
          status: AttendanceStatus.remote,
          createdAt: now,
        ),
        Attendance(
          id: '3',
          employeeId: '1003',
          date: yesterday,
          status: AttendanceStatus.absent,
          createdAt: now,
        ),
      ];

      final spots = buildAttendanceTrendSpots(attendanceList, days: 2);

      expect(spots.length, 2);
      expect(spots[0].y, 1);
      expect(spots[1].y, 1);
    });

    test('buildAttendanceDistributionData groups statuses into chart buckets', () {
      final attendanceList = [
        Attendance(
          id: '1',
          employeeId: '1001',
          date: DateTime.now(),
          status: AttendanceStatus.present,
          createdAt: DateTime.now(),
        ),
        Attendance(
          id: '2',
          employeeId: '1002',
          date: DateTime.now(),
          status: AttendanceStatus.onLeave,
          createdAt: DateTime.now(),
        ),
        Attendance(
          id: '3',
          employeeId: '1003',
          date: DateTime.now(),
          status: AttendanceStatus.absent,
          createdAt: DateTime.now(),
        ),
      ];

      final distribution = buildAttendanceDistributionData(attendanceList);

      expect(distribution['Present'], 1);
      expect(distribution['On Leave'], 1);
      expect(distribution['Absent'], 1);
    });
  });
}
