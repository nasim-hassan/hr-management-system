import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/data/services/payroll_service.dart';

class PayrollState {
  final List<Payroll> payrolls;
  final bool isLoading;
  final String? error;

  PayrollState({
    this.payrolls = const [],
    this.isLoading = false,
    this.error,
  });

  PayrollState copyWith({
    List<Payroll>? payrolls,
    bool? isLoading,
    String? error,
  }) {
    return PayrollState(
      payrolls: payrolls ?? this.payrolls,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PayrollNotifier extends StateNotifier<PayrollState> {
  PayrollNotifier() : super(PayrollState()) {
    loadPayrolls();
  }

  Future<void> loadPayrolls() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await PayrollService.getAllPayrolls();
      state = state.copyWith(payrolls: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPayroll(Payroll payroll) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newPayroll = await PayrollService.createPayroll(payroll);
      if (newPayroll != null) {
        state = state.copyWith(
          payrolls: [newPayroll, ...state.payrolls],
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to save payroll record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePayroll(Payroll payroll) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await PayrollService.updatePayroll(payroll.id, payroll.toJson());
      if (updated != null) {
        state = state.copyWith(
          payrolls: state.payrolls.map((item) => item.id == payroll.id ? updated : item).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update payroll record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePayroll(String payrollId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await PayrollService.deletePayroll(payrollId);
      if (success) {
        state = state.copyWith(
          payrolls: state.payrolls.where((item) => item.id != payrollId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete payroll record');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final payrollProvider = StateNotifierProvider<PayrollNotifier, PayrollState>((ref) {
  return PayrollNotifier();
});
