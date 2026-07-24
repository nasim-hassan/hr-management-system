import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/holiday_model.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';

double calculatePayrollNetSalary({
  required double baseSalary,
  required double bonus,
  required double allowances,
  required double autoDeductions,
  double manualDeductions = 0.0,
}) {
  return baseSalary + bonus + allowances - manualDeductions - autoDeductions;
}

bool _isHolidayDate(DateTime date, List<Holiday> holidays) {
  return holidays.any((holiday) {
    final holidayStart = DateTime(holiday.date.year, holiday.date.month, holiday.date.day);
    final holidayEnd = holiday.endDate != null
        ? DateTime(holiday.endDate!.year, holiday.endDate!.month, holiday.endDate!.day)
        : holidayStart;
    return !date.isBefore(holidayStart) && !date.isAfter(holidayEnd);
  });
}

double calculateAttendanceDeduction({
  required double baseSalary,
  required String employeeId,
  required int month,
  required int year,
  required List<Attendance> attendanceRecords,
  List<Holiday> holidays = const [],
  List<LeaveRequest> approvedLeaveRequests = const [],
  List<int> weeklyHolidays = const [DateTime.saturday, DateTime.sunday],
  double dailyDeductionRate = 1.0,
}) {
  final monthRecords = attendanceRecords.where((record) {
    return record.employeeId == employeeId &&
        record.date.year == year &&
        record.date.month == month;
  }).toList();

  final calendarDaysInMonth = DateTime(year, month + 1, 0).day;
  final workingDays = <DateTime>[];
  final effectiveWeeklyHolidays = {
    DateTime.saturday,
    DateTime.sunday,
    ...weeklyHolidays,
  }.toList();

  for (int day = 1; day <= calendarDaysInMonth; day++) {
    final currentDate = DateTime(year, month, day);

    final isWeeklyHoliday = effectiveWeeklyHolidays.contains(currentDate.weekday);
    if (isWeeklyHoliday) {
      continue;
    }

    workingDays.add(currentDate);
  }

  if (workingDays.isEmpty) {
    return 0.0;
  }

  final dailyRate = baseSalary / workingDays.length;
  double deduction = 0.0;

  for (final currentDate in workingDays) {
    if (_isHolidayDate(currentDate, holidays)) {
      continue;
    }

    final hasApprovedLeave = approvedLeaveRequests.any((request) {
      return request.employeeId == employeeId &&
          request.status == LeaveStatus.approved &&
          !currentDate.isBefore(request.startDate) &&
          !currentDate.isAfter(request.endDate);
    });

    if (hasApprovedLeave) {
      continue;
    }

    final record = monthRecords.firstWhere(
      (entry) => entry.date.year == currentDate.year &&
          entry.date.month == currentDate.month &&
          entry.date.day == currentDate.day,
      orElse: () => Attendance(
        id: '',
        employeeId: employeeId,
        date: currentDate,
        status: AttendanceStatus.absent,
        createdAt: currentDate,
      ),
    );

    switch (record.status) {
      case AttendanceStatus.present:
      case AttendanceStatus.remote:
        break;
      case AttendanceStatus.halfDay:
        deduction += dailyRate * 0.5;
        break;
      case AttendanceStatus.onLeave:
      case AttendanceStatus.absent:
        deduction += dailyRate;
        break;
    }
  }

  for (int day = 1; day <= calendarDaysInMonth; day++) {
    final currentDate = DateTime(year, month, day);
    final isWeeklyHoliday = effectiveWeeklyHolidays.contains(currentDate.weekday);
    if (!isWeeklyHoliday) {
      continue;
    }

    final record = monthRecords.firstWhere(
      (entry) => entry.date.year == currentDate.year &&
          entry.date.month == currentDate.month &&
          entry.date.day == currentDate.day,
      orElse: () => Attendance(
        id: '',
        employeeId: employeeId,
        date: currentDate,
        status: AttendanceStatus.absent,
        createdAt: currentDate,
      ),
    );

    if (record.status == AttendanceStatus.present || record.status == AttendanceStatus.remote) {
      deduction -= dailyRate;
    }
  }

  return deduction;
}
