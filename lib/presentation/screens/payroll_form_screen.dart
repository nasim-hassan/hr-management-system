import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/core/utils/payroll_calculation.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/data/providers/attendance_provider.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/data/providers/holiday_provider.dart';
import 'package:hr_management_system/data/providers/leave_request_provider.dart';

class PayrollFormScreen extends ConsumerStatefulWidget {
  final Payroll? payroll;

  const PayrollFormScreen({super.key, this.payroll});

  @override
  ConsumerState<PayrollFormScreen> createState() => _PayrollFormScreenState();
}

class _PayrollFormScreenState extends ConsumerState<PayrollFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedEmployeeId;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;
  DateTime _paymentDate = DateTime.now();
  bool _isPaid = false;

  late TextEditingController _baseSalaryController;
  late TextEditingController _bonusController;
  late TextEditingController _deductionsController;
  late TextEditingController _allowancesController;
  late TextEditingController _notesController;

  double _netSalary = 0.0;

  @override
  void initState() {
    super.initState();
    _baseSalaryController = TextEditingController(text: widget.payroll?.baseSalary.toString() ?? '');
    _bonusController = TextEditingController(text: widget.payroll?.bonus?.toString() ?? '');
    _deductionsController = TextEditingController(text: '');
    _allowancesController = TextEditingController(text: widget.payroll?.allowances?.toString() ?? '');
    _notesController = TextEditingController(text: widget.payroll?.notes ?? '');

    if (widget.payroll != null) {
      _selectedEmployeeId = widget.payroll!.employeeId;
      _selectedMonth = widget.payroll!.month;
      _selectedYear = widget.payroll!.year;
      _paymentDate = widget.payroll!.paymentDate;
      _isPaid = widget.payroll!.isPaid;
      _netSalary = widget.payroll!.netSalary;
    }

    _baseSalaryController.addListener(_calculateNetSalary);
    _bonusController.addListener(_calculateNetSalary);
    _allowancesController.addListener(_calculateNetSalary);
  }

  @override
  void dispose() {
    _baseSalaryController.dispose();
    _bonusController.dispose();
    _deductionsController.dispose();
    _allowancesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _populateSalaryFieldsFromEmployee(Employee? employee) {
    if (employee == null) return;

    _baseSalaryController.text = employee.baseSalary?.toStringAsFixed(2) ?? '';
    _allowancesController.text = employee.allowances?.toStringAsFixed(2) ?? '';
    _bonusController.text = '';
    _deductionsController.text = '';
    _calculateNetSalary();
  }

  Employee? _getSelectedEmployee(List<Employee> employees) {
    for (final employee in employees) {
      if (employee.id == _selectedEmployeeId) return employee;
    }
    return null;
  }

  void _calculateNetSalary() {
    final base = double.tryParse(_baseSalaryController.text) ?? 0.0;
    final bonus = double.tryParse(_bonusController.text) ?? 0.0;
    final allowances = double.tryParse(_allowancesController.text) ?? 0.0;

    final attendanceState = ref.read(attendanceProvider);
    final holidayState = ref.read(holidayProvider);
    final leaveRequestState = ref.read(leaveRequestProvider);
    final autoDeductions = calculateAttendanceDeduction(
      baseSalary: base,
      employeeId: _selectedEmployeeId ?? '',
      month: _selectedMonth,
      year: _selectedYear,
      attendanceRecords: attendanceState.attendanceList,
      holidays: [
        ...holidayState.customHolidays,
      ],
      approvedLeaveRequests: leaveRequestState.leaveRequests,
      weeklyHolidays: holidayState.weeklyHolidays,
    );

    setState(() {
      _deductionsController.text = autoDeductions.toStringAsFixed(2);
      _netSalary = calculatePayrollNetSalary(
        baseSalary: base,
        bonus: bonus,
        allowances: allowances,
        autoDeductions: autoDeductions,
      );
    });
  }

  void _savePayroll() {
    if (_formKey.currentState!.validate() && _selectedEmployeeId != null) {
      final newPayroll = Payroll(
        id: widget.payroll?.id ?? 'payroll_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        month: _selectedMonth,
        year: _selectedYear,
        baseSalary: double.tryParse(_baseSalaryController.text) ?? 0.0,
        bonus: double.tryParse(_bonusController.text),
        deductions: double.tryParse(_deductionsController.text) ?? 0.0,
        allowances: double.tryParse(_allowancesController.text),
        netSalary: _netSalary,
        paymentDate: _paymentDate,
        isPaid: _isPaid,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        createdAt: widget.payroll?.createdAt ?? DateTime.now(),
        updatedAt: widget.payroll == null ? null : DateTime.now(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.payroll == null ? 'Salary Generated Successfully' : 'Payroll Updated'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, newPayroll);
    }
  }

  Future<void> _selectPaymentDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _paymentDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _paymentDate) {
      setState(() {
        _paymentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(attendanceProvider, (_, __) {
      if (mounted) {
        _calculateNetSalary();
      }
    });
    ref.listen(holidayProvider, (_, __) {
      if (mounted) {
        _calculateNetSalary();
      }
    });
    ref.listen(leaveRequestProvider, (_, __) {
      if (mounted) {
        _calculateNetSalary();
      }
    });

    final isEdit = widget.payroll != null;
    final employeeState = ref.watch(employeeProvider);
    if (!isEdit && _selectedEmployeeId == null && !employeeState.isLoading && employeeState.employees.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _selectedEmployeeId = employeeState.employees.first.id;
        });
        _populateSalaryFieldsFromEmployee(employeeState.employees.first);
      });
    }

    if (!isEdit && _selectedEmployeeId != null && !employeeState.isLoading) {
      final selectedEmployee = _getSelectedEmployee(employeeState.employees);
      if (selectedEmployee != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _populateSalaryFieldsFromEmployee(selectedEmployee);
        });
      }
    }
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Payroll' : 'Generate Salary'),
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
                title: 'Basic Details',
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Employee',
                      prefixIcon: const Icon(Icons.person, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    initialValue: _selectedEmployeeId,
                    items: employeeState.employees.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.fullName),
                      );
                    }).toList(),
                    onChanged: isEdit
                        ? null
                        : (val) {
                            if (val != null) {
                              setState(() {
                                _selectedEmployeeId = val;
                              });
                              final selectedEmployee = _getSelectedEmployee(ref.read(employeeProvider).employees);
                              if (selectedEmployee != null) {
                                _populateSalaryFieldsFromEmployee(selectedEmployee);
                              }
                              _calculateNetSalary();
                            }
                          },
                    validator: (val) => val == null ? 'Please select an employee' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Month',
                            prefixIcon: const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          initialValue: _selectedMonth,
                          items: List.generate(12, (index) {
                            return DropdownMenuItem(
                              value: index + 1,
                              child: Text(_getMonthName(index + 1)),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              if (val != null) _selectedMonth = val;
                            });
                            _calculateNetSalary();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          decoration: InputDecoration(
                            labelText: 'Year',
                            prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          initialValue: _selectedYear,
                          items: List.generate(10, (index) {
                            final year = DateTime.now().year - 5 + index;
                            return DropdownMenuItem(
                              value: year,
                              child: Text(year.toString()),
                            );
                          }),
                          onChanged: (val) {
                            setState(() {
                              if (val != null) _selectedYear = val;
                            });
                            _calculateNetSalary();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Salary Breakdown',
                children: [
                  TextFormField(
                    controller: _baseSalaryController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Base Salary',
                      prefixIcon: const Icon(Icons.currency_exchange, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter base salary';
                      if (double.tryParse(val) == null) return 'Please enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _allowancesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Allowances',
                            prefixIcon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _bonusController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Bonus',
                            prefixIcon: const Icon(Icons.star_outline, color: Colors.amber),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _deductionsController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Absent Deduction',
                      prefixIcon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Net Salary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '৳${_netSalary.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Payment Details',
                children: [
                  InkWell(
                    onTap: () => _selectPaymentDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Payment Date',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        _paymentDate.toIso8601String().split('T')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Status'),
                    subtitle: Text(_isPaid ? 'Paid' : 'Pending'),
                    value: _isPaid,
                    activeThumbColor: Colors.green,
                    onChanged: (val) {
                      setState(() {
                        _isPaid = val;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      prefixIcon: const Icon(Icons.notes, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _savePayroll,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  isEdit ? 'Update Payroll' : 'Generate Salary',
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

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
