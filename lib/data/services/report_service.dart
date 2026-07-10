import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/report_model.dart';

class ReportService {
  static const String _tableName = 'reports';

  static Future<List<Report>> getAllReports() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => Report.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch reports: $e');
    }
  }

  static Future<Report?> fetchReportById(String reportId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', reportId)
          .maybeSingle();

      if (response == null) return null;
      return Report.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch report: $e');
    }
  }

  static Future<Report?> createReport(Report report) async {
    try {
      final data = report.toJson();
      if (report.id.startsWith('report_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;
      return Report.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create report: $e');
    }
  }

  static Future<Report?> updateReport(String reportId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', reportId)
          .select()
          .single();

      if (response == null) return null;
      return Report.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update report: $e');
    }
  }

  static Future<bool> deleteReport(String reportId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', reportId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete report: $e');
    }
  }
}
