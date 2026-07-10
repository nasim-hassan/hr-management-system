import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/providers/leave_request_provider.dart';
import 'package:hr_management_system/data/providers/employee_provider.dart';
import 'package:hr_management_system/data/models/employee_model.dart';
import 'package:hr_management_system/presentation/screens/leave_request_form_screen.dart';

class LeaveRequestListScreen extends ConsumerStatefulWidget {
  const LeaveRequestListScreen({super.key});

  @override
  ConsumerState<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends ConsumerState<LeaveRequestListScreen> {
  String _searchQuery = '';

  List<LeaveRequest> _filteredLeaveRequests(List<LeaveRequest> leaveRequests) {
    if (_searchQuery.isEmpty) return leaveRequests;
    return leaveRequests.where((leave) {
      return leave.status.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          leave.leaveType.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          leave.employeeId.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _deleteLeaveRequest(String id) async {
    final success = await ref.read(leaveRequestProvider.notifier).deleteLeaveRequest(id);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete leave request'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Leave Request deleted'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: canPop
          ? AppBar(
              title: const Text('Leave Requests'),
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
                hintText: 'Search by employee, status or type...',
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

          // Leave Request List
          Expanded(
            child: ref.watch(leaveRequestProvider).isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredLeaveRequests(ref.watch(leaveRequestProvider).leaveRequests).length,
                    itemBuilder: (context, index) {
                      final leaveRequest = _filteredLeaveRequests(ref.watch(leaveRequestProvider).leaveRequests)[index];
                      return _buildLeaveRequestCard(context, leaveRequest);
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
                builder: (context) => const LeaveRequestFormScreen(),
              ),
            );
            if (result != null && result is LeaveRequest) {
              await ref.read(leaveRequestProvider.notifier).addLeaveRequest(result);
            }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Leave Request', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLeaveRequestCard(BuildContext context, LeaveRequest leave) {
    final employeeState = ref.watch(employeeProvider);
    Employee? employee;
    if (!employeeState.isLoading && employeeState.employees.isNotEmpty) {
      try {
        employee = employeeState.employees.firstWhere((e) => e.id == leave.employeeId);
      } catch (_) {
        employee = null;
      }
    }

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
                builder: (context) => LeaveRequestFormScreen(leaveRequest: leave),
              ),
            );
            if (result != null && result is LeaveRequest) {
              await ref.read(leaveRequestProvider.notifier).updateLeaveRequest(result);
            }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Hero(
                tag: 'leave_avatar_${leave.id}',
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    employee != null
                        ? (employee.firstName.isNotEmpty ? employee.firstName[0] : '') + (employee.lastName.isNotEmpty ? employee.lastName[0] : '')
                        : '?',
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
                      employee?.fullName ?? leave.employeeId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leave.leaveType.displayName} Leave',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${leave.startDate.toIso8601String().split('T')[0]} to ${leave.endDate.toIso8601String().split('T')[0]} (${leave.numberOfDays} days)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusChip(leave.status.displayName),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Request'),
                      content: const Text('Are you sure you want to delete this leave request?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _deleteLeaveRequest(leave.id);
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
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      case 'cancelled':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange; // pending
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
