import 'package:flutter/material.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

class AttendanceFormScreen extends StatefulWidget {
  final Attendance? attendance; // If null, Add Mode. If provided, Edit Mode.

  const AttendanceFormScreen({super.key, this.attendance});

  @override
  State<AttendanceFormScreen> createState() => _AttendanceFormScreenState();
}

class _AttendanceFormScreenState extends State<AttendanceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedEmployeeId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  AttendanceStatus _selectedStatus = AttendanceStatus.present;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.attendance?.notes ?? '');
    
    if (widget.attendance != null) {
      _selectedEmployeeId = widget.attendance!.employeeId;
      _selectedDate = widget.attendance!.date;
      _selectedStatus = widget.attendance!.status;
      if (widget.attendance!.checkInTime != null) {
        _checkInTime = TimeOfDay.fromDateTime(widget.attendance!.checkInTime!);
      }
      if (widget.attendance!.checkOutTime != null) {
        _checkOutTime = TimeOfDay.fromDateTime(widget.attendance!.checkOutTime!);
      }
    } else {
      if (MockDataProvider.mockEmployees.isNotEmpty) {
        _selectedEmployeeId = MockDataProvider.mockEmployees.first.id;
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveAttendance() {
    if (_formKey.currentState!.validate() && _selectedEmployeeId != null) {
      DateTime? finalCheckIn;
      DateTime? finalCheckOut;
      
      if (_checkInTime != null) {
        finalCheckIn = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _checkInTime!.hour, _checkInTime!.minute);
      }
      if (_checkOutTime != null) {
        finalCheckOut = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _checkOutTime!.hour, _checkOutTime!.minute);
      }

      final newAttendance = Attendance(
        id: widget.attendance?.id ?? 'att_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        date: _selectedDate,
        checkInTime: finalCheckIn,
        checkOutTime: finalCheckOut,
        status: _selectedStatus,
        notes: _notesController.text,
        createdAt: widget.attendance?.createdAt ?? DateTime.now(),
        updatedAt: widget.attendance == null ? null : DateTime.now(),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.attendance == null ? 'Attendance Record Added' : 'Attendance Record Updated'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
      
      Navigator.pop(context, newAttendance);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isCheckIn) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isCheckIn 
          ? (_checkInTime ?? const TimeOfDay(hour: 9, minute: 0))
          : (_checkOutTime ?? const TimeOfDay(hour: 18, minute: 0)),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInTime = picked;
        } else {
          _checkOutTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.attendance != null;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Attendance' : 'Add Attendance Record'),
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
                title: 'Attendance Details',
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
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Date',
                        prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        _selectedDate.toIso8601String().split('T')[0],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context, true),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Check In Time',
                              prefixIcon: const Icon(Icons.access_time, color: Colors.green),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _checkInTime != null 
                                ? '${_checkInTime!.hour.toString().padLeft(2, '0')}:${_checkInTime!.minute.toString().padLeft(2, '0')}'
                                : 'Not Set',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectTime(context, false),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Check Out Time',
                              prefixIcon: const Icon(Icons.access_time, color: Colors.red),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _checkOutTime != null 
                                ? '${_checkOutTime!.hour.toString().padLeft(2, '0')}:${_checkOutTime!.minute.toString().padLeft(2, '0')}'
                                : 'Not Set',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AttendanceStatus>(
                    decoration: InputDecoration(
                      labelText: 'Status',
                      prefixIcon: const Icon(Icons.fact_check, color: AppTheme.primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    initialValue: _selectedStatus,
                    items: AttendanceStatus.values.map((s) {
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
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAttendance,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  isEdit ? 'Update Record' : 'Save Record',
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
