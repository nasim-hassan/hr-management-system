import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/presentation/screens/report_list_screen.dart';

void main() {
  group('report analytics helpers', () {
    test('buildEmployeeAnalytics aggregates active employees and departments', () {
      final employees = [
        Employee(
          id: '1001',
          userId: 'user-1',
          firstName: 'Alice',
          lastName: 'A',
          email: 'alice@example.com',
          phoneNumber: '123',
          isActive: true,
          createdAt: DateTime.now(),
          department: 'Engineering',
        ),
        Employee(
          id: '1002',
          userId: 'user-2',
          firstName: 'Bob',
          lastName: 'B',
          email: 'bob@example.com',
          phoneNumber: '123',
          isActive: true,
          createdAt: DateTime.now(),
          department: 'Engineering',
        ),
        Employee(
          id: '1003',
          userId: 'user-3',
          firstName: 'Cara',
          lastName: 'C',
          email: 'cara@example.com',
          phoneNumber: '123',
          isActive: false,
          createdAt: DateTime.now(),
          department: 'HR',
        ),
      ];

      final analytics = buildEmployeeAnalytics(employees);

      expect(analytics['totalEmployees'], 3);
      expect(analytics['activeEmployees'], 2);
      expect(analytics['departmentCount'], 2);
    });

    test('buildAttendanceSummary counts daily attendance status buckets', () {
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

      final analytics = buildAttendanceSummary(attendanceList);

      expect(analytics['present'], 1);
      expect(analytics['onLeave'], 1);
      expect(analytics['absent'], 1);
    });

    test('buildPayrollSummary calculates cashflow totals from payroll records', () {
      final payrollList = [
        Payroll(
          id: '1',
          employeeId: '1001',
          month: 7,
          year: 2026,
          baseSalary: 1000,
          netSalary: 1000,
          paymentDate: DateTime.now(),
          isPaid: true,
          createdAt: DateTime.now(),
        ),
        Payroll(
          id: '2',
          employeeId: '1002',
          month: 7,
          year: 2026,
          baseSalary: 2000,
          netSalary: 2000,
          paymentDate: DateTime.now(),
          isPaid: false,
          createdAt: DateTime.now(),
        ),
      ];

      final analytics = buildPayrollSummary(payrollList);

      expect(analytics['totalPayrollValue'], 3000);
      expect(analytics['paidPayrollValue'], 1000);
      expect(analytics['pendingPayrollValue'], 2000);
    });

    test('buildLeaveSummary counts leave requests by status', () {
      final leaveList = [
        LeaveRequest(
          id: '1',
          employeeId: '1001',
          leaveType: LeaveType.casual,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          numberOfDays: 2,
          reason: 'Test',
          status: LeaveStatus.pending,
          createdAt: DateTime.now(),
        ),
        LeaveRequest(
          id: '2',
          employeeId: '1002',
          leaveType: LeaveType.sick,
          startDate: DateTime.now(),
          endDate: DateTime.now().add(const Duration(days: 1)),
          numberOfDays: 2,
          reason: 'Test',
          status: LeaveStatus.approved,
          createdAt: DateTime.now(),
        ),
      ];

      final analytics = buildLeaveSummary(leaveList);

      expect(analytics['pending'], 1);
      expect(analytics['approved'], 1);
    });
  });
}
