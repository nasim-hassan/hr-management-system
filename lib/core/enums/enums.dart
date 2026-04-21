enum UserRole {
  admin('admin'),
  manager('manager'),
  employee('employee');

  final String value;

  const UserRole(this.value);

  static UserRole? fromString(String? value) {
    try {
      return UserRole.values.firstWhere((role) => role.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum AttendanceStatus {
  present('present'),
  absent('absent'),
  late('late'),
  halfDay('half_day'),
  lcPresent('lc_present');

  final String value;

  const AttendanceStatus(this.value);

  static AttendanceStatus? fromString(String? value) {
    try {
      return AttendanceStatus.values
          .firstWhere((status) => status.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum LeaveType {
  sick('sick'),
  casual('casual'),
  earned('earned'),
  unpaid('unpaid'),
  maternity('maternity'),
  paternity('paternity'),
  study('study');

  final String value;

  const LeaveType(this.value);

  static LeaveType? fromString(String? value) {
    try {
      return LeaveType.values.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum LeaveStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected'),
  cancelled('cancelled');

  final String value;

  const LeaveStatus(this.value);

  static LeaveStatus? fromString(String? value) {
    try {
      return LeaveStatus.values.firstWhere((status) => status.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum NotificationType {
  leaveApproved('leave_approved'),
  leaveRejected('leave_rejected'),
  attendanceReminder('attendance_reminder'),
  payslipGenerated('payslip_generated'),
  leaveRequest('leave_request'),
  system('system');

  final String value;

  const NotificationType(this.value);

  static NotificationType? fromString(String? value) {
    try {
      return NotificationType.values.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }
}

enum ReportType {
  attendance('attendance'),
  payroll('payroll'),
  leave('leave'),
  performance('performance');

  final String value;

  const ReportType(this.value);

  static ReportType? fromString(String? value) {
    try {
      return ReportType.values.firstWhere((type) => type.value == value);
    } catch (e) {
      return null;
    }
  }
}
