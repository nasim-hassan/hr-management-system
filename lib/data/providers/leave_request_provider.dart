import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/services/leave_request_service.dart';

class LeaveRequestState {
  final List<LeaveRequest> leaveRequests;
  final bool isLoading;
  final String? error;

  LeaveRequestState({
    this.leaveRequests = const [],
    this.isLoading = false,
    this.error,
  });

  LeaveRequestState copyWith({
    List<LeaveRequest>? leaveRequests,
    bool? isLoading,
    String? error,
  }) {
    return LeaveRequestState(
      leaveRequests: leaveRequests ?? this.leaveRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LeaveRequestNotifier extends StateNotifier<LeaveRequestState> {
  LeaveRequestNotifier() : super(LeaveRequestState()) {
    loadLeaveRequests();
  }

  Future<void> loadLeaveRequests() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final requests = await LeaveRequestService.getAllLeaveRequests();
      state = state.copyWith(leaveRequests: requests, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addLeaveRequest(LeaveRequest leaveRequest) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newRequest = await LeaveRequestService.createLeaveRequest(leaveRequest);
      if (newRequest != null) {
        state = state.copyWith(
          leaveRequests: [newRequest, ...state.leaveRequests],
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to save leave request');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateLeaveRequest(LeaveRequest leaveRequest) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await LeaveRequestService.updateLeaveRequest(leaveRequest.id, leaveRequest.toJson());
      if (updated != null) {
        state = state.copyWith(
          leaveRequests: state.leaveRequests
              .map((item) => item.id == leaveRequest.id ? updated : item)
              .toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update leave request');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteLeaveRequest(String requestId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await LeaveRequestService.deleteLeaveRequest(requestId);
      if (success) {
        state = state.copyWith(
          leaveRequests: state.leaveRequests.where((item) => item.id != requestId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete leave request');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final leaveRequestProvider = StateNotifierProvider<LeaveRequestNotifier, LeaveRequestState>((ref) {
  return LeaveRequestNotifier();
});
