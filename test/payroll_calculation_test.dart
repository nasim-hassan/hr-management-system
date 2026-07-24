import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/core/utils/payroll_calculation.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/holiday_model.dart';

void main() {
  List<Attendance> buildWorkingDayRecords({
    DateTime? absentDate,
    DateTime? halfDayDate,
    DateTime? holidayDate,
  }) {
    final records = <Attendance>[];
    for (int day = 1; day <= 31; day++) {
      final date = DateTime(2026, 7, day);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      if (date.day == absentDate?.day && date.month == absentDate?.month) {
        records.add(
          Attendance(
            id: 'absent-$day',
            employeeId: 'emp-1',
            date: date,
            status: AttendanceStatus.absent,
            createdAt: date,
          ),
        );
      } else if (date.day == halfDayDate?.day && date.month == halfDayDate?.month) {
        records.add(
          Attendance(
            id: 'half-$day',
            employeeId: 'emp-1',
            date: date,
            status: AttendanceStatus.halfDay,
            createdAt: date,
          ),
        );
      } else {
        records.add(
          Attendance(
            id: 'present-$day',
            employeeId: 'emp-1',
            date: date,
            status: AttendanceStatus.present,
            createdAt: date,
          ),
        );
      }
    }
    return records;
  }

  group('attendance-based payroll deductions', () {
    test('calculates net salary by subtracting attendance-based deductions', () {
      final netSalary = calculatePayrollNetSalary(
        baseSalary: 30000,
        bonus: 5000,
        allowances: 2000,
        autoDeductions: 1000,
      );

      expect(netSalary, 36000);
    });

    test('uses working days excluding weekends for the daily salary rate', () {
      final records = buildWorkingDayRecords(absentDate: DateTime(2026, 7, 1));

      final deduction = calculateAttendanceDeduction(
        baseSalary: 30000,
        employeeId: 'emp-1',
        month: 7,
        year: 2026,
        attendanceRecords: records,
      );

      final workingDaysInMonth = 23;
      final expectedDeduction = 30000 * 1 / workingDaysInMonth;

      expect(deduction, closeTo(expectedDeduction, 0.01));
    });

    test('does not count holiday dates as absent deductions', () {
      final records = buildWorkingDayRecords(absentDate: DateTime(2026, 7, 1));

      final deduction = calculateAttendanceDeduction(
        baseSalary: 30000,
        employeeId: 'emp-1',
        month: 7,
        year: 2026,
        attendanceRecords: records,
        holidays: [
          Holiday(id: 'h1', name: 'Holiday', date: DateTime(2026, 7, 2)),
        ],
      );

      final workingDaysInMonth = 23;
      final expectedDeduction = 30000 * 1 / workingDaysInMonth;

      expect(deduction, closeTo(expectedDeduction, 0.01));
    });

    test('deducts a full day for absent attendance and half day for half-day attendance', () {
      final records = buildWorkingDayRecords(
        absentDate: DateTime(2026, 7, 1),
        halfDayDate: DateTime(2026, 7, 3),
      );

      final deduction = calculateAttendanceDeduction(
        baseSalary: 30000,
        employeeId: 'emp-1',
        month: 7,
        year: 2026,
        attendanceRecords: records,
      );

      final workingDaysInMonth = 23;
      final expectedDeduction = 30000 * 1.5 / workingDaysInMonth;

      expect(deduction, closeTo(expectedDeduction, 0.01));
    });

    test('treats configured weekly holidays as paid days', () {
      final records = buildWorkingDayRecords();

      final deduction = calculateAttendanceDeduction(
        baseSalary: 30000,
        employeeId: 'emp-1',
        month: 7,
        year: 2026,
        attendanceRecords: records,
        weeklyHolidays: [DateTime.sunday],
      );

      expect(deduction, 0.0);
    });

    test('adds a daily-pay adjustment when an employee is present on a weekly holiday', () {
      final records = <Attendance>[
        Attendance(
          id: 'present-sun',
          employeeId: 'emp-1',
          date: DateTime(2026, 7, 5),
          status: AttendanceStatus.present,
          createdAt: DateTime(2026, 7, 5),
        ),
      ];

      final deduction = calculateAttendanceDeduction(
        baseSalary: 30000,
        employeeId: 'emp-1',
        month: 7,
        year: 2026,
        attendanceRecords: records,
        weeklyHolidays: [DateTime.sunday],
      );

      expect(deduction, closeTo(30000 - (30000 / 23), 0.01));
    });
  });
}
