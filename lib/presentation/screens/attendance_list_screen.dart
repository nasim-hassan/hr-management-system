import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/attendance_model.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/data/providers/attendance_provider.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/data/services/attendance_service.dart';
import 'package:hr_management_system/presentation/screens/attendance_form_screen.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

class AttendanceListScreen extends ConsumerStatefulWidget {
  const AttendanceListScreen({super.key});

  @override
  ConsumerState<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends ConsumerState<AttendanceListScreen> {
  String _searchQuery = '';

  List<Attendance> _getFilteredAttendances(List<Attendance> attendances, List<Employee> employees) {
    if (_searchQuery.isEmpty) return attendances;
    return attendances.where((att) {
      final emp = employees.firstWhere(
        (e) => e.id == att.employeeId,
        orElse: () => Employee(
          id: '',
          userId: '',
          firstName: 'Unknown',
          lastName: '',
          email: '',
          phoneNumber: '',
          isActive: false,
          createdAt: DateTime.now(),
        ),
      );
      final empName = emp.id.isNotEmpty ? emp.fullName : 'Unknown';
      return empName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          att.status.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(attendanceProvider);
    final employeeState = ref.watch(employeeProvider);
    final filteredAttendances = _getFilteredAttendances(attendanceState.attendanceList, employeeState.employees);

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
            child: attendanceState.isLoading || employeeState.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : attendanceState.error != null || employeeState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 16),
                            Text('Error: ${attendanceState.error ?? employeeState.error}'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.invalidate(attendanceProvider);
                                ref.invalidate(employeeProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : filteredAttendances.isEmpty
                        ? const Center(
                            child: Text('No attendance records found'),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredAttendances.length,
                            itemBuilder: (context, index) {
                              final attendance = filteredAttendances[index];
                              final employee = employeeState.employees.firstWhere(
                                (e) => e.id == attendance.employeeId,
                                orElse: () => Employee(
                                  id: '',
                                  userId: '',
                                  firstName: 'Unknown',
                                  lastName: '',
                                  email: '',
                                  phoneNumber: '',
                                  isActive: false,
                                  createdAt: DateTime.now(),
                                ),
                              );
                              return _buildAttendanceCard(context, attendance, employee.id.isNotEmpty ? employee : null, ref);
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
            await ref.read(attendanceProvider.notifier).addAttendance(result);
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Record', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Attendance attendance, Employee? employee, WidgetRef ref) {
    final empName = employee?.fullName ?? 'Unknown Employee';
    final empInitials = employee != null ? '${employee.firstName[0]}${employee.lastName[0]}' : 'U';

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
            await ref.read(attendanceProvider.notifier).updateAttendance(result);
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
                    empInitials,
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
                      empName,
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
                          onPressed: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.pop(context);
                            await AttendanceService.deleteAttendance(attendance.id);
                            ref.invalidate(attendanceProvider);
                            if (mounted) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Attendance record deleted'),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
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
