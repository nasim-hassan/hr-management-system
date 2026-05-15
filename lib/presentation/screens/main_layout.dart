import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/mock_data.dart';
import 'package:hr_management_system/data/providers/auth_provider.dart';
import 'package:hr_management_system/presentation/screens/dashboard_screen.dart';
import 'package:hr_management_system/presentation/screens/employee_list_screen.dart';
import 'package:hr_management_system/presentation/screens/attendance_list_screen.dart';
import 'package:hr_management_system/presentation/screens/leave_request_list_screen.dart';
import 'package:hr_management_system/presentation/screens/payroll_list_screen.dart';
import 'package:hr_management_system/presentation/screens/report_list_screen.dart';
import 'package:hr_management_system/presentation/screens/user_list_screen.dart';
import 'package:hr_management_system/presentation/screens/notification_screen.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const EmployeeListScreen(),
    const AttendanceListScreen(),
    const LeaveRequestListScreen(),
    const PayrollListScreen(),
    const ReportListScreen(),
    const UserListScreen(),
  ];

  final List<_SidebarItem> _menuItems = [
    _SidebarItem(icon: Icons.dashboard, label: 'Dashboard'),
    _SidebarItem(icon: Icons.people, label: 'Employees'),
    _SidebarItem(icon: Icons.access_time, label: 'Attendance'),
    _SidebarItem(icon: Icons.event_note, label: 'Leave Requests'),
    _SidebarItem(icon: Icons.payments, label: 'Payroll'),
    _SidebarItem(icon: Icons.bar_chart, label: 'Reports'),
    _SidebarItem(icon: Icons.supervised_user_circle, label: 'Users'),
  ];

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: return 'Admin Dashboard';
      case 1: return 'Employees Directory';
      case 2: return 'Attendance';
      case 3: return 'Leave Requests';
      case 4: return 'Payroll';
      case 5: return 'Reports';
      case 6: return 'User Management';
      default: return 'HR System';
    }
  }

  int get _unreadNotificationCount =>
      MockDataProvider.mockNotifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final isEmployeeScreen = _selectedIndex == 1;
    final unreadCount = _unreadNotificationCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        backgroundColor: isEmployeeScreen ? Colors.transparent : AppTheme.primaryColor,
        flexibleSpace: isEmployeeScreen
            ? Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              )
            : null,
        actions: [
          if (isEmployeeScreen)
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {},
            ),
          // Notification Bell Icon with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationScreen(),
                    ),
                  );
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.errorColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      unreadCount > 9 ? '9+' : '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: _buildDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: AppTheme.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          _buildLogo(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = _selectedIndex == index;
                return _buildSidebarMenuItem(item, isSelected, index);
              },
            ),
          ),
          _buildUserInfo(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.business_center, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 16),
          const Text(
            'HR System',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarMenuItem(_SidebarItem item, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          item.icon,
          color: isSelected ? Colors.white : Colors.white70,
        ),
        title: Text(
          item.label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context); // Close the drawer
        },
      ),
    );
  }

  Widget _buildUserInfo() {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (user?.fullName ?? 'U')
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0] : '')
                      .join()
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      user?.role.displayName ?? 'Employee',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, size: 16),
              label: const Text(
                'Logout',
                style: TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // Perform logout
      await ref.read(authProvider.notifier).logout();

      if (mounted) {
        // Navigate to login screen
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final String label;

  _SidebarItem({required this.icon, required this.label});
}
