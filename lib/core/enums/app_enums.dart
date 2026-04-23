/// User Roles in the system
enum UserRole {
  hrAdmin('HR Admin'),
  manager('Manager'),
  employee('Employee');

  final String displayName;
  const UserRole(this.displayName);

  /// Convert string to enum
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.name == value,
      orElse: () => UserRole.employee,
    );
  }

  /// Get enum name as string
  String toStringValue() => name;
}

/// Leave Request Status
enum LeaveStatus {
  pending('Pending'),
  approved('Approved'),
  rejected('Rejected'),
  cancelled('Cancelled');

  final String displayName;
  const LeaveStatus(this.displayName);

  static LeaveStatus fromString(String value) {
    return LeaveStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => LeaveStatus.pending,
    );
  }

  String toStringValue() => name;
}

/// Leave Types
enum LeaveType {
  annual('Annual Leave'),
  sick('Sick Leave'),
  casual('Casual Leave'),
  maternity('Maternity Leave'),
  paternity('Paternity Leave'),
  unpaid('Unpaid Leave');

  final String displayName;
  const LeaveType(this.displayName);

  static LeaveType fromString(String value) {
    return LeaveType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => LeaveType.casual,
    );
  }

  String toStringValue() => name;
}

/// Attendance Status
enum AttendanceStatus {
  present('Present'),
  absent('Absent'),
  halfDay('Half Day'),
  onLeave('On Leave'),
  remote('Remote Work');

  final String displayName;
  const AttendanceStatus(this.displayName);

  static AttendanceStatus fromString(String value) {
    return AttendanceStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => AttendanceStatus.absent,
    );
  }

  String toStringValue() => name;
}

/// Performance Review Status
enum ReviewStatus {
  pending('Pending'),
  completed('Completed'),
  inProgress('In Progress');

  final String displayName;
  const ReviewStatus(this.displayName);

  static ReviewStatus fromString(String value) {
    return ReviewStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ReviewStatus.pending,
    );
  }

  String toStringValue() => name;
}

/// Notification Type
enum NotificationType {
  leaveApproved('Leave Approved'),
  leaveRejected('Leave Rejected'),
  attendanceReminder('Attendance Reminder'),
  payslipReady('Payslip Ready'),
  performanceReview('Performance Review'),
  announcement('Announcement');

  final String displayName;
  const NotificationType(this.displayName);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => NotificationType.announcement,
    );
  }

  String toStringValue() => name;
}

/// Employee Designation/Position
enum Designation {
  intern('Intern'),
  juniorDeveloper('Junior Developer'),
  seniorDeveloper('Senior Developer'),
  technicalLead('Technical Lead'),
  manager('Manager'),
  director('Director'),
  cto('CTO'),
  ceo('CEO');

  final String displayName;
  const Designation(this.displayName);

  static Designation fromString(String value) {
    return Designation.values.firstWhere(
      (designation) => designation.name == value,
      orElse: () => Designation.intern,
    );
  }

  String toStringValue() => name;
}
