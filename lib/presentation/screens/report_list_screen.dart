import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/enums/app_enums.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/report_model.dart';
import 'package:hr_management_system/data/providers/report_provider.dart';
import 'package:hr_management_system/presentation/screens/report_form_screen.dart';

class ReportListScreen extends ConsumerStatefulWidget {
  const ReportListScreen({super.key});

  @override
  ConsumerState<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends ConsumerState<ReportListScreen> {
  late List<Report> _reports;
  String _searchQuery = '';
  ReportType? _filterType;

  List<Report> _filteredReports(List<Report> reports) {
    return reports.where((report) {
      final matchesSearch = _searchQuery.isEmpty ||
          report.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesType = _filterType == null || report.type == _filterType;
      return matchesSearch && matchesType;
    }).toList();
  }

  Future<void> _deleteReport(String id) async {
    final success = await ref.read(reportProvider.notifier).deleteReport(id);
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete report'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report deleted'),
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
              title: const Text('Reports'),
              elevation: 0,
            )
          : null,
      body: Column(
        children: [
          // Search and Filter Bar
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
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search reports...',
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
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ReportType?>(
                      value: _filterType,
                      hint: const Text('All Types'),
                      icon: const Icon(Icons.filter_list, color: AppTheme.primaryColor),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Types'),
                        ),
                        ...ReportType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.displayName),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterType = value;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Report List
          Expanded(
            child: ref.watch(reportProvider).isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredReports(ref.watch(reportProvider).reports).length,
                    itemBuilder: (context, index) {
                      final report = _filteredReports(ref.watch(reportProvider).reports)[index];
                return _buildReportCard(context, report);
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
                builder: (context) => const ReportFormScreen(),
              ),
            );
            if (result != null && result is Report) {
              await ref.read(reportProvider.notifier).addReport(result);
            }
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Generate Report', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
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
                builder: (context) => ReportFormScreen(report: report),
              ),
            );
            if (result != null && result is Report) {
              await ref.read(reportProvider.notifier).updateReport(result);
            }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconForReportType(report.type),
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatusChip(report.status),
                        const SizedBox(width: 8),
                        Text(
                          '${report.createdAt.day}/${report.createdAt.month}/${report.createdAt.year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete Report'),
                          content: const Text('Are you sure you want to delete this report?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _deleteReport(report.id);
                              },
                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  if (report.fileUrl != null)
                    IconButton(
                      icon: const Icon(Icons.download, color: AppTheme.primaryColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading report...')),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForReportType(ReportType type) {
    switch (type) {
      case ReportType.attendance:
        return Icons.access_time;
      case ReportType.payroll:
        return Icons.payments;
      case ReportType.employee:
        return Icons.people;
      case ReportType.performance:
        return Icons.trending_up;
      case ReportType.other:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildStatusChip(ReportStatus status) {
    Color color;
    switch (status) {
      case ReportStatus.generated:
        color = Colors.green;
        break;
      case ReportStatus.pending:
        color = Colors.orange;
        break;
      case ReportStatus.failed:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
