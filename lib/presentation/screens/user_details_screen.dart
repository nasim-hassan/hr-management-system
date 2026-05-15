import 'package:flutter/material.dart';
import 'package:hr_management_system/config/app_routes.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;
  final User? user; // Optional pre-loaded user

  const UserDetailsScreen({
    super.key,
    required this.userId,
    this.user,
  });

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  late User _user;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user ?? _getMockUser(widget.userId);
  }

  User _getMockUser(String userId) {
    // Mock data - in real app, fetch from Supabase
    final roleIndex = userId.hashCode % 3;
    return User(
      id: userId,
      email: 'user${userId.hashCode % 100}@example.com',
      fullName: 'User ${userId.hashCode % 100}',
      role: roleIndex == 0
          ? UserRole.hrAdmin
          : roleIndex == 1
              ? UserRole.manager
              : UserRole.employee,
      phoneNumber: '+880 1711 ${000 + (userId.hashCode % 900)}${0000 + (userId.hashCode % 9999)}',
      isActive: userId.hashCode % 2 == 0,
      createdAt: DateTime.now().subtract(Duration(days: userId.hashCode % 365)),
      updatedAt: DateTime.now().subtract(Duration(days: userId.hashCode % 30)),
    );
  }

  void _deleteUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text(
          'Are you sure you want to permanently delete ${_user.email}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Delete from Supabase
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_user.email} deleted successfully'),
                  backgroundColor: Colors.red,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('User Details'),
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
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 8),
                    const Text('Edit'),
                  ],
                ),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.editUser.replaceAll(':id', _user.id),
                    arguments: _user,
                  );
                },
              ),
              PopupMenuItem(
                child: Row(
                  children: [
                    const Icon(Icons.delete, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
                onTap: _deleteUser,
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Header Card
                  _buildUserHeaderCard(),
                  const SizedBox(height: 20),

                  // Basic Information
                  _buildSectionCard(
                    title: 'Basic Information',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('Email', _user.email),
                      _buildInfoRow('Full Name', _user.fullName ?? 'N/A'),
                      _buildInfoRow('Phone', _user.phoneNumber ?? 'N/A'),
                      _buildInfoRow('Role', _user.role.displayName),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account Status
                  _buildSectionCard(
                    title: 'Account Status',
                    icon: Icons.security,
                    children: [
                      _buildInfoRow(
                        'Status',
                        _user.isActive ? 'Active' : 'Inactive',
                        valueColor: _user.isActive ? Colors.green : Colors.red,
                      ),
                      _buildInfoRow(
                        'Created On',
                        DateFormat('MMM dd, yyyy - hh:mm a').format(_user.createdAt),
                      ),
                      if (_user.updatedAt != null)
                        _buildInfoRow(
                          'Last Updated',
                          DateFormat('MMM dd, yyyy - hh:mm a').format(_user.updatedAt!),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Profile Image
                  if (_user.profileImage != null)
                    _buildSectionCard(
                      title: 'Profile Picture',
                      icon: Icons.image,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _user.profileImage!,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(Icons.broken_image),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 20),

                  // Additional Information Box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _user.role.displayName == 'HR Admin'
                                ? 'This user has administrative access to all HR functions.'
                                : _user.role.displayName == 'Manager'
                                    ? 'This user can manage employees and approve requests.'
                                    : 'This user has standard employee access.',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildUserHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
            ),
            child: _user.profileImage != null
                ? ClipOval(
                    child: Image.network(
                      _user.profileImage!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(
                            _user.fullName?.isNotEmpty == true
                                ? _user.fullName!
                                    .split(' ')
                                    .map((e) => e[0])
                                    .join()
                                    .toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Center(
                    child: Text(
                      _user.fullName?.isNotEmpty == true
                          ? _user.fullName!
                              .split(' ')
                              .map((e) => e[0])
                              .join()
                              .toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(
            _user.fullName ?? 'Unknown User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            _user.email,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white30),
            ),
            child: Text(
              _user.role.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
