/// Payroll Model - Employee salary and payment information
class Payroll {
  final String id;
  final String employeeId;
  final int month;
  final int year;
  final double baseSalary;
  final double? bonus;
  final double? deductions;
  final double? allowances;
  final double netSalary;
  final DateTime paymentDate;
  final String? payslipUrl; // URL to stored payslip PDF
  final String? transactionId;
  final bool isPaid;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.baseSalary,
    this.bonus,
    this.deductions,
    this.allowances,
    required this.netSalary,
    required this.paymentDate,
    this.payslipUrl,
    this.transactionId,
    required this.isPaid,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  /// Get month name
  String getMonthName() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      month: json['month'] ?? DateTime.now().month,
      year: json['year'] ?? DateTime.now().year,
      baseSalary: (json['base_salary'] ?? 0).toDouble(),
      bonus: json['bonus'] != null ? (json['bonus']).toDouble() : null,
      deductions: json['deductions'] != null
          ? (json['deductions']).toDouble()
          : null,
      allowances: json['allowances'] != null
          ? (json['allowances']).toDouble()
          : null,
      netSalary: (json['net_salary'] ?? 0).toDouble(),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : DateTime.now(),
      payslipUrl: json['payslip_url'],
      transactionId: json['transaction_id'],
      isPaid: json['is_paid'] ?? false,
      notes: json['notes'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'month': month,
      'year': year,
      'base_salary': baseSalary,
      'bonus': bonus,
      'deductions': deductions,
      'allowances': allowances,
      'net_salary': netSalary,
      'payment_date': paymentDate.toIso8601String(),
      'payslip_url': payslipUrl,
      'transaction_id': transactionId,
      'is_paid': isPaid,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Payroll copyWith({
    String? id,
    String? employeeId,
    int? month,
    int? year,
    double? baseSalary,
    double? bonus,
    double? deductions,
    double? allowances,
    double? netSalary,
    DateTime? paymentDate,
    String? payslipUrl,
    String? transactionId,
    bool? isPaid,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Payroll(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      year: year ?? this.year,
      baseSalary: baseSalary ?? this.baseSalary,
      bonus: bonus ?? this.bonus,
      deductions: deductions ?? this.deductions,
      allowances: allowances ?? this.allowances,
      netSalary: netSalary ?? this.netSalary,
      paymentDate: paymentDate ?? this.paymentDate,
      payslipUrl: payslipUrl ?? this.payslipUrl,
      transactionId: transactionId ?? this.transactionId,
      isPaid: isPaid ?? this.isPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Payroll &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Payroll(id: $id, employeeId: $employeeId, month: $month/$year, netSalary: $netSalary, isPaid: $isPaid)';
  }
}
