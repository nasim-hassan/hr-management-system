import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/config/app_routes.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/user_model.dart';
import 'package:hr_management_system/data/providers/user_provider.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  String _searchQuery = '';
  UserRole? _selectedRole;

  List<User> get _filteredUsers {
    var filtered = ref.watch(userProvider).users
        .where((user) => user.role != UserRole.employee)
        .toList();

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (user.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
            (user.phoneNumber?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }

    // Filter by role
    if (_selectedRole != null) {
      filtered = filtered.where((user) => user.role == _selectedRole).toList();
    }

    return filtered;
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.hrAdmin:
        return Colors.red;
      case UserRole.manager:
        return Colors.orange;
      case UserRole.employee:
        return Colors.blue;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.hrAdmin:
        return Icons.admin_panel_settings;
      case UserRole.manager:
        return Icons.supervised_user_circle;
      case UserRole.employee:
        return Icons.person;
    }
  }

  void _deleteUser(User user) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deactivating user...')),
              );

              final success = await ref.read(userProvider.notifier).deleteUser(user.id);
              
              if (!mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${user.email} deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                final error = ref.read(userProvider).error ?? 'Failed to delete user';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
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
        title: const Text('Filter'),
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => _buildFilterSheet(),
              );
            },
          ),
        ],
      ),
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
                hintText: 'Search by email, name, or phone...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
                filled: true,
                fillColor: AppTheme.backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Active Filter Badge
          if (_selectedRole != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text('Role: ${_selectedRole!.displayName}'),
                onDeleted: () => setState(() => _selectedRole = null),
                backgroundColor: _getRoleColor(_selectedRole!).withValues(alpha: 0.2),
              ),
            ),

          // User List
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final userState = ref.watch(userProvider);

                if (userState.isLoading && userState.users.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userState.error != null && userState.users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${userState.error}',
                          style: const TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.read(userProvider.notifier).loadUsers(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (_filteredUsers.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.read(userProvider.notifier).loadUsers(),
                    child: ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'No users found',
                                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(userProvider.notifier).loadUsers(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return _buildUserCard(context, user);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, User user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.pushNamed(
            context,
            AppRoutes.userDetails.replaceAll(':id', user.id),
          );
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getRoleColor(user.role).withValues(alpha: 0.2),
                ),
                child: Center(
                  child: Icon(
                    _getRoleIcon(user.role),
                    color: _getRoleColor(user.role),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            user.role.displayName,
                            style: TextStyle(
                              fontSize: 11,
                              color: _getRoleColor(user.role),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          user.isActive ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: user.isActive ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            fontSize: 11,
                            color: user.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Actions
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editUser.replaceAll(':id', user.id),
                        arguments: user,
                      );
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () => _deleteUser(user),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSheet() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Role',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...UserRole.values
              .where((role) => role != UserRole.employee)
              .map((role) {
            return CheckboxListTile(
              value: _selectedRole == role,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value ?? false ? role : null;
                });
                Navigator.pop(context);
              },
              title: Text(role.displayName),
            );
          }),
        ],
      ),
    );
  }
}
