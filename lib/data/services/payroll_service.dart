import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';


class PayrollService {
  static const String _tableName = 'payroll';

  static Future<List<Payroll>> getAllPayrolls() async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('payment_date', ascending: false);

      if (response == null || response is! List) return [];

      return (response)
          .map((item) => Payroll.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch payroll records: $e');
    }
  }

  static Future<Payroll?> fetchPayrollById(String payrollId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', payrollId)
          .maybeSingle();

      if (response == null) return null;
      return Payroll.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch payroll record: $e');
    }
  }

  static Future<Payroll?> createPayroll(Payroll payroll) async {
    try {
      final data = payroll.toJson();
      if (payroll.id.startsWith('payroll_')) data.remove('id');

      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(data)
          .select()
          .single();

      if (response == null) return null;



      return Payroll.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create payroll record: $e');
    }
  }

  static Future<Payroll?> updatePayroll(String payrollId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', payrollId)
          .select()
          .single();

      if (response == null) return null;
      return Payroll.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update payroll record: $e');
    }
  }

  static Future<bool> deletePayroll(String payrollId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', payrollId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete payroll record: $e');
    }
  }
}
