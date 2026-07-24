import 'package:hr_management_system/core/utils/payroll_calculation.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

void main() {
  final records = <Attendance>[];
  for (int day = 1; day <= 31; day++) {
    final date = DateTime(2026, 7, day);
    if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
      continue;
    }
    records.add(Attendance(id: 'p-$day', employeeId: 'emp-1', date: date, status: AttendanceStatus.present, createdAt: date));
  }
  final deduction = calculateAttendanceDeduction(baseSalary: 30000, employeeId: 'emp-1', month: 7, year: 2026, attendanceRecords: records, weeklyHolidays: [DateTime.sunday]);
  print('deduction=$deduction');
  print('count=${records.length}');
}
