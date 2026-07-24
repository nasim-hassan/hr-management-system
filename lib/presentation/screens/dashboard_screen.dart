import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hr_management_system/config/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/providers/attendance_provider.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/data/providers/leave_request_provider.dart';
import 'package:hr_management_system/data/providers/payroll_provider.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

List<FlSpot> buildAttendanceTrendSpots(List<Attendance> attendanceList, {int days = 7}) {
  if (attendanceList.isEmpty || days <= 0) {
    return const [];
  }

  final today = DateTime.now();
  final startDate = DateTime(today.year, today.month, today.day).subtract(Duration(days: days - 1));
  final points = <FlSpot>[];

  for (int index = 0; index < days; index++) {
    final date = startDate.add(Duration(days: index));
    final dayRecords = attendanceList.where((attendance) {
      final attendanceDate = DateTime(
        attendance.date.year,
        attendance.date.month,
        attendance.date.day,
      );
      return attendanceDate.year == date.year &&
          attendanceDate.month == date.month &&
          attendanceDate.day == date.day;
    }).toList();

    final activeCount = dayRecords.where((attendance) {
      return attendance.status == AttendanceStatus.present ||
          attendance.status == AttendanceStatus.remote ||
          attendance.status == AttendanceStatus.halfDay;
    }).length;

    points.add(FlSpot(index.toDouble(), activeCount.toDouble()));
  }

  return points;
}

Map<String, int> buildAttendanceDistributionData(List<Attendance> attendanceList) {
  final distribution = <String, int>{
    'Present': 0,
    'Remote': 0,
    'Half Day': 0,
    'On Leave': 0,
    'Absent': 0,
  };

  for (final attendance in attendanceList) {
    switch (attendance.status) {
      case AttendanceStatus.present:
        distribution['Present'] = distribution['Present']! + 1;
        break;
      case AttendanceStatus.remote:
        distribution['Remote'] = distribution['Remote']! + 1;
        break;
      case AttendanceStatus.halfDay:
        distribution['Half Day'] = distribution['Half Day']! + 1;
        break;
      case AttendanceStatus.onLeave:
        distribution['On Leave'] = distribution['On Leave']! + 1;
        break;
      case AttendanceStatus.absent:
        distribution['Absent'] = distribution['Absent']! + 1;
        break;
    }
  }

  return distribution;
}

