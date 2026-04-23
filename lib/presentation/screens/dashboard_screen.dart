import 'package:flutter/material.dart';
import 'package:hr_management_system/config/app_routes.dart';
import 'package:hr_management_system/data/models/mock_data.dart';

/// Admin Dashboard Screen
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = MockDataProvider.getMockStatistics();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Welcome Header
            Container(
              color: Colors.blue.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Nasim Hassan',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'HR Administrator',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Statistics Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _StatCard(
                    title: 'Total Employees',
                    value: stats['totalEmployees'].toString(),
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _StatCard(
                    title: 'Attendance Today',
                    value: stats['attendanceToday'].toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                  _StatCard(
                    title: 'Pending Leaves',
                    value: stats['pendingLeaveRequests'].toString(),
                    icon: Icons.calendar_month,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Pending Payrolls',
                    value: stats['pendingPayrolls'].toString(),
                    icon: Icons.payments,
                    color: Colors.purple,
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
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.employees);
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.person_add,
                    label: 'Add Employee',
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.editEmployee.replaceAll(':id', 'new'));
                    },
                  ),
                  _QuickActionButton(
                    icon: Icons.assignment,
                    label: 'Review Leave Requests',
                    onTap: () {},
                  ),
                  _QuickActionButton(
                    icon: Icons.assessment,
                    label: 'Generate Reports',
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

/// Manager Dashboard Screen
class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              color: Colors.green.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Priya Sharma',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Team Manager',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Team Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatCard(
                    title: 'Team Members',
                    value: '3',
                    icon: Icons.group,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    title: 'Leave Requests to Approve',
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
                  ..._buildTeamAttendanceList(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTeamAttendanceList() {
    final employees = MockDataProvider.mockEmployees;
    return employees
        .map(
          (emp) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text(emp.fullName),
              subtitle: Text(emp.designation.displayName),
              trailing: const Chip(
                label: Text('Present'),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
        .toList();
  }
}

/// Employee Dashboard Screen
class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final employee = MockDataProvider.mockEmployees.first;
    final recentAttendance =
        MockDataProvider.getMockAttendanceByEmployee(employee.id);

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
              color: Colors.purple.shade50,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome, Amit Patel',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    employee.designation.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // Quick Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _StatCard(
                    title: 'Department',
                    value: employee.department,
                    icon: Icons.domain,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
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

// Helper Widgets
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(fontSize: 14),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
