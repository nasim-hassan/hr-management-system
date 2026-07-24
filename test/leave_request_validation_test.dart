import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/core/utils/leave_request_validation.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';

void main() {
  group('leave request overlap validation', () {
    test('detects overlapping date ranges for the same employee', () {
      final existing = LeaveRequest(
        id: 'existing-1',
        employeeId: 'emp-1',
        leaveType: LeaveType.annual,
        startDate: DateTime(2026, 7, 10),
        endDate: DateTime(2026, 7, 12),
        numberOfDays: 3,
        reason: 'Existing leave',
        status: LeaveStatus.pending,
        createdAt: DateTime(2026, 7, 1),
      );

      final result = validateLeaveRequestRange(
        employeeId: 'emp-1',
        startDate: DateTime(2026, 7, 11),
        endDate: DateTime(2026, 7, 14),
        existingRequests: [existing],
        currentRequestId: null,
      );

      expect(result, isNotNull);
      expect(result!.message, contains('overlaps'));
    });

    test('allows non-overlapping ranges for the same employee', () {
      final existing = LeaveRequest(
        id: 'existing-2',
        employeeId: 'emp-1',
        leaveType: LeaveType.sick,
        startDate: DateTime(2026, 7, 10),
        endDate: DateTime(2026, 7, 12),
        numberOfDays: 3,
        reason: 'Existing leave',
        status: LeaveStatus.pending,
        createdAt: DateTime(2026, 7, 1),
      );

      final result = validateLeaveRequestRange(
        employeeId: 'emp-1',
        startDate: DateTime(2026, 7, 13),
        endDate: DateTime(2026, 7, 15),
        existingRequests: [existing],
        currentRequestId: null,
      );

      expect(result, isNull);
    });
  });
}
