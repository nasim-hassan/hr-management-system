import 'package:hr_management_system/config/supabase_config.dart';

class DebugService {
  static Future<void> testSupabaseConnection() async {
    try {
      print('\n🔍 ===== SUPABASE DEBUG TEST START =====');
      
      // Test 1: Check if client is initialized
      print('✓ Test 1: Client initialized');
      final client = SupabaseConfig.client;
      print('  Client URL: ${client.supabaseUrl}');
      print('  Auth user: ${client.auth.currentUser?.email ?? "Not authenticated"}');
      
      // Test 2: Check employees table exists and has data
      print('\n✓ Test 2: Employees table');
      try {
        final empResponse = await client.from('employees').select().limit(1);
        print('  Query successful: $empResponse');
        print('  Response type: ${empResponse.runtimeType}');
        if (empResponse is List) {
          print('  Employee count (limit 1): ${empResponse.length}');
          if (empResponse.isNotEmpty) {
            print('  First record keys: ${(empResponse[0] as Map).keys.toList()}');
          }
        }
      } catch (e) {
        print('  ❌ Error querying employees: $e');
      }
      
      // Test 3: Check attendance table exists and has data
      print('\n✓ Test 3: Attendance table');
      try {
        final attResponse = await client.from('attendance').select().limit(1);
        print('  Query successful: $attResponse');
        print('  Response type: ${attResponse.runtimeType}');
        if (attResponse is List) {
          print('  Attendance count (limit 1): ${attResponse.length}');
          if (attResponse.isNotEmpty) {
            print('  First record keys: ${(attResponse[0] as Map).keys.toList()}');
          }
        }
      } catch (e) {
        print('  ❌ Error querying attendance: $e');
      }
      
      // Test 4: Check users table exists
      print('\n✓ Test 4: Users table');
      try {
        final usersResponse = await client.from('users').select().limit(1);
        print('  Query successful');
        if (usersResponse is List) {
          print('  User count (limit 1): ${usersResponse.length}');
        }
      } catch (e) {
        print('  ❌ Error querying users: $e');
      }
      
      // Test 5: Raw SQL count
      print('\n✓ Test 5: Row counts');
      try {
        final empResponse = await client.from('employees').select('id').limit(1000);
        if (empResponse is List) {
          print('  Employees total count: ${empResponse.length}');
        }
      } catch (e) {
        print('  ❌ Error counting employees: $e');
      }
      
      try {
        final attResponse = await client.from('attendance').select('id').limit(1000);
        if (attResponse is List) {
          print('  Attendance total count: ${attResponse.length}');
        }
      } catch (e) {
        print('  ❌ Error counting attendance: $e');
      }
      
      print('\n🔍 ===== SUPABASE DEBUG TEST END =====\n');
      
    } catch (e) {
      print('❌ Debug test failed: $e');
    }
  }

  static Future<Map<String, dynamic>> getConnectionStatus() async {
    final status = <String, dynamic>{};
    
    try {
      final client = SupabaseConfig.client;
      status['connected'] = true;
      status['url'] = client.supabaseUrl;
      status['authenticated'] = client.auth.currentUser != null;
      status['user_email'] = client.auth.currentUser?.email;
      
      // Try a simple query
      try {
        await client.from('employees').select('id').limit(1);
        status['employees_table_ok'] = true;
      } catch (e) {
        status['employees_table_ok'] = false;
        status['employees_error'] = e.toString();
      }
      
      try {
        await client.from('attendance').select('id').limit(1);
        status['attendance_table_ok'] = true;
      } catch (e) {
        status['attendance_table_ok'] = false;
        status['attendance_error'] = e.toString();
      }
      
    } catch (e) {
      status['connected'] = false;
      status['error'] = e.toString();
    }
    
    return status;
  }
}
