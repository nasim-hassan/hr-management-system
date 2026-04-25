import 'package:flutter/material.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';
import 'package:hr_management_system/presentation/screens/attendance_form_screen.dart';

class AttendanceListScreen extends StatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late List<Attendance> _attendances;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _attendances = List.from(MockDataProvider.mockAttendance);
  }

  List<Attendance> get _filteredAttendances {
    if (_searchQuery.isEmpty) return _attendances;
    return _attendances.where((att) {
      final emp = MockDataProvider.mockEmployees.firstWhere(
        (e) => e.id == att.employeeId,
      );
      return emp.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          att.status.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _deleteAttendance(String id) {
    setState(() {
      _attendances.removeWhere((att) => att.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attendance record deleted'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
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
                hintText: 'Search by employee name or status...',
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

          // Attendance List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredAttendances.length,
              itemBuilder: (context, index) {
                final attendance = _filteredAttendances[index];
                return _buildAttendanceCard(context, attendance);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AttendanceFormScreen(),
            ),
          );
          if (result != null && result is Attendance) {
            setState(() {
              _attendances.insert(0, result);
            });
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Attendance attendance) {
    final employee = MockDataProvider.mockEmployees.firstWhere(
      (e) => e.id == attendance.employeeId,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AttendanceFormScreen(attendance: attendance),
            ),
          );
          if (result != null && result is Attendance) {
            setState(() {
              final index = _attendances.indexWhere((a) => a.id == result.id);
              if (index != -1) {
                _attendances[index] = result;
              }
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'att_avatar_${attendance.id}',
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
                      'Date: ${attendance.date.toIso8601String().split('T')[0]}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatusChip(attendance.status.displayName),
                        if (attendance.checkInTime != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'In: ${attendance.checkInTime!.hour.toString().padLeft(2, '0')}:${attendance.checkInTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                        if (attendance.checkOutTime != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            'Out: ${attendance.checkOutTime!.hour.toString().padLeft(2, '0')}:${attendance.checkOutTime!.minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Record'),
                      content: const Text('Are you sure you want to delete this attendance record?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteAttendance(attendance.id);
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present':
        color = Colors.green;
        break;
      case 'absent':
        color = Colors.red;
        break;
      case 'half day':
        color = Colors.orange;
        break;
      case 'late':
        color = Colors.amber;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
