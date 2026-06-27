import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hr_management_system/core/theme/app_theme.dart';
import 'package:hr_management_system/data/models/holiday_model.dart';
import 'package:hr_management_system/data/providers/holiday_provider.dart';
import 'package:hr_management_system/core/extensions/extensions.dart';

class HolidayListScreen extends ConsumerStatefulWidget {
  const HolidayListScreen({super.key});

  @override
  ConsumerState<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends ConsumerState<HolidayListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final List<Map<String, dynamic>> _days = [
    {'index': 1, 'name': 'Monday'},
    {'index': 2, 'name': 'Tuesday'},
    {'index': 3, 'name': 'Wednesday'},
    {'index': 4, 'name': 'Thursday'},
    {'index': 5, 'name': 'Friday'},
    {'index': 6, 'name': 'Saturday'},
    {'index': 7, 'name': 'Sunday'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddHolidayDialog(BuildContext context) {
    DateTime? tempStartDate;
    DateTime? tempEndDate;
    bool isRange = false;
    String? dateError;
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.celebration, color: AppTheme.primaryColor),
                  SizedBox(width: 10),
                  Text('Add Custom Holiday'),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Holiday Name',
                          hintText: 'e.g., Independence Day',
                          prefixIcon: Icon(Icons.edit),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter holiday name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Holiday Type',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Single Day')),
                              selected: !isRange,
                              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: !isRange ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                fontWeight: !isRange ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    isRange = false;
                                    tempEndDate = null;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text('Date Range')),
                              selected: isRange,
                              selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                              checkmarkColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isRange ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                                fontWeight: isRange ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setDialogState(() {
                                    isRange = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isRange ? 'Holiday Range' : 'Holiday Date',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          if (isRange) {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                              initialDateRange: tempStartDate != null && tempEndDate != null
                                  ? DateTimeRange(start: tempStartDate!, end: tempEndDate!)
                                  : null,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                tempStartDate = picked.start;
                                tempEndDate = picked.end;
                                dateError = null;
                              });
                            }
                          } else {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: tempStartDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                tempStartDate = picked;
                                tempEndDate = null;
                                dateError = null;
                              });
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            border: Border.all(
                              color: dateError != null ? Colors.red : Colors.grey[300]!,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: AppTheme.primaryColor),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  tempStartDate == null
                                      ? (isRange ? 'Select Holiday Range' : 'Select Holiday Date')
                                      : (isRange && tempEndDate != null
                                          ? '${tempStartDate!.toFormattedString(format: "MMM dd, yyyy")} - ${tempEndDate!.toFormattedString(format: "MMM dd, yyyy")}'
                                          : tempStartDate!.toFormattedString(format: 'EEEE, MMMM dd, yyyy')),
                                  style: TextStyle(
                                    color: tempStartDate == null ? Colors.grey[600] : AppTheme.textPrimaryColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (dateError != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          dateError!,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (tempStartDate == null) {
                        setDialogState(() {
                          dateError = 'Please select a date';
                        });
                        return;
                      }
                      if (isRange && tempEndDate == null) {
                        setDialogState(() {
                          dateError = 'Please select an end date';
                        });
                        return;
                      }
                      final newHoliday = Holiday(
                        id: 'h_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        date: tempStartDate!,
                        endDate: tempEndDate,
                      );
                      final success = await ref.read(holidayProvider.notifier).addCustomHoliday(newHoliday);
                      if (success && context.mounted) {
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Holiday "${newHoliday.name}" added successfully!'),
                            backgroundColor: AppTheme.successColor,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteHoliday(BuildContext context, Holiday holiday) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Custom Holiday'),
        content: Text('Are you sure you want to delete "${holiday.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref.read(holidayProvider.notifier).deleteCustomHoliday(holiday.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Holiday "${holiday.name}" deleted'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final holidayState = ref.watch(holidayProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Elegant customized tab bar
          Container(
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondaryColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'Weekly Holidays'),
                Tab(text: 'Custom Holidays'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Weekly Holidays tab
                _buildWeeklyHolidaysTab(holidayState),
                // 2. Custom Holidays tab
                _buildCustomHolidaysTab(holidayState),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton.extended(
              onPressed: () => _showAddHolidayDialog(context),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add Holiday',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : null,
    );
  }

  Widget _buildWeeklyHolidaysTab(HolidayState state) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildWeeklyHolidaysHeader(),
        ..._days.map((day) {
          final isHoliday = state.weeklyHolidays.contains(day['index']);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isHoliday
                          ? AppTheme.primaryColor.withValues(alpha: 0.1)
                          : Colors.grey[100],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: isHoliday ? AppTheme.primaryColor : Colors.grey[400],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isHoliday ? AppTheme.primaryColor : AppTheme.textPrimaryColor,
                          ),
                        ),
                        Text(
                          isHoliday ? 'Holiday (Recurring)' : 'Working Day',
                          style: TextStyle(
                            fontSize: 12,
                            color: isHoliday ? AppTheme.successColor : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: isHoliday,
                    activeTrackColor: AppTheme.primaryColor,
                    onChanged: (val) {
                      ref.read(holidayProvider.notifier).toggleWeeklyHoliday(day['index']);
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildCustomHolidaysTab(HolidayState state) {
    if (state.customHolidays.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration_outlined,
                size: 80,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Custom Holidays Set',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add national holidays, company anniversaries,\nand special observances here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showAddHolidayDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Add First Holiday'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _buildCustomHolidaysHeader(state.customHolidays.length),
        ...state.customHolidays.map((holiday) {
          final String subtitleText;
          if (holiday.endDate == null || holiday.endDate!.isSameDay(holiday.date)) {
            final weekdayName = _days.firstWhere(
              (d) => d['index'] == holiday.date.weekday,
              orElse: () => {'name': ''},
            )['name'];
            subtitleText = '${holiday.date.toFormattedString(format: "MMMM dd, yyyy")} ($weekdayName)';
          } else {
            final durationDays = holiday.endDate!.difference(holiday.date).inDays + 1;
            subtitleText = '${holiday.date.toFormattedString(format: "MMM dd, yyyy")} - ${holiday.endDate!.toFormattedString(format: "MMM dd, yyyy")} ($durationDays days)';
          }
          
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.celebration,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
              ),
              title: Text(
                holiday.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                subtitleText,
                style: const TextStyle(
                  color: AppTheme.textSecondaryColor,
                  fontSize: 13,
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                onPressed: () => _deleteHoliday(context, holiday),
              ),
            ),
          );
        }),
        const SizedBox(height: 80), // extra padding for FAB
      ],
    );
  }

  Widget _buildWeeklyHolidaysHeader() {
    return Card(
      elevation: 0,
      color: AppTheme.primaryColor.withValues(alpha: 0.05),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Weekly Recurring Holidays',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Define the standard weekly non-working days. Employees will automatically be marked off-duty on these days.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHolidaysHeader(int count) {
    return Card(
      elevation: 0,
      color: AppTheme.secondaryColor.withValues(alpha: 0.05),
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.secondaryColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppTheme.secondaryColor, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Custom Holidays ($count)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage specific calendar-based events, national holidays, and company observances.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
