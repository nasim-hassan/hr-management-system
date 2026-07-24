import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/data/providers/attendance_provider.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/data/providers/leave_request_provider.dart';
import 'package:hr_management_system/data/providers/payroll_provider.dart';

Map<String, int> buildEmployeeAnalytics(List<Employee> employees) {
  final departmentSet = <String>{};
  var activeEmployees = 0;

  for (final employee in employees) {
    if (employee.department != null && employee.department!.trim().isNotEmpty) {
      departmentSet.add(employee.department!.trim());
    }
    if (employee.isActive) {
      activeEmployees++;
    }
  }

  return {
    'totalEmployees': employees.length,
    'activeEmployees': activeEmployees,
    'departmentCount': departmentSet.length,
  };
}

Map<String, int> buildAttendanceSummary(List<Attendance> attendanceList) {
  final summary = <String, int>{
    'present': 0,
    'remote': 0,
    'halfDay': 0,
    'onLeave': 0,
    'absent': 0,
  };

  for (final attendance in attendanceList) {
    switch (attendance.status) {
      case AttendanceStatus.present:
        summary['present'] = summary['present']! + 1;
        break;
      case AttendanceStatus.remote:
        summary['remote'] = summary['remote']! + 1;
        break;
      case AttendanceStatus.halfDay:
        summary['halfDay'] = summary['halfDay']! + 1;
        break;
      case AttendanceStatus.onLeave:
        summary['onLeave'] = summary['onLeave']! + 1;
        break;
      case AttendanceStatus.absent:
        summary['absent'] = summary['absent']! + 1;
        break;
    }
  }

  return summary;
}

Map<String, double> buildPayrollSummary(List<Payroll> payrollList) {
  final totalPayrollValue = payrollList.fold<double>(0, (sum, payroll) => sum + payroll.netSalary);
  final paidPayrollValue = payrollList
      .where((payroll) => payroll.isPaid)
      .fold<double>(0, (sum, payroll) => sum + payroll.netSalary);
  final pendingPayrollValue = totalPayrollValue - paidPayrollValue;

  return {
    'totalPayrollValue': totalPayrollValue,
    'paidPayrollValue': paidPayrollValue,
    'pendingPayrollValue': pendingPayrollValue,
  };
}

Map<String, int> buildLeaveSummary(List<LeaveRequest> leaveRequestList) {
  final summary = <String, int>{
    'pending': 0,
    'approved': 0,
    'rejected': 0,
    'cancelled': 0,
  };

  for (final leave in leaveRequestList) {
    switch (leave.status) {
      case LeaveStatus.pending:
        summary['pending'] = summary['pending']! + 1;
        break;
      case LeaveStatus.approved:
        summary['approved'] = summary['approved']! + 1;
        break;
      case LeaveStatus.rejected:
        summary['rejected'] = summary['rejected']! + 1;
        break;
      case LeaveStatus.cancelled:
        summary['cancelled'] = summary['cancelled']! + 1;
        break;
    }
  }

  return summary;
}

class ReportListScreen extends ConsumerWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final leaveRequestState = ref.watch(leaveRequestProvider);
    final payrollState = ref.watch(payrollProvider);

    final employeeAnalytics = buildEmployeeAnalytics(employeeState.employees);
    final attendanceSummary = buildAttendanceSummary(attendanceState.attendanceList);
    final leaveSummary = buildLeaveSummary(leaveRequestState.leaveRequests);
    final payrollSummary = buildPayrollSummary(payrollState.payrolls);

    final totalEmployees = employeeAnalytics['totalEmployees'] ?? 0;
    final activeEmployees = employeeAnalytics['activeEmployees'] ?? 0;
    final departmentCount = employeeAnalytics['departmentCount'] ?? 0;
    final totalAttendanceRecords = attendanceState.attendanceList.length;
    final totalLeaveRequests = leaveRequestState.leaveRequests.length;
    final totalPayrollValue = payrollSummary['totalPayrollValue'] ?? 0.0;
    final paidPayrollValue = payrollSummary['paidPayrollValue'] ?? 0.0;
    final pendingPayrollValue = payrollSummary['pendingPayrollValue'] ?? 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto-generated HR Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _SummaryStatCard(
                  title: 'Total Employees',
                  value: totalEmployees.toString(),
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _SummaryStatCard(
                  title: 'Active Employees',
                  value: activeEmployees.toString(),
                  icon: Icons.verified_user,
                  color: Colors.green,
                ),
                _SummaryStatCard(
                  title: 'Attendance Records',
                  value: totalAttendanceRecords.toString(),
                  icon: Icons.fact_check,
                  color: Colors.orange,
                ),
                _SummaryStatCard(
                  title: 'Leave Requests',
                  value: totalLeaveRequests.toString(),
                  icon: Icons.calendar_month,
                  color: Colors.purple,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Workforce Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Departments', departmentCount.toString(), Colors.blue),
                    _InfoRow('Present Today', (attendanceSummary['present'] ?? 0).toString(), Colors.green),
                    _InfoRow('Remote Today', (attendanceSummary['remote'] ?? 0).toString(), Colors.indigo),
                    _InfoRow('On Leave Today', (attendanceSummary['onLeave'] ?? 0).toString(), Colors.orange),
                    _InfoRow('Absent Today', (attendanceSummary['absent'] ?? 0).toString(), Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Attendance Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _ProgressRow('Present', attendanceSummary['present'] ?? 0, Colors.green),
                    _ProgressRow('Remote', attendanceSummary['remote'] ?? 0, Colors.indigo),
                    _ProgressRow('Half Day', attendanceSummary['halfDay'] ?? 0, Colors.orange),
                    _ProgressRow('On Leave', attendanceSummary['onLeave'] ?? 0, Colors.purple),
                    _ProgressRow('Absent', attendanceSummary['absent'] ?? 0, Colors.red),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Leave Status Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Pending', (leaveSummary['pending'] ?? 0).toString(), Colors.orange),
                    _InfoRow('Approved', (leaveSummary['approved'] ?? 0).toString(), Colors.green),
                    _InfoRow('Rejected', (leaveSummary['rejected'] ?? 0).toString(), Colors.red),
                    _InfoRow('Cancelled', (leaveSummary['cancelled'] ?? 0).toString(), Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payroll Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow('Total Payroll Value', '\৳${totalPayrollValue.toStringAsFixed(0)}', Colors.blue),
                    _InfoRow('Paid Payroll', '\৳${paidPayrollValue.toStringAsFixed(0)}', Colors.green),
                    _InfoRow('Pending Payroll', '\৳${pendingPayrollValue.toStringAsFixed(0)}', Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InfoRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _ProgressRow(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(value.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value > 0 ? 1 : 0,
              minHeight: 8,
              color: color,
              backgroundColor: color.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
