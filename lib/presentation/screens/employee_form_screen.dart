import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
// Mock data no longer used here; employeeProvider handles storage
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';

class EmployeeFormScreen extends ConsumerStatefulWidget {
  final Employee? employee; // If null, it's Add Mode. If provided, Edit Mode.

  const EmployeeFormScreen({super.key, this.employee});

  @override
  ConsumerState<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends ConsumerState<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _idController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _departmentController;
  
  late TextEditingController _baseSalaryController;
  late TextEditingController _allowancesController;
  late TextEditingController _deductionsController;
  double _calculatedNetSalary = 0.0;
  
  Designation _selectedDesignation = Designation.juniorDeveloper;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employee?.id ?? '');
    _firstNameController = TextEditingController(text: widget.employee?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.employee?.lastName ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phoneNumber ?? '');
    _departmentController = TextEditingController(text: widget.employee?.department ?? '');
    
    _baseSalaryController = TextEditingController(text: widget.employee?.baseSalary?.round().toString() ?? '');
    _allowancesController = TextEditingController(text: widget.employee?.allowances?.round().toString() ?? '');
    _deductionsController = TextEditingController(text: widget.employee?.deductions?.round().toString() ?? '');
    
    _calculateNetSalary();
    
    _baseSalaryController.addListener(_calculateNetSalary);
    _allowancesController.addListener(_calculateNetSalary);
    _deductionsController.addListener(_calculateNetSalary);
    
    if (widget.employee != null) {
      _selectedDesignation = widget.employee!.designation;
      _isActive = widget.employee!.isActive;
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _departmentController.dispose();
    _baseSalaryController.dispose();
    _allowancesController.dispose();
    _deductionsController.dispose();
    super.dispose();
  }

  void _calculateNetSalary() {
    final base = double.tryParse(_baseSalaryController.text) ?? 0.0;
    final allowances = double.tryParse(_allowancesController.text) ?? 0.0;
    final deductions = double.tryParse(_deductionsController.text) ?? 0.0;
    setState(() {
      _calculatedNetSalary = base + allowances - deductions;
    });
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final id = _idController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final department = _departmentController.text.trim();
      final baseSalary = double.tryParse(_baseSalaryController.text) ?? 0.0;
      final allowances = double.tryParse(_allowancesController.text) ?? 0.0;
      final deductions = double.tryParse(_deductionsController.text) ?? 0.0;
      
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
          if (widget.employee == null) {
          // Add Mode
          final newEmployee = Employee(
            id: id,
            userId: '',
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phone,
            dateOfBirth: DateTime(1995, 1, 1),
            dateOfJoining: DateTime.now(),
            designation: _selectedDesignation,
            department: department,
            baseSalary: baseSalary,
            allowances: allowances,
            deductions: deductions,
            isActive: _isActive,
            createdAt: DateTime.now(),
          );
          
          final success = await ref.read(employeeProvider.notifier).addEmployee(newEmployee);
          if (!success) throw Exception('Failed to add employee to the system');
        } else {
          // Edit Mode
          final updatedEmployee = widget.employee!.copyWith(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phone,
            department: department,
            designation: _selectedDesignation,
            baseSalary: baseSalary,
            allowances: allowances,
            deductions: deductions,
            isActive: _isActive,
            updatedAt: DateTime.now(),
          );
          
          final success = await ref.read(employeeProvider.notifier).updateEmployee(updatedEmployee);
          if (!success) throw Exception('Failed to update employee in the system');
        }

        if (mounted) {
          Navigator.pop(context); // Pop loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.employee == null ? 'Employee Added Successfully' : 'Employee Updated Successfully'),
              backgroundColor: AppTheme.successColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Pop loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.errorColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.employee != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Employee' : 'Add New Employee'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: 'Personal Details',
                children: [
                  _buildTextField(
                    controller: _idController,
                    label: 'Employee ID',
                    icon: Icons.badge,
                    enabled: widget.employee == null,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                        if (widget.employee == null) {
                        final exists = ref.read(employeeProvider).employees.any(
                          (emp) => emp.id.trim().toLowerCase() == v.trim().toLowerCase(),
                        );
                        if (exists) return 'Employee ID already exists';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          icon: Icons.person,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          icon: Icons.person_outline,
                          validator: (v) => v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Professional Details',
                children: [
                  _buildTextField(
                    controller: _departmentController,
                    label: 'Department',
                    icon: Icons.domain,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Designation>(
                    decoration: InputDecoration(
                      labelText: 'Designation',
                      prefixIcon: const Icon(Icons.work, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    initialValue: _selectedDesignation,
                    items: Designation.values.map((d) {
                      return DropdownMenuItem(
                        value: d,
                        child: Text(d.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _selectedDesignation = val;
                      });
                    },
                    validator: (val) => val == null ? 'Please select a designation' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active Status', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(_isActive ? 'Employee has access to system' : 'Employee account is disabled'),
                    value: _isActive,
                    activeThumbColor: AppTheme.successColor,
                    onChanged: (val) {
                      setState(() => _isActive = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Salary Breakdown Setup',
                children: [
                  _buildTextField(
                    controller: _baseSalaryController,
                    label: 'Base Salary',
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _allowancesController,
                          label: 'Allowances',
                          icon: Icons.add_circle_outline,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                              return 'Enter number';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _deductionsController,
                          label: 'Deductions',
                          icon: Icons.remove_circle_outline,
                          keyboardType: TextInputType.number,
                          validator: (v) {
                            if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                              return 'Enter number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Calculated Net Salary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '₹${_calculatedNetSalary.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveEmployee,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  isEdit ? 'Update Employee' : 'Save Employee',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? AppTheme.primaryColor : Colors.grey),
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }
}
