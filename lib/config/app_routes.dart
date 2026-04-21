class AppRoutes {
  // Auth Routes
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Dashboard Routes
  static const String adminDashboard = '/admin-dashboard';
  static const String managerDashboard = '/manager-dashboard';
  static const String employeeDashboard = '/employee-dashboard';

  // Employee Routes
  static const String employees = '/employees';
  static const String employeeDetails = '/employees/:id';
  static const String editEmployee = '/employees/:id/edit';

  // Attendance Routes
  static const String attendance = '/attendance';
  static const String attendanceHistory = '/attendance/history';

  // Leave Routes
  static const String leave = '/leave';
  static const String leaveRequests = '/leave/requests';
  static const String createLeaveRequest = '/leave/create';
  static const String leaveRequestDetails = '/leave/:id';

  // Payroll Routes
  static const String payroll = '/payroll';
  static const String payslips = '/payroll/slips';
  static const String payslipDetails = '/payroll/slips/:id';

  // Reports Routes
  static const String reports = '/reports';
  static const String attendanceReport = '/reports/attendance';
  static const String payrollReport = '/reports/payroll';

  // Profile Routes
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/settings';

  // Notification Routes
  static const String notifications = '/notifications';
}
