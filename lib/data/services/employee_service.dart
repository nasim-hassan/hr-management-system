import 'package:hr_management_system/config/supabase_config.dart';
import 'package:hr_management_system/data/models/employee_model.dart';

class EmployeeService {
  static const String _tableName = 'employees';

  static Future<List<Employee>> getAllEmployees() async {
    try {
      print('📊 [EMPLOYEE SERVICE] Fetching all employees...');
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      print('📊 [EMPLOYEE SERVICE] Raw response type: ${response.runtimeType}');
      print('📊 [EMPLOYEE SERVICE] Raw response: $response');

      if (response == null) {
        print('⚠️  [EMPLOYEE SERVICE] Response is null');
        return [];
      }
      
      if (response is! List) {
        print('⚠️  [EMPLOYEE SERVICE] Response is not a List: ${response.runtimeType}');
        return [];
      }

      print('📊 [EMPLOYEE SERVICE] Found ${response.length} employees');
      
      final employees = (response)
          .map((item) {
            print('📊 [EMPLOYEE SERVICE] Processing employee item: ${item['id']}');
            return Employee.fromJson(item as Map<String, dynamic>);
          })
          .toList();
      
      print('✅ [EMPLOYEE SERVICE] Successfully parsed ${employees.length} employees');
      return employees;
    } catch (e) {
      print('❌ [EMPLOYEE SERVICE] Error fetching employees: $e');
      throw Exception('Failed to fetch employees: $e');
    }
  }

  static Future<Employee?> fetchEmployeeById(String employeeId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('id', employeeId)
          .maybeSingle();

      if (response == null) return null;
      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch employee: $e');
    }
  }

  static Future<Employee?> fetchEmployeeByUserId(String userId) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch employee profile for user: $e');
    }
  }

  static Future<Employee?> createEmployee(Employee employee) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .insert(employee.toJson())
          .select()
          .single();

      if (response == null) return null;
      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to create employee record: $e');
    }
  }

  static Future<Employee?> updateEmployee(String employeeId, Map<String, dynamic> data) async {
    try {
      final response = await SupabaseConfig.client
          .from(_tableName)
          .update(data)
          .eq('id', employeeId)
          .select()
          .single();

      if (response == null) return null;
      return Employee.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update employee record: $e');
    }
  }

  static Future<bool> deleteEmployee(String employeeId) async {
    try {
      await SupabaseConfig.client
          .from(_tableName)
          .delete()
          .eq('id', employeeId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete employee record: $e');
    }
  }
}
