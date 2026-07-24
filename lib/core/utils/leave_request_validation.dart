import 'package:hr_management_system/data/models/leave_request_model.dart';

class LeaveRequestValidationResult {
  final bool isValid;
  final String? message;

  const LeaveRequestValidationResult({required this.isValid, this.message});
}

LeaveRequestValidationResult? validateLeaveRequestRange({
  required String employeeId,
  required DateTime startDate,
  required DateTime endDate,
  required List<LeaveRequest> existingRequests,
  String? currentRequestId,
}) {
  if (startDate.isAfter(endDate)) {
    return const LeaveRequestValidationResult(
      isValid: false,
      message: 'Start date cannot be after end date.',
    );
  }

  for (final day in _daysBetween(startDate, endDate)) {
    final hasConflict = existingRequests.any((existing) {
      if (existing.employeeId != employeeId) return false;
      if (currentRequestId != null && existing.id == currentRequestId) return false;

      final isDayCovered = !day.isBefore(existing.startDate) && !day.isAfter(existing.endDate);
      return isDayCovered;
    });

    if (hasConflict) {
      return const LeaveRequestValidationResult(
        isValid: false,
        message: 'This date range overlaps with an existing leave request for this employee.',
      );
    }
  }

  return null;
}

Iterable<DateTime> _daysBetween(DateTime startDate, DateTime endDate) sync* {
  var current = DateTime(startDate.year, startDate.month, startDate.day);
  final last = DateTime(endDate.year, endDate.month, endDate.day);

  while (!current.isAfter(last)) {
    yield current;
    current = current.add(const Duration(days: 1));
  }
}
