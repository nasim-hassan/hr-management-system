import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/config/app_routes.dart';

class EmployeeDetailsScreen extends ConsumerStatefulWidget {
  final Employee employee;

  const EmployeeDetailsScreen({super.key, required this.employee});

  @override
  ConsumerState<EmployeeDetailsScreen> createState() => _EmployeeDetailsScreenState();
}

class _EmployeeDetailsScreenState extends ConsumerState<EmployeeDetailsScreen> {
  late String _employeeId;

  @override
  void initState() {
    super.initState();
    _employeeId = widget.employee.id;
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve latest employee data from the employee provider
    final employeeState = ref.watch(employeeProvider);
    Employee employee = widget.employee;
    if (!employeeState.isLoading && employeeState.employees.isNotEmpty) {
      try {
        employee = employeeState.employees.firstWhere((emp) => emp.id == _employeeId);
      } catch (_) {
        employee = widget.employee;
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, employee),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    title: 'Professional Info',
                    icon: Icons.work,
                    children: [
                      _buildInfoRow('Department', employee.department ?? 'N/A'),
                      _buildInfoRow(
                        'Designation',
                        employee.designation != null && employee.designation!.isNotEmpty
                            ? Designation.fromString(employee.designation!).displayName
                            : 'N/A',
                      ),
                      _buildInfoRow('Status', employee.isActive ? 'Active' : 'Inactive'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Contact Info',
                    icon: Icons.contact_mail,
                    children: [
                          _buildInfoRow('Email', employee.email),
                      _buildInfoRow('Phone', employee.phoneNumber),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Personal Info',
                    icon: Icons.person,
                    children: [
                          _buildInfoRow('Address', employee.address ?? 'N/A'),
                      _buildInfoRow('City', employee.city ?? 'N/A'),
                      _buildInfoRow('Zip Code', employee.zipCode ?? 'N/A'),
                      _buildInfoRow('Country', employee.country ?? 'N/A'),
                      _buildInfoRow('NID Number', employee.nidNumber ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Salary Information',
                    icon: Icons.account_balance_wallet,
                    children: [
                      _buildInfoRow('Base Salary', employee.baseSalary != null ? '৳${employee.baseSalary!.toStringAsFixed(2)}' : 'N/A'),
                      _buildInfoRow('Allowances', employee.allowances != null ? '৳${employee.allowances!.toStringAsFixed(2)}' : 'N/A'),
                      _buildInfoRow('Net Salary', _calculateNetSalary(employee)),
                      _buildInfoRow('Account Number', employee.accountNumber ?? 'N/A'),
                      _buildInfoRow('Bank Name', employee.bankName ?? 'N/A'),
                      _buildInfoRow('Account Holder', employee.accountHolderName ?? 'N/A'),
                      _buildInfoRow('Branch', employee.branchName ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    title: 'Identity & Address',
                    icon: Icons.location_on,
                    children: [
                      _buildInfoRow('NID Number', employee.nidNumber ?? 'N/A'),
                      _buildInfoRow('Address', employee.address ?? 'N/A'),
                      _buildInfoRow('City', employee.city ?? 'N/A'),
                      _buildInfoRow('Zip Code', employee.zipCode ?? 'N/A'),
                      _buildInfoRow('Country', employee.country ?? 'N/A'),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Employee employee) {
    return SliverAppBar(
      expandedHeight: 250.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Hero(
                tag: 'avatar_${employee.id}',
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Text(
                    employee.firstName[0] + employee.lastName[0],
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                employee.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                employee.email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () async {
            await Navigator.pushNamed(
              context, 
              AppRoutes.editEmployee.replaceAll(':id', employee.id),
              arguments: employee,
            );
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  String _calculateNetSalary(Employee employee) {
    final base = employee.baseSalary ?? 0;
    final allowances = employee.allowances ?? 0;
    final net = base + allowances;
    return '৳${net.toStringAsFixed(2)}';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

}
