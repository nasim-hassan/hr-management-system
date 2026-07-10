import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/config/app_routes.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  String _searchQuery = '';

  List<Employee> _getFilteredEmployees(List<Employee> employees) {
    if (_searchQuery.isEmpty) return employees;
    return employees.where((emp) {
      return emp.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.department.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          emp.designation.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final employeeState = ref.watch(employeeProvider);
    final filteredEmployees = _getFilteredEmployees(employeeState.employees);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: canPop
          ? AppBar(
              title: const Text('Employees Directory'),
              elevation: 0,
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name, department, role...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Employee List
          Expanded(
            child: employeeState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : employeeState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: ${employeeState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(employeeProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredEmployees.isEmpty
                        ? const Center(
                            child: Text('No employees found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              return _buildEmployeeCard(context, employee, ref);
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.pushNamed(context, AppRoutes.editEmployee.replaceAll(':id', 'new'));
          ref.invalidate(employeeProvider);
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Employee', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmployeeCard(BuildContext context, Employee employee, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.pushNamed(
            context, 
            AppRoutes.employeeDetails.replaceAll(':id', employee.id),
            arguments: employee,
          );
          ref.invalidate(employeeProvider);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'avatar_${employee.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    employee.firstName[0] + employee.lastName[0],
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      employee.designation.displayName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (employee.baseSalary != null)
                      Text(
                        'Salary: ₹${employee.netSalary.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            employee.department,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (employee.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.successColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
