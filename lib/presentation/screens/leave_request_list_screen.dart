import 'package:flutter/material.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/leave_request_model.dart';
import 'package:hr_management_system/data/models/mock_data.dart';
import 'package:hr_management_system/presentation/screens/leave_request_form_screen.dart';

class LeaveRequestListScreen extends StatefulWidget {
  const LeaveRequestListScreen({super.key});

  @override
  State<LeaveRequestListScreen> createState() => _LeaveRequestListScreenState();
}

class _LeaveRequestListScreenState extends State<LeaveRequestListScreen> {
  late List<LeaveRequest> _leaveRequests;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _leaveRequests = List.from(MockDataProvider.mockLeaveRequests);
  }

  List<LeaveRequest> get _filteredLeaveRequests {
    if (_searchQuery.isEmpty) return _leaveRequests;
    return _leaveRequests.where((leave) {
      final emp = MockDataProvider.mockEmployees.firstWhere(
        (e) => e.id == leave.employeeId,
        orElse: () => MockDataProvider.mockEmployees.first,
      );
      return emp.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          leave.status.displayName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          leave.leaveType.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _deleteLeaveRequest(String id) {
    setState(() {
      _leaveRequests.removeWhere((leave) => leave.id == id);
    });
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
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredLeaveRequests.length,
              itemBuilder: (context, index) {
                final leaveRequest = _filteredLeaveRequests[index];
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
            setState(() {
              _leaveRequests.insert(0, result);
            });
          }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Leave Request', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildLeaveRequestCard(BuildContext context, LeaveRequest leave) {
    final employee = MockDataProvider.mockEmployees.firstWhere(
      (e) => e.id == leave.employeeId,
      orElse: () => MockDataProvider.mockEmployees.first,
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
              builder: (context) => LeaveRequestFormScreen(leaveRequest: leave),
            ),
          );
          if (result != null && result is LeaveRequest) {
            setState(() {
              final index = _leaveRequests.indexWhere((l) => l.id == result.id);
              if (index != -1) {
                _leaveRequests[index] = result;
              }
            });
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
