import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/report_model.dart';
import 'package:hr_management_system/data/services/report_service.dart';

class ReportState {
  final List<Report> reports;
  final bool isLoading;
  final String? error;

  ReportState({
    this.reports = const [],
    this.isLoading = false,
    this.error,
  });

  ReportState copyWith({
    List<Report>? reports,
    bool? isLoading,
    String? error,
  }) {
    return ReportState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  ReportNotifier() : super(ReportState()) {
    loadReports();
  }

  Future<void> loadReports() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await ReportService.getAllReports();
      state = state.copyWith(reports: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addReport(Report report) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final newReport = await ReportService.createReport(report);
      if (newReport != null) {
        state = state.copyWith(
          reports: [newReport, ...state.reports],
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to save report');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateReport(Report report) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await ReportService.updateReport(report.id, report.toJson());
      if (updated != null) {
        state = state.copyWith(
          reports: state.reports.map((item) => item.id == report.id ? updated : item).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update report');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteReport(String reportId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await ReportService.deleteReport(reportId);
      if (success) {
        state = state.copyWith(
          reports: state.reports.where((item) => item.id != reportId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete report');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier();
});
