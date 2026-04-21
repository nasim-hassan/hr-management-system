class AppConstants {
  // App Info
  static const String appName = 'HR Management System';
  static const String appVersion = '1.0.0';
  static const String appBuild = '1';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
  static const String lastSyncKey = 'last_sync';

  // Database Tables
  static const String usersTable = 'users';
  static const String employeesTable = 'employees';
  static const String attendanceTable = 'attendance';
  static const String leaveRequestsTable = 'leave_requests';
  static const String leaveTypesTable = 'leave_types';
  static const String payrollTable = 'payroll';
  static const String payslipsTable = 'payslips';
  static const String notificationsTable = 'notifications';
  static const String reportsTable = 'reports';

  // Time Format
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';

  // Pagination
  static const int pageSize = 20;

  // API Timeouts (in seconds)
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;

  // Attendance
  static const int attendanceCheckInHour = 9;
  static const int attendanceCheckInMinute = 0;
  static const int lateMarginMinutes = 15;

  // Error Messages
  static const String networkError =
      'Network error occurred. Please try again.';
  static const String serverError =
      'Server error occurred. Please try again later.';
  static const String unknownError =
      'An unknown error occurred. Please try again.';
  static const String invalidCredentials = 'Invalid email or password.';
  static const String userAlreadyExists =
      'User with this email already exists.';
  static const String notFound = 'Resource not found.';
  static const String unauthorized =
      'You are not authorized to perform this action.';
  static const String sessionExpired =
      'Your session has expired. Please login again.';

  // Success Messages
  static const String loginSuccess = 'Login successful.';
  static const String logoutSuccess = 'Logout successful.';
  static const String registrationSuccess =
      'Registration successful. Please login.';
  static const String updateSuccess = 'Update successful.';
  static const String deleteSuccess = 'Deleted successfully.';
  static const String checkInSuccess = 'Check-in successful.';
  static const String checkOutSuccess = 'Check-out successful.';
  static const String leaveRequestSubmitted =
      'Leave request submitted successfully.';
  static const String leaveApproved = 'Leave request approved.';
  static const String leaveRejected = 'Leave request rejected.';
}

// UI Constants
class UIConstants {
  // Spacing
  static const double paddingXSmall = 4.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;

  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusExtraLarge = 16.0;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconExtraLarge = 48.0;

  // Button Heights
  static const double buttonHeightSmall = 36.0;
  static const double buttonHeightMedium = 44.0;
  static const double buttonHeightLarge = 52.0;

  // Animation Duration
  static const Duration animationDurationShort = Duration(milliseconds: 200);
  static const Duration animationDurationMedium = Duration(milliseconds: 300);
  static const Duration animationDurationLong = Duration(milliseconds: 500);
}
