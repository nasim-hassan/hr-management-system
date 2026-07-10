import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/services/employee_service.dart';
import 'package:hr_management_system/data/services/user_profile_service.dart';


class EmployeeListState {
  final List<Employee> employees;
  final bool isLoading;
  final String? error;

  EmployeeListState({
    this.employees = const [],
    this.isLoading = false,
    this.error,
  });

  EmployeeListState copyWith({
    List<Employee>? employees,
    bool? isLoading,
    String? error,
  }) {
    return EmployeeListState(
      employees: employees ?? this.employees,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EmployeeListNotifier extends StateNotifier<EmployeeListState> {
  EmployeeListNotifier() : super(EmployeeListState()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    print('🔄 [EMPLOYEE PROVIDER] Loading employees...');
    state = state.copyWith(isLoading: true, error: null);
    try {
      final employees = await EmployeeService.getAllEmployees();
      print('✅ [EMPLOYEE PROVIDER] Loaded ${employees.length} employees');
      state = state.copyWith(employees: employees, isLoading: false);
    } catch (e) {
      print('❌ [EMPLOYEE PROVIDER] Error loading employees: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addEmployee(Employee employee) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Resolve correct user_id by querying users table by email
      final user = await UserProfileService.fetchUserProfileByEmail(employee.email);
      if (user == null) {
        throw Exception('No user profile found for email ${employee.email}. Please create the user account first.');
      }

      // 2. Associate the retrieved user_id with the new employee record
      final employeeWithUserId = employee.copyWith(userId: user.id);

      final newEmployee = await EmployeeService.createEmployee(employeeWithUserId);
      if (newEmployee != null) {
        state = state.copyWith(
          employees: [newEmployee, ...state.employees],
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to save employee profile');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateEmployee(Employee employee) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updated = await EmployeeService.updateEmployee(employee.id, {
        'first_name': employee.firstName,
        'last_name': employee.lastName,
        'email': employee.email,
        'phone_number': employee.phoneNumber,
        'address': employee.address,
        'city': employee.city,
        'state': employee.state,
        'zip_code': employee.zipCode,
        'country': employee.country,
        'date_of_birth': employee.dateOfBirth.toIso8601String(),
        'gender': employee.gender,
        'marital_status': employee.maritalStatus,
        'designation': employee.designation.toStringValue(),
        'department': employee.department,
        'manager': employee.manager,
        'base_salary': employee.baseSalary,
        'allowances': employee.allowances,
        'deductions': employee.deductions,
        'bank_name': employee.bankName,
        'account_number': employee.accountNumber,
        'ifsc_code': employee.ifscCode,
        'pan_number': employee.panNumber,
        'aadhar_number': employee.aadharNumber,
        'emergency_contact': employee.emergencyContact,
        'emergency_contact_number': employee.emergencyContactNumber,
        'is_active': employee.isActive,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (updated != null) {
        state = state.copyWith(
          employees: state.employees.map((e) => e.id == employee.id ? updated : e).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to update employee profile');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteEmployee(String employeeId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final success = await EmployeeService.deleteEmployee(employeeId);
      if (success) {
        state = state.copyWith(
          employees: state.employees.where((e) => e.id != employeeId).toList(),
          isLoading: false,
        );
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Failed to delete employee profile');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final employeeProvider = StateNotifierProvider<EmployeeListNotifier, EmployeeListState>((ref) {
  return EmployeeListNotifier();
});
