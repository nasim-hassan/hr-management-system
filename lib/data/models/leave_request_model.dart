import 'package:hr_management_system/core/enums/app_enums.dart';

/// Leave Request Model
class LeaveRequest {
  final String id;
  final String employeeId;
  final LeaveType leaveType;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final String? reason;
  final LeaveStatus status;
  final String? approvedBy;
  final DateTime? approvedDate;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    this.reason,
    required this.status,
    this.approvedBy,
    this.approvedDate,
    this.rejectionReason,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
  bool get isRejected => status == LeaveStatus.rejected;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      leaveType:
          LeaveType.fromString(json['leave_type'] ?? LeaveType.casual.toStringValue()),
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      numberOfDays: json['number_of_days'] ?? 0,
      reason: json['reason'],
      status: LeaveStatus.fromString(
          json['status'] ?? LeaveStatus.pending.toStringValue()),
      approvedBy: json['approved_by'],
      approvedDate: json['approved_date'] != null
          ? DateTime.parse(json['approved_date'])
          : null,
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'leave_type': leaveType.toStringValue(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'number_of_days': numberOfDays,
      'reason': reason,
      'status': status.toStringValue(),
      'approved_by': approvedBy,
      'approved_date': approvedDate?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    LeaveType? leaveType,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfDays,
    String? reason,
    LeaveStatus? status,
    String? approvedBy,
    DateTime? approvedDate,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveType: leaveType ?? this.leaveType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedDate: approvedDate ?? this.approvedDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LeaveRequest &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'LeaveRequest(id: $id, employeeId: $employeeId, leaveType: ${leaveType.displayName}, status: ${status.displayName})';
  }
}