/// Admin Dashboard Screen - Professional with Analytics
class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final leaveRequestState = ref.watch(leaveRequestProvider);
    final payrollState = ref.watch(payrollProvider);

    final today = DateTime.now();
    final totalEmployees = employeeState.employees.length;
    final attendanceToday = attendanceState.attendanceList.where((attendance) {
      final date = attendance.date;
      return date.year == today.year && date.month == today.month && date.day == today.day;
    }).length;
    final pendingLeaveRequests = leaveRequestState.leaveRequests
        .where((leave) => leave.status == LeaveStatus.pending)
        .length;
    final pendingPayrolls = payrollState.payrolls.where((payroll) => !payroll.isPaid).length;
    final attendanceTrendSpots = buildAttendanceTrendSpots(attendanceState.attendanceList, days: 7);
    final attendanceDistribution = buildAttendanceDistributionData(attendanceState.attendanceList);
    final distributionEntries = attendanceDistribution.entries
        .where((entry) => entry.value > 0)
        .toList();
    final hasAttendanceData = attendanceState.attendanceList.isNotEmpty;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Nasim Hassan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'HR Administrator',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Cards - 2x2 Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2, // wide cards
                children: [
                  _SmallStatCard(
                    title: 'Total Employees',
                    value: totalEmployees.toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _SmallStatCard(
                    title: 'Attendance Today',
                    value: attendanceToday.toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _SmallStatCard(
                    title: 'Pending Leaves',
                    value: pendingLeaveRequests.toString(),
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                  _SmallStatCard(
                    title: 'Pending Payrolls',
                    value: pendingPayrolls.toString(),
                    icon: Icons.payments,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            // Analytics Section Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text(
                    'Analytics Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Chip(
                    label: const Text('This Week'),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ],
              ),
            ),

            // Attendance Trend Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Attendance Trend',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (attendanceState.isLoading)
                        const SizedBox(
                          height: 180,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (!hasAttendanceData)
                        const SizedBox(
                          height: 180,
                          child: Center(child: Text('No attendance data available yet.')),
                        )
                      else
                        SizedBox(
                          height: 180,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      final index = value.toInt();
                                      if (index < 0 || index >= attendanceTrendSpots.length) {
                                        return const SizedBox.shrink();
                                      }
                                      final date = DateTime.now().subtract(
                                        Duration(days: attendanceTrendSpots.length - 1 - index),
                                      );
                                      return Text(
                                        '${date.day}',
                                        style: const TextStyle(fontSize: 12),
                                      );
                                    },
                                    reservedSize: 30,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: attendanceTrendSpots,
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Leave Distribution Pie Chart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leave Distribution',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (!hasAttendanceData)
                        const SizedBox(
                          height: 200,
                          child: Center(child: Text('No attendance distribution available yet.')),
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: PieChart(
                                PieChartData(
                                  sections: distributionEntries.map((entry) {
                                    final total = distributionEntries.fold<double>(0, (sum, item) => sum + item.value.toDouble());
                                    final value = total > 0 ? entry.value.toDouble() : 0.0;
                                    final percentage = total > 0 ? (entry.value / total * 100).round() : 0;
                                    final color = _chartColorFor(entry.key);
                                    return PieChartSectionData(
                                      value: value,
                                      color: color,
                                      title: '${entry.key}\n($percentage%)',
                                      radius: 50,
                                      titleStyle: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }).toList(),
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: distributionEntries.map((entry) {
                                final color = _chartColorFor(entry.key);
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text('${entry.key}: ${entry.value}'),
                                  ],
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.people,
                    label: 'Employee Directory',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.employees),
                  ),
                  _QuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Employee',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.editEmployee.replaceAll(':id', 'new'),
                    ),
                  ),
                  _QuickActionButton(
                    icon: Icons.assignment,
                    label: 'Review Leave Requests',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.leaveRequests),
                  ),
                  _QuickActionButton(
                    icon: Icons.assessment,
                    label: 'Generate Reports',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.reports),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Manager Dashboard Screen
class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final employees = employeeState.employees;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Ramim Rashid',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Team Manager',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Team Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: const [
                  _SmallStatCard(
                    title: 'Team Members',
                    value: '3',
                    icon: Icons.group,
                    color: Colors.blue,
                  ),
                  _SmallStatCard(
                    title: 'Leave Requests',
                    value: '2',
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),

            // Team Attendance
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Attendance Today',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...employees.map((emp) => Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(emp.fullName),
                          subtitle: Text(emp.email),
                          trailing: const Chip(
                            label: Text('Present'),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Employee Dashboard Screen
class EmployeeDashboardScreen extends ConsumerWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeeState = ref.watch(employeeProvider);
    final attendanceState = ref.watch(attendanceProvider);
    final Employee employee = employeeState.employees.isNotEmpty
        ? employeeState.employees.first
        : Employee(
            id: 'unknown',
            userId: '',
            firstName: 'Unknown',
            lastName: 'User',
            email: '',
            phoneNumber: '',
            isActive: true,
            createdAt: DateTime.now(),
          );
    final recentAttendance = attendanceState.attendanceList
        .where((attendance) => attendance.employeeId == employee.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Dashboard'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Emon Khan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employee.email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.2,
                children: [
                  _SmallStatCard(
                    title: 'Phone',
                    value: employee.phoneNumber,
                    icon: Icons.phone,
                    color: Colors.blue,
                  ),
                  _SmallStatCard(
                    title: 'Recent Attendance',
                    value: '${recentAttendance.length} Records',
                    icon: Icons.calendar_today,
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Actions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.login,
                    label: 'Check In',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.logout,
                    label: 'Check Out',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.assignment,
                    label: 'Apply Leave',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.description,
                    label: 'View Payslip',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ============ Helper Widgets ============

/// Small Stat Card Widget - Grid Layout with Icon Alongside
Color _chartColorFor(String label) {
  switch (label) {
    case 'Present':
      return Colors.green;
    case 'Remote':
      return Colors.blue;
    case 'Half Day':
      return Colors.orange;
    case 'On Leave':
      return Colors.purple;
    case 'Absent':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

class _SmallStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Quick Action Button Widget
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              Icon(Icons.arrow_forward_ios,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
