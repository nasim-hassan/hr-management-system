import 'package:flutter/material.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/payroll_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';

class PayrollFormScreen extends StatefulWidget {
  final Payroll? payroll;

  const PayrollFormScreen({super.key, this.payroll});

  @override
  State<PayrollFormScreen> createState() => _PayrollFormScreenState();
}

class _PayrollFormScreenState extends State<PayrollFormScreen> {
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
    _deductionsController = TextEditingController(text: widget.payroll?.deductions?.toString() ?? '');
    _allowancesController = TextEditingController(text: widget.payroll?.allowances?.toString() ?? '');
    _notesController = TextEditingController(text: widget.payroll?.notes ?? '');

    if (widget.payroll != null) {
      _selectedEmployeeId = widget.payroll!.employeeId;
      _selectedMonth = widget.payroll!.month;
      _selectedYear = widget.payroll!.year;
      _paymentDate = widget.payroll!.paymentDate;
      _isPaid = widget.payroll!.isPaid;
      _netSalary = widget.payroll!.netSalary;
    } else {
      if (MockDataProvider.mockEmployees.isNotEmpty) {
        _selectedEmployeeId = MockDataProvider.mockEmployees.first.id;
      }
    }

    _baseSalaryController.addListener(_calculateNetSalary);
    _bonusController.addListener(_calculateNetSalary);
    _deductionsController.addListener(_calculateNetSalary);
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

  void _calculateNetSalary() {
    final base = double.tryParse(_baseSalaryController.text) ?? 0.0;
    final bonus = double.tryParse(_bonusController.text) ?? 0.0;
    final allowances = double.tryParse(_allowancesController.text) ?? 0.0;
    final deductions = double.tryParse(_deductionsController.text) ?? 0.0;

    setState(() {
      _netSalary = base + bonus + allowances - deductions;
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
        deductions: double.tryParse(_deductionsController.text),
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
          content: Text(widget.payroll == null ? 'Payroll Added' : 'Payroll Updated'),
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
    final isEdit = widget.payroll != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Payroll' : 'Add Payroll'),
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
                    items: MockDataProvider.mockEmployees.map((e) {
                      return DropdownMenuItem(
                        value: e.id,
                        child: Text(e.fullName),
                      );
                    }).toList(),
                    onChanged: isEdit ? null : (val) {
                      setState(() {
                        if (val != null) {
                          _selectedEmployeeId = val;
                          // Auto-fill base salary if adding new
                          if (!isEdit) {
                            final emp = MockDataProvider.mockEmployees.firstWhere((e) => e.id == val);
                            _baseSalaryController.text = emp.salary ?? '';
                          }
                        }
                      });
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
                      prefixIcon: const Icon(Icons.currency_rupee, color: AppTheme.primaryColor),
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
                    decoration: InputDecoration(
                      labelText: 'Deductions',
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
                          '₹${_netSalary.toStringAsFixed(2)}',
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
                    activeColor: Colors.green,
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
                  isEdit ? 'Update Payroll' : 'Save Payroll',
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
