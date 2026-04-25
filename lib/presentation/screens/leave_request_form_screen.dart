import 'package:flutter/material.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

class LeaveRequestFormScreen extends StatefulWidget {
  final LeaveRequest? leaveRequest; // If null, Add Mode. If provided, Edit Mode.

  const LeaveRequestFormScreen({super.key, this.leaveRequest});

  @override
  State<LeaveRequestFormScreen> createState() => _LeaveRequestFormScreenState();
}

class _LeaveRequestFormScreenState extends State<LeaveRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedEmployeeId;
  LeaveType _selectedLeaveType = LeaveType.annual;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  LeaveStatus _selectedStatus = LeaveStatus.pending;
  
  late TextEditingController _reasonController;
  late TextEditingController _rejectionReasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.leaveRequest?.reason ?? '');
    _rejectionReasonController = TextEditingController(text: widget.leaveRequest?.rejectionReason ?? '');
    
    if (widget.leaveRequest != null) {
      _selectedEmployeeId = widget.leaveRequest!.employeeId;
      _selectedLeaveType = widget.leaveRequest!.leaveType;
      _startDate = widget.leaveRequest!.startDate;
      _endDate = widget.leaveRequest!.endDate;
      _selectedStatus = widget.leaveRequest!.status;
    } else {
      if (MockDataProvider.mockEmployees.isNotEmpty) {
        _selectedEmployeeId = MockDataProvider.mockEmployees.first.id;
      }
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _rejectionReasonController.dispose();
    super.dispose();
  }

  int get _numberOfDays {
    return _endDate.difference(_startDate).inDays + 1;
  }

  void _saveLeaveRequest() {
    if (_formKey.currentState!.validate() && _selectedEmployeeId != null) {
      if (_startDate.isAfter(_endDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Start Date cannot be after End Date'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final newLeaveRequest = LeaveRequest(
        id: widget.leaveRequest?.id ?? 'leave_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        leaveType: _selectedLeaveType,
        startDate: _startDate,
        endDate: _endDate,
        numberOfDays: _numberOfDays,
        reason: _reasonController.text,
        status: _selectedStatus,
        rejectionReason: _selectedStatus == LeaveStatus.rejected ? _rejectionReasonController.text : null,
        createdAt: widget.leaveRequest?.createdAt ?? DateTime.now(),
        updatedAt: widget.leaveRequest == null ? null : DateTime.now(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.leaveRequest == null ? 'Leave Request Created' : 'Leave Request Updated'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context, newLeaveRequest);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.leaveRequest != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Leave Request' : 'Create Leave Request'),
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
                title: 'Leave Details',
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
                        if (val != null) _selectedEmployeeId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<LeaveType>(
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      prefixIcon: const Icon(Icons.category, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    initialValue: _selectedLeaveType,
                    items: LeaveType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _selectedLeaveType = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Start Date',
                              prefixIcon: const Icon(Icons.date_range, color: Colors.green),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _startDate.toIso8601String().split('T')[0],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'End Date',
                              prefixIcon: const Icon(Icons.date_range, color: Colors.red),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _endDate.toIso8601String().split('T')[0],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Days: $_numberOfDays',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _reasonController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason for Leave',
                      prefixIcon: const Icon(Icons.text_snippet, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Please provide a reason' : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: 'Approval Status',
                children: [
                  DropdownButtonFormField<LeaveStatus>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.assignment_turned_in, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    initialValue: _selectedStatus,
                    items: LeaveStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        if (val != null) _selectedStatus = val;
                      });
                    },
                  ),
                  if (_selectedStatus == LeaveStatus.rejected) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _rejectionReasonController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Rejection Reason',
                        prefixIcon: const Icon(Icons.cancel, color: Colors.red),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      validator: (v) => _selectedStatus == LeaveStatus.rejected && (v == null || v.isEmpty)
                          ? 'Please provide a rejection reason'
                          : null,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveLeaveRequest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  isEdit ? 'Update Request' : 'Submit Request',
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
}
