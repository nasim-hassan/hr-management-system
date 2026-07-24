import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
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
  late TextEditingController _addressController;
  late TextEditingController _departmentController;
  late TextEditingController _cityController;
  late TextEditingController _zipCodeController;
  late TextEditingController _countryController;
  late TextEditingController _nidNumberController;
  late TextEditingController _accountNumberController;
  late TextEditingController _accountHolderNameController;
  late TextEditingController _bankNameController;
  late TextEditingController _branchNameController;
  late TextEditingController _baseSalaryController;
  late TextEditingController _allowancesController;
  Designation? _designation;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.employee?.id ?? '');
    _firstNameController = TextEditingController(text: widget.employee?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.employee?.lastName ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.employee?.address ?? '');
    _departmentController = TextEditingController(text: widget.employee?.department ?? '');
    _cityController = TextEditingController(text: widget.employee?.city ?? '');
    _zipCodeController = TextEditingController(text: widget.employee?.zipCode ?? '');
    _countryController = TextEditingController(text: widget.employee?.country ?? '');
    _nidNumberController = TextEditingController(text: widget.employee?.nidNumber ?? '');
    _accountNumberController = TextEditingController(text: widget.employee?.accountNumber ?? '');
    _accountHolderNameController = TextEditingController(text: widget.employee?.accountHolderName ?? '');
    _bankNameController = TextEditingController(text: widget.employee?.bankName ?? '');
    _branchNameController = TextEditingController(text: widget.employee?.branchName ?? '');
    _baseSalaryController = TextEditingController(text: widget.employee?.baseSalary?.toString() ?? '');
    _allowancesController = TextEditingController(text: widget.employee?.allowances?.toString() ?? '');
    _designation = widget.employee?.designation != null
        ? Designation.fromString(widget.employee!.designation!)
        : null;
    
    if (widget.employee != null) {
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
    _addressController.dispose();
    _departmentController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _nidNumberController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _bankNameController.dispose();
    _branchNameController.dispose();
    _baseSalaryController.dispose();
    _allowancesController.dispose();
    super.dispose();
  }

  void _saveEmployee() async {
    if (_formKey.currentState!.validate()) {
      final id = _idController.text.trim();
      final firstName = _firstNameController.text.trim();
      final lastName = _lastNameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final address = _addressController.text.trim().isEmpty ? null : _addressController.text.trim();
      final department = _departmentController.text.trim().isEmpty ? null : _departmentController.text.trim();
      final designation = _designation?.toStringValue();
      final city = _cityController.text.trim().isEmpty ? null : _cityController.text.trim();
      final zipCode = _zipCodeController.text.trim().isEmpty ? null : _zipCodeController.text.trim();
      final country = _countryController.text.trim().isEmpty ? null : _countryController.text.trim();
      final nidNumber = _nidNumberController.text.trim().isEmpty ? null : _nidNumberController.text.trim();
      final accountNumber = _accountNumberController.text.trim().isEmpty ? null : _accountNumberController.text.trim();
      final accountHolderName = _accountHolderNameController.text.trim().isEmpty ? null : _accountHolderNameController.text.trim();
      final bankName = _bankNameController.text.trim().isEmpty ? null : _bankNameController.text.trim();
      final branchName = _branchNameController.text.trim().isEmpty ? null : _branchNameController.text.trim();
      final baseSalary = _baseSalaryController.text.trim().isEmpty ? null : double.tryParse(_baseSalaryController.text.trim());
      final allowances = _allowancesController.text.trim().isEmpty ? null : double.tryParse(_allowancesController.text.trim());

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
            userId: null,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phone,
            address: address,
            department: department,
            designation: designation,
            city: city,
            zipCode: zipCode,
            country: country,
            nidNumber: nidNumber,
            manager: null,
            accountNumber: accountNumber,
            accountHolderName: accountHolderName,
            bankName: bankName,
            branchName: branchName,
            baseSalary: baseSalary,
            allowances: allowances,
            isActive: _isActive,
            createdAt: DateTime.now(),
          );

          final success = await ref.read(employeeProvider.notifier).addEmployee(newEmployee);
          if (!success) throw Exception('Failed to add employee to the system');
        } else {
          // Edit Mode
          final updatedEmployee = widget.employee!.copyWith(
            userId: widget.employee?.userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phone,
            address: address,
            department: department,
            designation: designation,
            city: city,
            zipCode: zipCode,
            country: country,
            nidNumber: nidNumber,
            manager: null,
            accountNumber: accountNumber,
            accountHolderName: accountHolderName,
            bankName: bankName,
            branchName: branchName,
            baseSalary: baseSalary,
            allowances: allowances,
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
                    enabled: false,
                    validator: (_) => null,
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
                    icon: Icons.business,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Designation>(
                    initialValue: _designation,
                    decoration: InputDecoration(
                      labelText: 'Designation',
                      prefixIcon: const Icon(Icons.work),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    items: Designation.values
                        .map((designation) => DropdownMenuItem(
                              value: designation,
                              child: Text(designation.displayName),
                            ))
                        .toList(),
                    onChanged: (designation) {
                      setState(() => _designation = designation);
                    },
                    validator: (v) => null,
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
                title: 'Identity & Address',
                children: [
                  _buildTextField(
                    controller: _nidNumberController,
                    label: 'NID Number',
                    icon: Icons.perm_identity,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.home,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cityController,
                          label: 'City',
                          icon: Icons.location_city,
                          validator: (v) => null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _zipCodeController,
                          label: 'Zip Code',
                          icon: Icons.local_post_office,
                          keyboardType: TextInputType.number,
                          validator: (v) => null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _countryController,
                    label: 'Country',
                    icon: Icons.flag,
                    validator: (v) => null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Salary Breakdown',
                children: [
                  _buildTextField(
                    controller: _baseSalaryController,
                    label: 'Base Salary',
                    icon: Icons.currency_exchange,
                    keyboardType: TextInputType.number,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _allowancesController,
                    label: 'Allowances',
                    icon: Icons.add_circle_outline,
                    keyboardType: TextInputType.number,
                    validator: (v) => null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Bank Details',
                children: [
                  _buildTextField(
                    controller: _accountNumberController,
                    label: 'Bank Account Number',
                    icon: Icons.account_balance,
                    keyboardType: TextInputType.number,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _accountHolderNameController,
                    label: 'Account Holder Name',
                    icon: Icons.account_circle,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _bankNameController,
                    label: 'Bank Name',
                    icon: Icons.account_balance,
                    validator: (v) => null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _branchNameController,
                    label: 'Branch Name',
                    icon: Icons.account_balance_wallet,
                    validator: (v) => null,
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
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      readOnly: onTap != null,
      onTap: onTap,
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
